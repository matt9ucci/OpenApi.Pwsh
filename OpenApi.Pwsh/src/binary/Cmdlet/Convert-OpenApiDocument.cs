using System.Management.Automation.Language;
using Microsoft.OpenApi.Extensions;

namespace OpenApi.Pwsh.Cmdlet;

/// <summary>
/// Convert-OpenApiDocument cmdlet.
/// </summary>
[Cmdlet(VerbsData.Convert, "OpenApiDocument",
	DefaultParameterSetName = "ModelToString"
)]
public class ConvertOpenApiDocument : PSCmdlet {

	/// <summary>
	/// OpenAPI document or fragment as <see cref="IOpenApiSerializable"/>.
	/// </summary>
	[Parameter(
		Position = 0, ParameterSetName = "ModelToString",
		Mandatory = true, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true
	)]
	public IOpenApiSerializable Model { get; init; } = null!;

	/// <summary>
	/// OpenAPI document or fragment as JSON/YAML.
	/// </summary>
	[Parameter(
		Position = 0, ParameterSetName = "StringToModel",
		Mandatory = true, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true
	)]
	[Parameter(
		Position = 0, ParameterSetName = "FragmentToModel",
		Mandatory = true, ValueFromPipeline = true, ValueFromPipelineByPropertyName = true
	)]
	public string String { get; init; } = string.Empty;

	/// <summary>
	/// The type to which convert fragment (<see cref="String"/>).
	/// </summary>
	[ArgumentCompleter(typeof(ConvertibleTypeCompleter))]
	[Parameter(ParameterSetName = "FragmentToModel", Mandatory = true)]
	public Type Type { get; init; } = null!;

	/// <summary>
	/// The version of OpenAPI specification.
	/// </summary>
	[Parameter(ParameterSetName = "ModelToString")]
	[Parameter(ParameterSetName = "FragmentToModel")]
	public OpenApiSpecVersion Version { get; init; } = Configuration.Current.Version;

	/// <summary>
	/// The format of OpenAPI document.
	/// </summary>
	[Parameter(ParameterSetName = "ModelToString")]
	public OpenApiFormat Format { get; init; } = Configuration.Current.Format;

	/// <summary>
	/// The <see cref="OpenApiReaderSettings"/> to convert <see cref="String"/> to model.
	/// </summary>
	[Parameter(ParameterSetName = "StringToModel")]
	[Parameter(ParameterSetName = "FragmentToModel")]
	public OpenApiReaderSettings ReaderSettings { get; init; } = Configuration.Current.OpenApiReaderSettings;

	/// <summary>
	/// The <see cref="OpenApiWriterSettings"/> to convert <see cref="Model"/> to JSON/YAML.
	/// </summary>
	[Parameter(ParameterSetName = "ModelToString")]
	public OpenApiWriterSettings WriterSettings { get; init; } = Configuration.Current.OpenApiWriterSettings;

	private readonly List<string> _stringList = new();

	/// <inheritdoc/>
	protected override void BeginProcessing() {
		if (ParameterSetName == "FragmentToModel") {
			if (!typeof(IOpenApiElement).IsAssignableFrom(Type)) {
				throw new PSArgumentException();
			}
		}
	}

	/// <inheritdoc/>
	protected override void ProcessRecord() {
		switch (ParameterSetName) {
			case "ModelToString":
				ModelToString();
				break;
			case "StringToModel" or "FragmentToModel":
				_stringList.Add(String);
				break;
			default:
				// Unreachable case
				break;
		}

		void ModelToString() {
			MemoryStream stream = new();
			Model.Serialize(stream, Version, Format, WriterSettings);

			StreamReader reader = new(stream);
			reader.BaseStream.Position = 0;
			var docString = reader.ReadToEnd();

			WriteObject(docString);
		}
	}

	/// <inheritdoc/>
	protected override void EndProcessing() {
		var sendToPipeline = ParameterSetName switch {
			"StringToModel" => StringToModel(),
			"FragmentToModel" => FragmentToModel(),
			_ => null! // "ModelToString"
		};

		if (sendToPipeline is not null) {
			WriteObject(sendToPipeline);
		}

		object StringToModel() {
			var normalizedString = string.Join('\n', _stringList).Replace("\r\n", "\n").Replace("\r", "\n");

			var doc = new OpenApiStringReader(ReaderSettings).Read(normalizedString, out var diagnostic);

			WriteDiagnostic(diagnostic);

			return doc;
		}

		object FragmentToModel() {
			var normalizedString = string.Join('\n', _stringList).Replace("\r\n", "\n").Replace("\r", "\n");

			var method_ReadFragment = typeof(OpenApiStringReader).GetMethod(
				nameof(OpenApiStringReader.ReadFragment),
				new[]{
					typeof(string),
					typeof(OpenApiSpecVersion),
					typeof(OpenApiDiagnostic).MakeByRefType()
				}
			)!.MakeGenericMethod(Type);
			var parameters = new object[] { normalizedString, Version, null! };

			var openApiElement = method_ReadFragment.Invoke(new OpenApiStringReader(ReaderSettings), parameters)!;

			WriteDiagnostic((OpenApiDiagnostic)parameters[2]);

			return openApiElement;
		}
	}

	private void WriteDiagnostic(OpenApiDiagnostic diagnostic) {
		foreach (var warning in diagnostic.Warnings) {
			WriteWarning(warning.ToString());
		}

		foreach (var error in diagnostic.Errors) {
			WriteError(new(
				new Exception(error.ToString()),
				"OpenApi.Pwsh.InvalidData",
				ErrorCategory.InvalidData,
				null // Avoid setting the _stringList which would be too long
			));
		}
	}

	private class ConvertibleTypeCompleter : IArgumentCompleter {
		private static readonly string[] _convertibleTypeNames_2_0 = {
			"Microsoft.OpenApi.Any.IOpenApiAny",
			"Microsoft.OpenApi.Models.OpenApiContact",
			"Microsoft.OpenApi.Models.OpenApiExternalDocs",
			"Microsoft.OpenApi.Models.OpenApiHeader",
			"Microsoft.OpenApi.Models.OpenApiInfo",
			"Microsoft.OpenApi.Models.OpenApiLicense",
			"Microsoft.OpenApi.Models.OpenApiOperation",
			"Microsoft.OpenApi.Models.OpenApiParameter",
			"Microsoft.OpenApi.Models.OpenApiPathItem",
			"Microsoft.OpenApi.Models.OpenApiPaths",
			"Microsoft.OpenApi.Models.OpenApiResponse",
			"Microsoft.OpenApi.Models.OpenApiResponses",
			"Microsoft.OpenApi.Models.OpenApiSchema",
			"Microsoft.OpenApi.Models.OpenApiSecurityRequirement",
			"Microsoft.OpenApi.Models.OpenApiSecurityScheme",
			"Microsoft.OpenApi.Models.OpenApiTag",
			"Microsoft.OpenApi.Models.OpenApiXml",
		};

		private static readonly string[] _convertibleTypeNames_3_0 = {
			"Microsoft.OpenApi.Any.IOpenApiAny",
			"Microsoft.OpenApi.Models.OpenApiCallback",
			"Microsoft.OpenApi.Models.OpenApiComponents",
			"Microsoft.OpenApi.Models.OpenApiContact",
			"Microsoft.OpenApi.Models.OpenApiEncoding",
			"Microsoft.OpenApi.Models.OpenApiExample",
			"Microsoft.OpenApi.Models.OpenApiExternalDocs",
			"Microsoft.OpenApi.Models.OpenApiHeader",
			"Microsoft.OpenApi.Models.OpenApiInfo",
			"Microsoft.OpenApi.Models.OpenApiLicense",
			"Microsoft.OpenApi.Models.OpenApiLink",
			"Microsoft.OpenApi.Models.OpenApiMediaType",
			"Microsoft.OpenApi.Models.OpenApiOAuthFlow",
			"Microsoft.OpenApi.Models.OpenApiOAuthFlows",
			"Microsoft.OpenApi.Models.OpenApiOperation",
			"Microsoft.OpenApi.Models.OpenApiParameter",
			"Microsoft.OpenApi.Models.OpenApiPathItem",
			"Microsoft.OpenApi.Models.OpenApiPaths",
			"Microsoft.OpenApi.Models.OpenApiRequestBody",
			"Microsoft.OpenApi.Models.OpenApiResponse",
			"Microsoft.OpenApi.Models.OpenApiResponses",
			"Microsoft.OpenApi.Models.OpenApiSchema",
			"Microsoft.OpenApi.Models.OpenApiSecurityRequirement",
			"Microsoft.OpenApi.Models.OpenApiSecurityScheme",
			"Microsoft.OpenApi.Models.OpenApiServer",
			"Microsoft.OpenApi.Models.OpenApiServerVariable",
			"Microsoft.OpenApi.Models.OpenApiTag",
			"Microsoft.OpenApi.Models.OpenApiXml",
		};

		public IEnumerable<CompletionResult> CompleteArgument(string commandName, string parameterName, string wordToComplete, CommandAst commandAst, IDictionary fakeBoundParameters) {
			var version = Enum.TryParse<OpenApiSpecVersion>(fakeBoundParameters[nameof(Version)]?.ToString(), out var v)
				? v
				: Configuration.Current.Version;

			var convertibleTypeNames = version switch {
				OpenApiSpecVersion.OpenApi2_0 => _convertibleTypeNames_2_0,
				OpenApiSpecVersion.OpenApi3_0 => _convertibleTypeNames_3_0,
				_ => _convertibleTypeNames_3_0,
			};

			var wordToCompletePattern = WildcardPattern.Get(
				string.IsNullOrWhiteSpace(wordToComplete) ? "*" : $"*{wordToComplete}*",
				WildcardOptions.IgnoreCase
			);

			return
				from name in convertibleTypeNames
				where wordToCompletePattern.IsMatch(name)
				orderby name
				select new CompletionResult(name, name, CompletionResultType.ParameterValue, name);
		}
	}
}
