namespace OpenApi.Pwsh.Provider.Item;

/// <summary>
/// <see cref="OpenApiDocument"/> as an item.
/// </summary>
internal class OpenApiDocumentItem : ItemBase<OpenApiDocument>, IContainer {

	/// <inheritdoc/>
	internal OpenApiDocumentItem(string name, OpenApiDocument value) : base(name, value) {
	}

	/// <inheritdoc/>
	public IEnumerable<IItem> GetChildItems() {
		if (Value.ExternalDocs is not null) { yield return new OpenApiExternalDocsItem("ExternalDocs", Value.ExternalDocs); }
		if (Value.Info is not null) { yield return new OpenApiInfoItem("Info", Value.Info); }
		if (Value.Servers is not null) { yield return new ListOpenApiServerItem("Servers", Value.Servers); }
	}

	/// <inheritdoc/>
	public IItem SetChildItem(string name, object value) {
		return name.ToLower() switch {
			"externaldocs" => new OpenApiExternalDocsItem(name, Value.ExternalDocs = Cast<OpenApiExternalDocs>(value)),
			"info" => new OpenApiInfoItem(name, Value.Info = Cast<OpenApiInfo>(value)),
			"servers" => new ListOpenApiServerItem(name, Value.Servers = Cast<IList<OpenApiServer>>(value)),
			_ => throw new PSArgumentException($"Cannot set {value.GetType()} as a child item of {Value.GetType()} by name '{name}'."),
		};
	}
}
