namespace OpenApi.Pwsh.Extension;

internal static class OpenApiDocumentExtension {

	internal static SearchResult GetSearchResultByOperationId(this OpenApiDocument doc, string operationId) {
		OperationSearch search = new((_, _, operation) => operation.OperationId == operationId);
		new OpenApiWalker(search).Walk(doc);

		return search.SearchResults.Count switch {
			1 => search.SearchResults.Single(),
			> 1 => throw new PSArgumentException($"The operationId '{operationId}' is duplicated.", nameof(operationId)),
			_ => throw new ItemNotFoundException($"The operationId '{operationId}' does not exist."),
		};
	}

	internal static IList<OpenApiParameter> GetOpenApiParameter(this OpenApiDocument doc, string operationId) {
		var searchResult = doc.GetSearchResultByOperationId(operationId);

		var operationParams_All = searchResult.Operation.Parameters;
		var pathItemParams_All = doc.Paths[searchResult.CurrentKeys.Path].Parameters;

		var operationParams_Unique = operationParams_All.DistinctBy(KeySelector);
		var pathItemParams_Unique = pathItemParams_All.DistinctBy(KeySelector);

		var pathItemParams = pathItemParams_Unique.ExceptBy(operationParams_Unique.Select(KeySelector), KeySelector);

		var openApiParams = pathItemParams.Concat(operationParams_Unique);

		return openApiParams.ToList();

		static (string, ParameterLocation?) KeySelector(OpenApiParameter param) {
			return (param.Name, param.In);
		}
	}
}
