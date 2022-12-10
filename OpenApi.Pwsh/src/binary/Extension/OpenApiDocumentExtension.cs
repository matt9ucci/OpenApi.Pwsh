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
}
