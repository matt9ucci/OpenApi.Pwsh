using OpenApi.Pwsh.Utility;

namespace OpenApi.Pwsh.Test.Xunit.Utility;

public class PathTemplatingTest {

	[Fact]
	public void CreateUriTemplate_SimpleCase() {
		List<OpenApiParameter> openApiParameters = new() {
			new() { Name = "path", In = ParameterLocation.Path, Style = ParameterStyle.Simple, Explode = false },
			new() { Name = "query", In = ParameterLocation.Query, Style = ParameterStyle.Form, Explode = true },
		};

		var actual = PathTemplating.CreateUriTemplate("https://example.com", "/users/{path}", openApiParameters);

		Assert.Equal("https://example.com/users/{path}{?query*}", actual.ToString());
	}

	/// <seealso href="https://swagger.io/docs/specification/serialization/">Parameter Serialization</seealso>
	[Theory]
	[InlineData(null, false, "/users/{id}")]
	[InlineData(null, true, "/users/{id*}")]
	[InlineData(ParameterStyle.Simple, false, "/users/{id}")]
	[InlineData(ParameterStyle.Simple, true, "/users/{id*}")]
	[InlineData(ParameterStyle.Label, false, "/users/{.id}")]
	[InlineData(ParameterStyle.Label, true, "/users/{.id*}")]
	[InlineData(ParameterStyle.Matrix, false, "/users/{;id}")]
	[InlineData(ParameterStyle.Matrix, true, "/users/{;id*}")]
	public void CreateUriTemplateStringOfPath_Style_Explode_Cases(ParameterStyle? style, bool explode, string expected) {
		List<OpenApiParameter> openApiParameters = new() {
			new() { Name = "id", In = ParameterLocation.Path, Style = style, Explode = explode },
		};

		var actual = PathTemplating.CreateUriTemplateStringOfPath("/users/{id}", openApiParameters);

		Assert.Equal(expected, actual);
	}

	/// <seealso href="https://swagger.io/docs/specification/serialization/">Parameter Serialization</seealso>
	[Theory]
	[InlineData(null, true, "{?id*}")]
	[InlineData(null, false, "{?id}")]
	[InlineData(ParameterStyle.Form, true, "{?id*}")]
	[InlineData(ParameterStyle.Form, false, "{?id}")]
	[InlineData(ParameterStyle.SpaceDelimited, true, "{?id*}")]
	[InlineData(ParameterStyle.PipeDelimited, true, "{?id*}")]
	public void CreateUriTemplateStringOfQuery_Style_Explode_Cases(ParameterStyle? style, bool explode, string expected) {
		List<OpenApiParameter> openApiParameters = new() {
			new() { Name = "id", In = ParameterLocation.Query, Style = style, Explode = explode },
		};

		var actual = PathTemplating.CreateUriTemplateStringOfQuery(openApiParameters);

		Assert.Equal(expected, actual);
	}

	/// <seealso href="https://swagger.io/docs/specification/serialization/">Parameter Serialization</seealso>
	[Theory]
	[InlineData(ParameterStyle.SpaceDelimited, false)]
	[InlineData(ParameterStyle.PipeDelimited, false)]
	[InlineData(ParameterStyle.DeepObject, false)]
	public void CreateUriTemplateStringOfQuery_Style_Explode_NotSupported(ParameterStyle? style, bool explode) {
		List<OpenApiParameter> openApiParameters = new() {
			new() { Name = "id", In = ParameterLocation.Query, Style = style, Explode = explode },
		};

		_ = Assert.Throws<PSNotSupportedException>(() => PathTemplating.CreateUriTemplateStringOfQuery(openApiParameters));
	}
}
