using OpenApi.Pwsh.Completion;
using OpenApi.Pwsh.Extension;

namespace OpenApi.Pwsh.Cmdlet;

/// <summary>
/// Get-OpenApiParameter cmdlet.
/// </summary>
[Cmdlet(VerbsCommon.Get, "OpenApiParameter")]
[OutputType(typeof(OpenApiParameter))]
public class GetOpenApiParameterCmdlet : PSCmdlet {

	/// <summary>
	/// The OpenAPI document name of the OpenApiParameter.
	/// </summary>
	[Parameter(Position = 0, Mandatory = true)]
	[ArgumentCompleter(typeof(OpenApiNameCompleter))]
	public string OpenApiName { get; init; } = string.Empty;

	/// <summary>
	/// The OperationId of the OpenApiParameter.
	/// </summary>
	[Parameter(Position = 1, Mandatory = true)]
	[OperationIdCompletion(nameof(OpenApiName))]
	public string OperationId { get; init; } = string.Empty;

	/// <inheritdoc/>
	protected override void EndProcessing() {
		var doc = GetDocument();

		var openApiParams = doc.GetOpenApiParameter(OperationId);

		WriteObject(openApiParams, true);
	}

	private OpenApiDocument GetDocument() {
		var path = new[] { $"{Configuration.Current.DriveName}:{OpenApiName}" };

		try {
			return (OpenApiDocument)InvokeProvider.Item.Get(path, false, true).Single().BaseObject;
		} catch (ItemNotFoundException e) {
			throw new ItemNotFoundException($"Cannot find OpenApiName '{OpenApiName}' because it does not exist.", e);
		}
	}
}
