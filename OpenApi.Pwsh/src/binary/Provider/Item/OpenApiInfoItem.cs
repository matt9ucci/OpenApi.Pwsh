namespace OpenApi.Pwsh.Provider.Item;

/// <summary>
/// <see cref="OpenApiInfo"/> as an item.
/// </summary>
internal class OpenApiInfoItem : ItemBase<OpenApiInfo>, IContainer {

	/// <inheritdoc/>
	internal OpenApiInfoItem(string name, OpenApiInfo value) : base(name, value) {
	}

	/// <inheritdoc/>
	public IEnumerable<IItem> GetChildItems() {
		if (Value.Contact is not null) { yield return new OpenApiContactItem("Contact", Value.Contact); }
		if (Value.License is not null) { yield return new OpenApiLicenseItem("License", Value.License); }
	}

	/// <inheritdoc/>
	public void RemoveChildItem(string name) {
		switch (name.ToLower()) {
			case "contact": Value.Contact = null; break;
			case "license": Value.License = null; break;
			default: throw new PSArgumentException($"Cannot remove the child item '{name}'.", nameof(name));
		};
	}

	/// <inheritdoc/>
	public IItem SetChildItem(string name, object value) {
		return name.ToLower() switch {
			"contact" => new OpenApiContactItem(name, Value.Contact = Cast<OpenApiContact>(value)),
			"license" => new OpenApiLicenseItem(name, Value.License = Cast<OpenApiLicense>(value)),
			_ => throw new PSArgumentException($"Cannot set {value.GetType()} as a child item of {Value.GetType()} by name '{name}'."),
		};
	}
}
