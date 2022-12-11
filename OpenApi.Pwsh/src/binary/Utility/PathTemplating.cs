using Tavis.UriTemplates;

namespace OpenApi.Pwsh.Utility;

/// <summary>
/// Static utility class for URI Template of Paths.
/// </summary>
/// <seealso href="https://spec.openapis.org/oas/v3.1.0#path-templating">3.2 Path Templating | OpenAPI Specification v3.1.0</seealso>
/// <seealso href="https://swagger.io/docs/specification/paths-and-operations/">Paths and Operations</seealso>
/// <seealso href="https://swagger.io/docs/specification/describing-parameters/">Describing Parameters</seealso>
/// <seealso href="https://swagger.io/docs/specification/serialization/">Parameter Serialization</seealso>
/// <seealso href="https://www.rfc-editor.org/rfc/rfc6570.html">RFC 6570: URI Template</seealso>
internal static class PathTemplating {

	internal static UriTemplate CreateUriTemplate(
		string serverUrl,
		string openApiPath,
		IList<OpenApiParameter> openApiParameters
	) {
		StringBuilder sb = new(serverUrl);
		_ = sb
			.Append(CreateUriTemplateStringOfPath(openApiPath, openApiParameters))
			.Append(CreateUriTemplateStringOfQuery(openApiParameters));

		return new(sb.ToString());
	}

	internal static string CreateUriTemplateStringOfPath(string openApiPath, IList<OpenApiParameter> openApiParameters) {
		var pathParameters = openApiParameters.Where(p => p.In is ParameterLocation.Path);
		foreach (var p in pathParameters) {
			var newValue = p switch {
#pragma warning disable IDE0055
				{ Style: ParameterStyle.Simple or null, Explode: false } => null,
				{ Style: ParameterStyle.Simple or null, Explode: true } => $"{{{p.Name}*}}",
				{ Style: ParameterStyle.Label, Explode: false } => $"{{.{p.Name}}}",
				{ Style: ParameterStyle.Label, Explode: true } => $"{{.{p.Name}*}}",
				{ Style: ParameterStyle.Matrix, Explode: false } => $"{{;{p.Name}}}",
				{ Style: ParameterStyle.Matrix, Explode: true } => $"{{;{p.Name}*}}",
#pragma warning restore IDE0055
				_ => throw new PSNotSupportedException($"The OpenApiParameter is not supported {{ In: {p.In}, Style: {p.Style}, Explode: {p.Explode} }}.")
			};

			if (newValue is not null) {
				openApiPath = openApiPath.Replace($"{{{p.Name}}}", newValue);
			}
		}

		return openApiPath;
	}

	internal static string CreateUriTemplateStringOfQuery(IList<OpenApiParameter> openApiParameters) {
		List<string> variableList = new();

		var queryParameters = openApiParameters.Where(p => p.In is ParameterLocation.Query);
		foreach (var p in queryParameters) {
			var variable = p switch {
#pragma warning disable IDE0055
				{ Style: ParameterStyle.Form or null, Explode: true } => $"{p.Name}*",
				{ Style: ParameterStyle.Form or null, Explode: false } => p.Name,
				{ Style: ParameterStyle.SpaceDelimited, Explode: true } => $"{p.Name}*",
				{ Style: ParameterStyle.PipeDelimited, Explode: true } => $"{p.Name}*",
#pragma warning restore IDE0055
				_ => throw new PSNotSupportedException($"The OpenApiParameter is not supported {{ In: {p.In}, Style: {p.Style}, Explode: {p.Explode} }}.")
			};

			if (variable is not null) {
				variableList.Add(variable);
			}
		}

		return variableList.Any()
			? $"{{?{string.Join(',', variableList)}}}"
			: string.Empty;
	}
}
