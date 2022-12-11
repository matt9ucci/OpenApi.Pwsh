namespace OpenApi.Pwsh.Extension;

internal static class OpenApiParameterExtension {

	/// <seealso href="https://swagger.io/docs/specification/data-models/data-types/">Data Types<seealso/>
	internal static Type ResolvePwshParameterType(this OpenApiParameter param) {
		return param.Schema.Type switch {
			"boolean" => typeof(SwitchParameter),
			"string" => typeof(string),
			"integer" => param.Schema.Format switch {
				"int32" => typeof(int),
				"int64" => typeof(long),
				_ => typeof(long)
			},
			"number" => param.Schema.Format switch {
				"float" => typeof(float),
				"double" => typeof(double),
				_ => typeof(decimal)
			},
			_ => typeof(object),
		};
	}

	internal static ParameterAttribute ToPwshParameterAttribute(this OpenApiParameter param) {
		return new() {
			Mandatory = param.Required,
			HelpMessage = param.Description ?? $"OpenAPI parameter in {param.In}."
		};
	}
}
