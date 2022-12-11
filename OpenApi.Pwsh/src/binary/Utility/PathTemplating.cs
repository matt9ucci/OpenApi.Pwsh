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
		IList<OpenApiParameter> openApiParams
	) {
		StringBuilder sb = new(serverUrl);
		_ = sb
			.Append(CreateUriTemplateStringOfPath(openApiPath, openApiParams))
			.Append(CreateUriTemplateStringOfQuery(openApiParams));

		return new(sb.ToString());
	}

	internal static string CreateUriTemplateStringOfPath(string openApiPath, IList<OpenApiParameter> openApiParams) {
		var pathParams = openApiParams.Where(p => p.In is ParameterLocation.Path);
		foreach (var param in pathParams) {
			var variable = param switch {
#pragma warning disable IDE0055
				{ Style: ParameterStyle.Simple or null, Explode: false } => null,
				{ Style: ParameterStyle.Simple or null, Explode: true } => $"{{{param.Name}*}}",
				{ Style: ParameterStyle.Label, Explode: false } => $"{{.{param.Name}}}",
				{ Style: ParameterStyle.Label, Explode: true } => $"{{.{param.Name}*}}",
				{ Style: ParameterStyle.Matrix, Explode: false } => $"{{;{param.Name}}}",
				{ Style: ParameterStyle.Matrix, Explode: true } => $"{{;{param.Name}*}}",
#pragma warning restore IDE0055
				_ => throw new PSNotSupportedException($"The OpenApiParameter is not supported {{ In: {param.In}, Style: {param.Style}, Explode: {param.Explode} }}.")
			};

			if (variable is not null) {
				openApiPath = openApiPath.Replace($"{{{param.Name}}}", variable);
			}
		}

		return openApiPath;
	}

	internal static string CreateUriTemplateStringOfQuery(IList<OpenApiParameter> openApiParams) {
		List<string> variableList = new();

		var queryParams = openApiParams.Where(p => p.In is ParameterLocation.Query);
		foreach (var param in queryParams) {
			var variable = param switch {
#pragma warning disable IDE0055
				{ Style: ParameterStyle.Form or null, Explode: true } => $"{param.Name}*",
				{ Style: ParameterStyle.Form or null, Explode: false } => param.Name,
				{ Style: ParameterStyle.SpaceDelimited, Explode: true } => $"{param.Name}*",
				{ Style: ParameterStyle.PipeDelimited, Explode: true } => $"{param.Name}*",
#pragma warning restore IDE0055
				_ => throw new PSNotSupportedException($"The OpenApiParameter is not supported {{ In: {param.In}, Style: {param.Style}, Explode: {param.Explode} }}.")
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
