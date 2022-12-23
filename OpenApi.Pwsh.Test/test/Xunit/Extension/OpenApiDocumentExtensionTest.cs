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

	[Theory]
	[InlineData(0, 0)]
	[InlineData(0, 1)]
	[InlineData(0, 2)]
	[InlineData(1, 0)]
	[InlineData(1, 1)]
	[InlineData(1, 2)]
	[InlineData(2, 0)]
	[InlineData(2, 1)]
	[InlineData(2, 2)]
	public void GetOpenApiParameter(int pathItemParamCount, int operationParamCount) {
		const string path = "path01";
		const OperationType operationType = OperationType.Get;
		const string operationId = "GetPath01";

		List<OpenApiParameter> pathItemParams = new();
		for (var i = 0; i < pathItemParamCount; i++) {
			pathItemParams.Add(new() { Name = $"PathItemParam{i}", In = ParameterLocation.Path });
		}

		List<OpenApiParameter> operationParams = new();
		for (var i = 0; i < operationParamCount; i++) {
			operationParams.Add(new() { Name = $"OperationParam{i}", In = ParameterLocation.Path });
		}

		OpenApiDocument doc = new() {
			Paths = new() {
				[path] = new() {
					Parameters = pathItemParams,
					Operations = new Dictionary<OperationType, OpenApiOperation> {
						[operationType] = new() {
							OperationId = operationId,
							Parameters = operationParams
						}
					}
				}
			}
		};

		var openApiParams = doc.GetOpenApiParameter(operationId);

		Assert.Equal(pathItemParamCount + operationParamCount, openApiParams.Count);
		Assert.Equal(doc.Paths[path].Parameters.Concat(doc.Paths[path].Operations[operationType].Parameters), openApiParams);
	}

	[Fact]
	public void GetOpenApiParameter_PathItem_Overridden_By_Operation() {
		const string path = "path01";
		const OperationType operationType = OperationType.Get;
		const string operationId = "GetPath01";

		OpenApiDocument doc = new() {
			Paths = new() {
				[path] = new() {
					Parameters = new List<OpenApiParameter> {
						new() { Name = $"PathItemParam01", In = ParameterLocation.Path },
						new() { Name = $"Overridden", In = ParameterLocation.Path, Description = "PathItem" },
					},
					Operations = new Dictionary<OperationType, OpenApiOperation> {
						[operationType] = new() {
							OperationId = operationId,
							Parameters = new List<OpenApiParameter> {
								new() { Name = $"OperationParam01", In = ParameterLocation.Path },
								new() { Name = $"Overridden", In = ParameterLocation.Path, Description = "Operation" },
							}
						}
					}
				}
			}
		};

		var openApiParams = doc.GetOpenApiParameter(operationId);

		Assert.Equal(3, openApiParams.Count);
		Assert.Equal(doc.Paths[path].Parameters[0], openApiParams[0]);
		Assert.Equal(doc.Paths[path].Operations[operationType].Parameters[0], openApiParams[1]);
		Assert.Equal(doc.Paths[path].Operations[operationType].Parameters[1], openApiParams[2]);
	}
}
