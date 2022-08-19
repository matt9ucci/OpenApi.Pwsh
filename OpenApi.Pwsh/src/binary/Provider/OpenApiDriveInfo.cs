using OpenApi.Pwsh.Provider.Item;

namespace OpenApi.Pwsh.Provider;

/// <summary>
/// PSDrive for <see cref="OpenApiProvider"/>.
/// </summary>
internal class OpenApiDriveInfo : PSDriveInfo {

	private readonly IOpenApiRegistry _registry;

	internal OpenApiDriveInfo(
		string name,
		ProviderInfo provider,
		string root,
		string description,
		PSCredential credential,
		IOpenApiRegistry registry
	) : base(name, provider, root, description, credential) {
		_registry = registry;
	}

	/// <summary>
	/// Gets the root as an <see cref="IContainer"/>, which is derived from <see cref="IItem"/>.
	/// </summary>
	/// <returns>The root.</returns>
	internal IContainer GetRootItem() {
		return new OpenApiRegistryItem(Root, _registry);
	}
}
