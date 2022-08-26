namespace OpenApi.Pwsh.Provider.Item;

/// <summary>
/// <see cref="OpenApiLicense"/> as an item.
/// </summary>
internal class OpenApiLicenseItem : ItemBase<OpenApiLicense> {

	/// <inheritdoc/>
	internal OpenApiLicenseItem(string name, OpenApiLicense value) : base(name, value) {
	}
}
