namespace OpenApi.Pwsh.Provider.Item;

/// <summary>
/// Represents an item which is not found.
/// </summary>
internal class NotFound : ItemBase<object>, IContainer {

	/// <inheritdoc/>
	internal NotFound(string name) : base(name, string.Empty) {
	}

	/// <summary>
	/// Returns this instance.
	/// </summary>
	/// <returns>This instance.</returns>
	public IEnumerable<IItem> GetChildItems() {
		yield return this;
	}

	/// <summary>
	/// Not supported.
	/// </summary>
	/// <exception cref="PSNotSupportedException"/>
	public void RemoveChildItem(string name) {
		throw new PSNotSupportedException();
	}

	/// <summary>
	/// Not supported.
	/// </summary>
	/// <exception cref="PSNotSupportedException"/>
	public IItem SetChildItem(string name, object value) {
		throw new PSNotSupportedException();
	}
}
