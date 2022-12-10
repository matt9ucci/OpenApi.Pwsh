using OpenApi.Pwsh.Extension;

namespace OpenApi.Pwsh.Test.Xunit.Extension;

public class OpenApiDocumentExtensionTest {

	[Fact]
	public void GetSearchResultByOperationId() {
		const string path = "path01";
		const OperationType operationType = OperationType.Get;
		const string operationId = "GetPath01";

		OpenApiDocument doc = new() {
			Paths = new() {
				[path] = new() {
					Operations = new Dictionary<OperationType, OpenApiOperation> {
						[operationType] = new() {
							OperationId = operationId,
						}
					}
				}
			}
		};

		var searchResult = doc.GetSearchResultByOperationId(operationId);

		Assert.Equal(path, searchResult.CurrentKeys.Path);
		Assert.Equal(operationType, searchResult.CurrentKeys.Operation);
		Assert.Equal(operationId, searchResult.Operation.OperationId);
	}

	[Fact]
	public void GetSearchResultByOperationId_NotFound() {
		OpenApiDocument doc = new() {
			Paths = new() {
				["path01"] = new() {
					Operations = new Dictionary<OperationType, OpenApiOperation> {
						[OperationType.Get] = new() {
							OperationId = "GetPath01",
						}
					}
				}
			}
		};

		const string operationId = "NotFound";
		var exception = Assert.Throws<ItemNotFoundException>(() => doc.GetSearchResultByOperationId(operationId));
		Assert.Equal($"The operationId '{operationId}' does not exist.", exception.Message);
	}

	[Fact]
	public void GetSearchResultByOperationId_Duplicated_OperationId() {
		const string operationId = "GetPath01";

		OpenApiDocument doc = new() {
			Paths = new() {
				["path01"] = new() {
					Operations = new Dictionary<OperationType, OpenApiOperation> {
						[OperationType.Get] = new() { OperationId = operationId },
						[OperationType.Put] = new() { OperationId = operationId },
					}
				}
			}
		};

		var exception = Assert.Throws<PSArgumentException>(() => doc.GetSearchResultByOperationId(operationId));
		Assert.Equal($"The operationId '{operationId}' is duplicated.", exception.Message);
	}
}
