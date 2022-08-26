namespace OpenApi.Pwsh.Provider.Item;

/// <summary>
/// <see cref="IList{OpenApiServer}"/> as an item.
/// </summary>
internal class ListOpenApiServerItem : ListItemBase<OpenApiServer> {

	/// <inheritdoc/>
	internal ListOpenApiServerItem(string name, IList<OpenApiServer> value) : base(name, value) {
	}

	/// <inheritdoc/>
	protected override IItem CreateChildItem(string name, OpenApiServer item) {
		return new OpenApiServerItem(name, item);
	}
}
