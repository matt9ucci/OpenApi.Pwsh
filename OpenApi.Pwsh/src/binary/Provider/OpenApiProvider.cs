using System.Management.Automation.Provider;

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

	/// <summary>
	/// Not supported.
	/// </summary>
	/// <exception cref="PSNotSupportedException"></exception>
	protected override bool IsValidPath(string path) {
		throw new PSNotSupportedException($"Not supported: IsValidPath({nameof(path)}: \"{path}\")");
	}

	#endregion
}
