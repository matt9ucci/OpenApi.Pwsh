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

	#endregion

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
