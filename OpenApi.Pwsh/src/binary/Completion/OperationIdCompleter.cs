namespace OpenApi.Pwsh.Completion;

internal class OperationIdCompleter : IArgumentCompleter {

	private readonly string _sourceParameter;

	public OperationIdCompleter(string sourceParameter) {
		_sourceParameter = sourceParameter;
	}

	public IEnumerable<CompletionResult> CompleteArgument(string commandName, string parameterName, string wordToComplete, CommandAst commandAst, IDictionary fakeBoundParameters) {
		OpenApiDocument doc = fakeBoundParameters[_sourceParameter] switch {
			string openApiName => GetDocument(openApiName),
			OpenApiDocument d => d,
			_ => new() // The completion result will be empty
		};

		var wildcard = WildcardPattern.Get($"{wordToComplete}*", WildcardOptions.IgnoreCase);
		OperationSearch search = new((_, _, operation) => wildcard.IsMatch(operation.OperationId));
		new OpenApiWalker(search).Walk(doc);

		return
			from result in search.SearchResults
			orderby result.Operation.OperationId
			select new CompletionResult(
				result.Operation.OperationId,
				result.Operation.OperationId,
				CompletionResultType.ParameterValue,
				BuildToolTip(result)
			);
	}

	private static OpenApiDocument GetDocument(string openApiName) {
		try {
			var ps = PowerShell.Create(RunspaceMode.CurrentRunspace)
				.AddCommand(ProviderCmdlet.GetItem)
				.AddParameter("LiteralPath", $"{Configuration.Current.DriveName}:{openApiName}");
			return (OpenApiDocument)ps.Invoke().Single().BaseObject;
		} catch {
			return new();
		}
	}

	private static string BuildToolTip(SearchResult result) {
		var toolTip = new StringBuilder()
			.Append(result.CurrentKeys.Operation)
			.Append(' ')
			.Append(result.CurrentKeys.Path);

		// Append either Summary or Description if possible
		if (!string.IsNullOrEmpty(result.Operation.Summary)) {
			_ = toolTip
				.AppendLine()
				.Append(result.Operation.Summary);
		} else if (!string.IsNullOrEmpty(result.Operation.Description)) {
			_ = toolTip
				.AppendLine()
				.Append(result.Operation.Description);
		}

		return toolTip.ToString();
	}
}

internal class OperationIdCompletionAttribute : ArgumentCompleterFactoryAttribute {

	private readonly string _sourceParameter;

	public OperationIdCompletionAttribute(string sourceParameter) {
		_sourceParameter = sourceParameter;
	}

	public override IArgumentCompleter Create() {
		return new OperationIdCompleter(_sourceParameter);
	}
}
