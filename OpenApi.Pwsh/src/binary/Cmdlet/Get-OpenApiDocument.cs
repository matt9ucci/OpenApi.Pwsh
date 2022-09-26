namespace OpenApi.Pwsh.Cmdlet;

/// <summary>
/// Get-OpenApiDocument cmdlet.
/// </summary>
[Cmdlet(VerbsCommon.Get, "OpenApiDocument")]
[OutputType(typeof(OpenApiDocument))]
public class GetOpenApiDocumentCmdlet : PSCmdlet {

	/// <summary>
	/// The name which is associated with the OpenAPI document.
	/// </summary>
	[Parameter(Position = 0)]
	[SupportsWildcards]
	public string OpenApiName { get; init; } = "*";

	/// <inheritdoc/>
	protected override void EndProcessing() {
		var path = $"{Configuration.Current.DriveName}:{OpenApiName}";

		try {
			var docs = InvokeProvider.Item.Get(path);
			WriteObject(docs, true);
		} catch (ItemNotFoundException e) {
			throw new ItemNotFoundException($"Cannot find OpenApiName '{OpenApiName}' because it does not exist.", e);
		}
	}
}
