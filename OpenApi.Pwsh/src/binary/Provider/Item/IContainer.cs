namespace OpenApi.Pwsh.Provider.Item;

/// <summary>
/// Represents an OpenApiProvider container.
/// </summary>
internal interface IContainer : IItem {

	/// <summary>
	/// Gets the child item by name.
	/// </summary>
	/// <param name="name">The name of the child item.</param>
	/// <returns>The child item.</returns>
	IItem GetChildItem(string name) {
		return GetChildItems()
			.Where(item => item.Name.Equals(name, StringComparison.OrdinalIgnoreCase))
			.SingleOrDefault(new NotFound(name));
	}

	/// <summary>
	/// Gets child items.
	/// </summary>
	/// <returns>Child items.</returns>
	IEnumerable<IItem> GetChildItems();

	/// <summary>
	/// Sets the child item by name.
	/// </summary>
	/// <param name="name">The name of the child item.</param>
	/// <param name="value">The child item.</param>
	/// <returns>The child item.</returns>
	IItem SetChildItem(string name, object value);
}
