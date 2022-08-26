namespace OpenApi.Pwsh.Provider.Item;

/// <summary>
/// Represents an OpenApiProvider item.
/// </summary>
internal interface IItem {

	/// <summary>
	/// Determines if the item is a container.
	/// </summary>
	bool IsContainer { get; }

	/// <summary>
	/// The name of the item.
	/// </summary>
	string Name { get; }

	/// <summary>
	/// The value of the item.
	/// </summary>
	object Value { get; }
}
