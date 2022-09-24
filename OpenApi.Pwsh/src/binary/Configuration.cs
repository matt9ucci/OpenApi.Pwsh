namespace OpenApi.Pwsh;

/// <summary>
/// Configuration of OpenApi.Pwsh module.
/// </summary>
public class Configuration {

	static Configuration() {
		Current = new();
	}

	/// <summary>
	/// The configuration in use.
	/// </summary>
	public static Configuration Current { get; set; }

	/// <summary>
	/// The drive name of the OpenApi provider in use.
	/// </summary>
	public string DriveName { get; set; }

	/// <summary>
	/// When <c>true</c>, the module creates an OpenApi drive with the name <see cref="DriveName"/>.
	/// </summary>
	public bool DriveAutoCreation { get; set; }

	/// <summary>
	/// The OpenAPI Specification version of OpenAPI document.
	/// </summary>
	public OpenApiSpecVersion Version { get; set; }

	/// <summary>
	/// The format of OpenAPI document.
	/// </summary>
	public OpenApiFormat Format { get; set; }

	/// <summary>
	/// <see cref="Microsoft.OpenApi.Readers.OpenApiReaderSettings"/>.
	/// </summary>
	public OpenApiReaderSettings OpenApiReaderSettings { get; set; }

	/// <summary>
	/// <see cref="Microsoft.OpenApi.Writers.OpenApiWriterSettings"/>.
	/// </summary>
	public OpenApiWriterSettings OpenApiWriterSettings { get; set; }

	/// <summary>
	/// Default configuration.
	/// </summary>
	public Configuration() {
		DriveName = "OpenApi";
		DriveAutoCreation = true;
		Version = OpenApiSpecVersion.OpenApi3_0;
		Format = OpenApiFormat.Json;
		OpenApiReaderSettings = new OpenApiReaderSettings();
		OpenApiWriterSettings = new OpenApiJsonWriterSettings();
	}
}
