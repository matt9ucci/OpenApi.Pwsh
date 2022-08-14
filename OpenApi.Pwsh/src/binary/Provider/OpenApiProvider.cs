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
