using System.Management.Automation.Provider;
using OpenApi.Pwsh.Provider.Item;

namespace OpenApi.Pwsh.Provider;

/// <summary>
/// Provides <see cref="OpenApiDocument"/> objects.
/// </summary>
[CmdletProvider(ProviderName, ProviderCapabilities.None)]
public class OpenApiProvider : NavigationCmdletProvider {

	/// <summary>
	/// The name of the provider.
	/// </summary>
	public const string ProviderName = "OpenApi";

	private OpenApiDriveInfo Drive => PSDriveInfo is OpenApiDriveInfo drive
		? drive
		: throw new PSInvalidCastException();

	#region DriveCmdletProvider overrides

	/// <summary>
	/// Creates a drive with an <see cref="IOpenApiRegistry"/> object.
	/// </summary>
	/// <param name="drive">The source of the new drive.</param>
	/// <returns>The new drive.</returns>
	protected override PSDriveInfo NewDrive(PSDriveInfo drive) {
		var dynParams = DynamicParameters as OpenApiProviderNewDriveDynamicParameters;
		var registry = dynParams?.OpenApiRegistry ?? new OpenApiBasicRegistry();

		var root = string.IsNullOrEmpty(drive.Root) ? registry.GetType().Name : drive.Root;

		return new OpenApiDriveInfo(
			drive.Name,
			drive.Provider,
			root,
			drive.Description,
			drive.Credential,
			registry
		);
	}

	/// <summary>
	/// New-PSDrive cmdlet's dynamic parameters.
	/// </summary>
	protected override object NewDriveDynamicParameters() {
		return new OpenApiProviderNewDriveDynamicParameters();
	}

	private class OpenApiProviderNewDriveDynamicParameters {
		[Parameter]
		public IOpenApiRegistry? OpenApiRegistry { get; init; }
	}

	#endregion

	#region ItemCmdletProvider overrides

	/// <inheritdoc/>
	protected override void GetItem(string path) {
		var providerPath = NewProviderPath(path);
		var item = GetItem(providerPath);

		if (item is NotFound) {
			// Will not be thrown because the item exists when this method is called
			throw new ItemNotFoundException($"Not found: {path}");
		} else {
			WriteItemObject(item.Value, providerPath.Path, item.IsContainer);
		}
	}

	/// <summary>
	/// Not supported.
	/// </summary>
	/// <exception cref="PSNotSupportedException"></exception>
	protected override bool IsValidPath(string path) {
		throw new PSNotSupportedException($"Not supported: IsValidPath({nameof(path)}: \"{path}\")");
	}

	/// <inheritdoc/>
	protected override bool ItemExists(string path) {
		return GetItem(NewProviderPath(path)) is not NotFound;
	}

	/// <inheritdoc/>
	protected override void SetItem(string path, object value) {
		var providerPath = NewProviderPath(path);
		if (providerPath.Segments.Length < 1) {
			throw new PSArgumentException($"Cannot set the item because it is root: path '{path}'.", nameof(path));
		}

		var container = GetContainer(providerPath);

		if (container is NotFound) {
			throw new ItemNotFoundException($"Cannot find the container of the path '{path}'.");
		} else {
			IItem item = container.SetChildItem(providerPath.Leaf, value);
			WriteItemObject(item.Value, providerPath.Path, item.IsContainer);
		}
	}

	#endregion

	private IContainer GetContainer(OpenApiProviderPath path) {
		IContainer container = Drive.GetRootItem();

		foreach (var segment in path.ContainerSegments) {
			if (container.GetChildItem(segment) is IContainer c) {
				container = c;
			} else {
				return new NotFound(segment);
			}
		}

		return container;
	}

	private IItem GetItem(OpenApiProviderPath path) {
		IItem item = Drive.GetRootItem();

		foreach (var segment in path.Segments) {
			if (item is IContainer container) {
				item = container.GetChildItem(segment);
			} else {
				return new NotFound(segment);
			}
		}

		return item;
	}

	private OpenApiProviderPath NewProviderPath(string path) {
		return new(path, ItemSeparator);
	}
}
