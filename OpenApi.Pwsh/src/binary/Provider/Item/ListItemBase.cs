namespace OpenApi.Pwsh.Provider.Item;

/// <summary>
/// The base class for an OpenApiProvider item as <see cref="IList{T}"/>.
/// </summary>
/// <typeparam name="TElement">The type of the list element.</typeparam>
internal abstract class ListItemBase<TElement> : ItemBase<IList<TElement>>, IContainer {

	/// <inheritdoc/>
	internal ListItemBase(string name, IList<TElement> value) : base(name, value) {
	}

	/// <inheritdoc/>
	public IEnumerable<IItem> GetChildItems() {
		return Value.Select((element, index) => CreateChildItem(index.ToString(), element));
	}

	/// <summary>
	/// Adds or replaces an item in the list by the name.
	/// </summary>
	/// <param name="name">The name of the item.</param>
	/// <param name="value">The value of the item.</param>
	/// <returns>The return value of the <see cref="CreateChildItem"/> method.</returns>
	/// <exception cref="PSArgumentException"><paramref name="name"/> is not an int.</exception>
	/// <exception cref="PSArgumentOutOfRangeException"><paramref name="name"/> is greater than the list count.</exception>
	public IItem SetChildItem(string name, object value) {
		if (!int.TryParse(name, out var index)) {
			throw new PSArgumentException($"'{name}' is not an int.", nameof(name));
		}

		TElement item = Cast<TElement>(value);

		switch (index) {
			case int i when i < Value.Count:
				// Replace
				Value[i] = item;
				break;
			case int i when i == Value.Count:
				// Create
				Value.Add(item);
				break;
			default:
				throw new PSArgumentOutOfRangeException(
					nameof(name),
					index,
					$"Cannot set the item at {index} because it is greater than {Value.Count}."
				);
		};

		return CreateChildItem(name, item);
	}

	/// <summary>
	/// Creates the child item of the list.
	/// </summary>
	/// <param name="name">The name of the child item.</param>
	/// <param name="value">The value of the child item.</param>
	/// <returns>The child item.</returns>
	protected abstract IItem CreateChildItem(string name, TElement value);
}
