namespace OpenApi.Pwsh.Completion;

internal class OpenApiNameCompleter : IArgumentCompleter {
	public IEnumerable<CompletionResult> CompleteArgument(string commandName, string parameterName, string wordToComplete, CommandAst commandAst, IDictionary fakeBoundParameters) {
		var ps = PowerShell.Create(RunspaceMode.CurrentRunspace)
			.AddCommand(ProviderCmdlet.GetChildItem)
			.AddParameter("Path", $"{Configuration.Current.DriveName}:{wordToComplete}*");

		return
			from psObject in ps.Invoke()
			select new {
				Name = psObject.Properties["PSChildName"].Value.ToString(),
				((OpenApiDocument)psObject.BaseObject).Info
			} into doc
			orderby doc.Name
			select new CompletionResult(
				doc.Name, doc.Name, CompletionResultType.ParameterValue,
				$"{doc.Info.Title}{Environment.NewLine}Version {doc.Info.Version}"
			);
	}
}
