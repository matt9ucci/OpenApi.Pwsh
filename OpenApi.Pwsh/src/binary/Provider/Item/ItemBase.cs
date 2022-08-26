namespace OpenApi.Pwsh.Provider.Item;

/// <summary>
/// The base class for an OpenApiProvider item.
/// </summary>
/// <typeparam name="TValue">The type of item value.</typeparam>
internal abstract class ItemBase<TValue> : IItem {

	/// <inheritdoc/>
	public bool IsContainer => this is IContainer;

	/// <inheritdoc/>
	public string Name { get; init; }

	/// <summary>
	/// The value of the item.
	/// </summary>
	internal TValue Value { get; init; }

	/// <inheritdoc/>
	object IItem.Value => Value!;

	/// <summary>
	/// Constructor.
	/// </summary>
	/// <param name="name">The name of the item.</param>
	/// <param name="value">The value of the item.</param>
	internal ItemBase(string name, TValue value) {
		Name = name;
		Value = value;
	}

	/// <summary>
	/// Casts the value: it may be a <see cref="PSObject"/>.
	/// </summary>
	/// <typeparam name="T">The type to cast <paramref name="value"/>.</typeparam>
	/// <param name="value">The value.</param>
	/// <returns><paramref name="value"/> as <typeparamref name="T"/>.</returns>
	/// <exception cref="PSInvalidCastException">Cannot cast <paramref name="value"/> as <typeparamref name="T"/>.</exception>
	protected static T Cast<T>(object value) {
		return value switch {
			PSObject p when p.BaseObject is T v => v,
			T v => v,
			_ => throw new PSInvalidCastException($"Cannot cast {value.GetType()} as {typeof(T)}.")
		};
	}
}
