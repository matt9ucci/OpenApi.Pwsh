namespace OpenApi.Pwsh.Extension;

internal static class OperationTypeExtension {

	internal static WebRequestMethod ToWebRequestMethod(this OperationType? operationType) {
		return operationType switch {
			OperationType.Get => WebRequestMethod.Get,
			OperationType.Put => WebRequestMethod.Put,
			OperationType.Post => WebRequestMethod.Post,
			OperationType.Delete => WebRequestMethod.Delete,
			OperationType.Options => WebRequestMethod.Options,
			OperationType.Head => WebRequestMethod.Head,
			OperationType.Patch => WebRequestMethod.Patch,
			OperationType.Trace => WebRequestMethod.Trace,
			null => throw new PSArgumentNullException(nameof(operationType)),
			_ => throw new PSArgumentOutOfRangeException(nameof(operationType)),
		};
	}
}
