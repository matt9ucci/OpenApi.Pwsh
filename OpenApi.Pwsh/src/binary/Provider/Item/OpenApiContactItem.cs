namespace OpenApi.Pwsh.Provider.Item;

/// <summary>
/// <see cref="OpenApiContact"/> as an item.
/// </summary>
internal class OpenApiContactItem : ItemBase<OpenApiContact> {

	/// <inheritdoc/>
	internal OpenApiContactItem(string name, OpenApiContact value) : base(name, value) {
	}
}
