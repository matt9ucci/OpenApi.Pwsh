namespace OpenApi.Pwsh.Provider.Item;

/// <summary>
/// <see cref="IOpenApiRegistry"/> as an item.
/// </summary>
internal class OpenApiRegistryItem : ItemBase<IOpenApiRegistry>, IContainer {

	/// <inheritdoc/>
	internal OpenApiRegistryItem(string name, IOpenApiRegistry value) : base(name, value) {
	}

	/// <inheritdoc/>
	public IItem GetChildItem(string name) {
		return Value.TryGet(name, out OpenApiDocument doc)
			? new OpenApiDocumentItem(name, doc)
			: new NotFound(name);
	}

	/// <inheritdoc/>
	public IEnumerable<IItem> GetChildItems() {
		foreach (var name in Value.GetNames()) {
			yield return GetChildItem(name);
		}
	}

	/// <inheritdoc/>
	public void RemoveChildItem(string name) {
		_ = Value.Unregister(name);
	}

	/// <inheritdoc/>
	public IItem SetChildItem(string name, object value) {
		var doc = Cast<OpenApiDocument>(value);
		Value.Register(name, doc);
		return new OpenApiDocumentItem(name, doc);
	}
}
