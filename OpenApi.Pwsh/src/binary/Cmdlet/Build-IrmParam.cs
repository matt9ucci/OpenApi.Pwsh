using OpenApi.Pwsh.Completion;
using OpenApi.Pwsh.Extension;
using OpenApi.Pwsh.Utility;

namespace OpenApi.Pwsh.Cmdlet;

/// <summary>
/// Build-IrmParam cmdlet.
/// </summary>
[Cmdlet(VerbsLifecycle.Build, "IrmParam")]
[OutputType(typeof(Hashtable))]
public class BuildIrmParamCmdlet : PSCmdlet, IDynamicParameters {

	/// <summary>
	/// The OpenAPI document name of the uri.
	/// </summary>
	[Parameter(Position = 0, Mandatory = true)]
	[ArgumentCompleter(typeof(OpenApiNameCompleter))]
	public string OpenApiName { get; init; } = string.Empty;

	/// <summary>
	/// The OperationId of the uri.
	/// </summary>
	[Parameter(Position = 1, Mandatory = true)]
	[OperationIdCompletion(nameof(OpenApiName))]
	public string OperationId { get; init; } = string.Empty;

	private RuntimeDefinedParameterDictionary _dynParams = null!;

	public object GetDynamicParameters() {
		if (string.IsNullOrEmpty(OpenApiName) || string.IsNullOrEmpty(OperationId)) {
			return null!;
		}

		var doc = GetDocument();
		var searchResult = doc.GetSearchResultByOperationId(OperationId);

		var openApiParamsForDynParams = searchResult.Operation.Parameters.Where(
			param => param.In is ParameterLocation.Path or ParameterLocation.Query
		);

		_dynParams = new();
		foreach (var openApiParam in openApiParamsForDynParams) {
			_dynParams.Add(openApiParam.Name, new(
				openApiParam.Name,
				openApiParam.ResolvePwshParameterType(),
				CreateAttributes(openApiParam)
			));
		}

		return _dynParams;
	}

	/// <inheritdoc/>
	protected override void EndProcessing() {
		WriteDebug_dynParams();

		var doc = GetDocument();
		var searchResult = doc.GetSearchResultByOperationId(OperationId);

		var template = PathTemplating.CreateUriTemplate(
			GetServerUrl(doc),
			searchResult.CurrentKeys.Path,
			searchResult.Operation.Parameters
		);

		foreach (var dynParam in _dynParams.Values) {
			template.SetParameter(dynParam.Name, dynParam.Value switch {
				SwitchParameter s => s ? "true" : "false",
				_ => dynParam.Value
			});
		}

		Hashtable irmParams = new() {
			["Uri"] = new Uri(template.Resolve()),
			["Method"] = searchResult.CurrentKeys.Operation.ToWebRequestMethod(),
		};

		WriteObject(irmParams, false);
	}

	private static string GetServerUrl(OpenApiDocument doc) {
		return doc.Servers.Any()
			? doc.Servers.First().Url
			: throw new PSInvalidOperationException($"OpenApiServer does not exist.");
	}

	private OpenApiDocument GetDocument() {
		var path = new[] { $"{Configuration.Current.DriveName}:{OpenApiName}" };

		try {
			return (OpenApiDocument)InvokeProvider.Item.Get(path, false, true).Single().BaseObject;
		} catch (ItemNotFoundException e) {
			throw new ItemNotFoundException($"Cannot find OpenApiName '{OpenApiName}' because it does not exist.", e);
		}
	}

	private static Collection<Attribute> CreateAttributes(OpenApiParameter openApiParam) {
		return new() {
			// The alias prefixed with '_' can help to tell dynamic param from static one.
			new AliasAttribute($"_{openApiParam.Name}"),
			openApiParam.ToPwshParameterAttribute()
		};
	}

	private void WriteDebug_dynParams() {
		foreach (var dynParam in _dynParams.Values) {
			WriteDebug($"{dynParam.Name} = {dynParam.Value} ({dynParam.ParameterType})");
			foreach (var attribute in dynParam.Attributes) {
				var text = attribute switch {
					AliasAttribute a => $"Alias = {string.Join(',', a.AliasNames)}",
					ParameterAttribute p => $"Mandatory = {p.Mandatory}, HelpMessage = \"{p.HelpMessage}\"",
					_ => $"{nameof(attribute.TypeId)} = {attribute.TypeId}"
				};
				WriteDebug($"  {text}");
			}
		}
	}
}
