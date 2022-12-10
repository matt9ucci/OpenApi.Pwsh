using OpenApi.Pwsh.Completion;
using OpenApi.Pwsh.Extension;

namespace OpenApi.Pwsh.Cmdlet;

/// <summary>
/// Show-OpenApiExternalDocs cmdlet.
/// </summary>
[Cmdlet(VerbsCommon.Show, "OpenApiExternalDocs")]
[OutputType(typeof(OpenApiExternalDocs))]
public class ShowOpenApiExternalDocsCmdlet : PSCmdlet {

	/// <summary>
	/// The OpenAPI document name of the external documentation.
	/// </summary>
	[Parameter(Position = 0, Mandatory = true)]
	[ArgumentCompleter(typeof(OpenApiNameCompleter))]
	public string OpenApiName { get; init; } = string.Empty;

	/// <summary>
	/// The OperationId of the external documentation.
	/// </summary>
	[Parameter(Position = 1)]
	[OperationIdCompletion(nameof(OpenApiName))]
	public string OperationId { get; init; } = string.Empty;

	/// <summary>
	/// Returns the <see cref="OpenApiExternalDocs"/> object.
	/// </summary>
	[Parameter]
	public SwitchParameter AsModel { get; init; }

	/// <inheritdoc/>
	protected override void EndProcessing() {
		var doc = GetDocument();
		var externalDocs = GetExternalDocs(doc);

		if (AsModel) {
			WriteObject(externalDocs);
			return;
		}

		WriteVerbose($"OpenApiExternalDocs {{ Url = \"{externalDocs.Url}\", Description = \"{externalDocs.Description}\" }}");

		if (externalDocs.Url is null) {
			throw new PSInvalidOperationException($"The URL of the external documentation is undefined.");
		} else {
			// Show in browser
			_ = PowerShell.Create(RunspaceMode.CurrentRunspace)
				.AddCommand("Start-Process")
				.AddParameter("FilePath", externalDocs.Url.ToString())
				.Invoke();
		}
	}

	private OpenApiDocument GetDocument() {
		var path = $"{Configuration.Current.DriveName}:{OpenApiName}";

		try {
			return InvokeProvider.Item.Get(path)
				.Select(psObject => psObject.BaseObject).Cast<OpenApiDocument>().Single();
		} catch (ItemNotFoundException e) {
			throw new ItemNotFoundException($"Cannot find OpenApiName '{OpenApiName}' because it does not exist.", e);
		}
	}

	private OpenApiExternalDocs GetExternalDocs(OpenApiDocument doc) {
		return string.IsNullOrEmpty(OperationId)
			? doc.ExternalDocs ?? new()
			: doc.GetSearchResultByOperationId(OperationId).Operation.ExternalDocs ?? new();
	}
}
