namespace OpenApi.Pwsh.Provider.Item;

/// <summary>
/// <see cref="OpenApiServer"/> as an item.
/// </summary>
internal class OpenApiServerItem : ItemBase<OpenApiServer> {

	/// <inheritdoc/>
	internal OpenApiServerItem(string name, OpenApiServer value) : base(name, value) {
	}
}
