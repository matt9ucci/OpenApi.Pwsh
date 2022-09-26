namespace OpenApi.Pwsh.Cmdlet;

/// <summary>
/// Import-OpenApiDocument cmdlet.
/// </summary>
[Cmdlet(VerbsData.Import, "OpenApiDocument",
	DefaultParameterSetName = "ByPath"
)]
public class ImportOpenApiDocument : PSCmdlet {

	/// <summary>
	/// Path to the OpenAPI document.
	/// </summary>
	[Parameter(
		Position = 0, ParameterSetName = "ByPath",
		Mandatory = true, ValueFromPipeline = true
	)]
	public string[] Path { get; init; } = Array.Empty<string>();

	/// <summary>
	/// URI of the OpenAPI document.
	/// </summary>
	[Parameter(
		Position = 0, ParameterSetName = "ByUri",
		Mandatory = true, ValueFromPipeline = true
	)]
	public Uri[] Uri { get; init; } = Array.Empty<Uri>();

	/// <summary>
	/// The name which is associated with the OpenAPI document to be imported.
	/// </summary>
	[Parameter(Position = 1)]
	public string OpenApiName { get; init; } = string.Empty;

	/// <summary>
	/// The <see cref="OpenApiReaderSettings"/> which is used to import the OpenAPI document.
	/// </summary>
	[Parameter]
	public OpenApiReaderSettings ReaderSettings { get; init; } = Configuration.Current.OpenApiReaderSettings;

	/// <summary>
	/// Returns the imported OpenAPI document.
	/// </summary>
	[Parameter]
	public SwitchParameter PassThru { get; init; }

	/// <inheritdoc/>
	protected override void BeginProcessing() {
		switch (ParameterSetName) {
			case "ByPath":
				if ((Path.Length > 1) && !string.IsNullOrEmpty(OpenApiName)) {
					throw new PSArgumentException(
						$"Cannot set {nameof(OpenApiName)}: {nameof(Path)}.Length = {Path.Length} > 1",
						nameof(OpenApiName)
					);
				}
				break;
			case "ByUri":
				if (Uri.Length > 1 && !string.IsNullOrEmpty(OpenApiName)) {
					throw new PSArgumentException(
						$"Cannot set {nameof(OpenApiName)}: {nameof(Uri)}.Length = {Uri.Length} > 1",
						nameof(OpenApiName)
					);
				}
				break;
			default: break; // Unreachable
		}
	}

	/// <inheritdoc/>
	protected override void ProcessRecord() {
		switch (ParameterSetName) {
			case "ByPath":
				foreach (var p in Path) {
					using var stream = File.OpenRead(GetUnresolvedProviderPathFromPSPath(p));
					Import(stream, p);
				}
				break;
			case "ByUri":
				foreach (var u in Uri) {
					using var stream = u switch {
						_ when u.IsFile => File.OpenRead(u.LocalPath),
						_ when u.IsAbsoluteUri => new HttpClient().GetStreamAsync(u).Result,
						_ => throw new PSArgumentException($"Unsupported URI '{u}'.", nameof(u))
					};
					Import(stream, u.LocalPath);
				}
				break;
			default: break; // Unreachable
		}

		void Import(Stream stream, string path) {
			var itemName = string.IsNullOrEmpty(OpenApiName) ? System.IO.Path.GetFileNameWithoutExtension(path) : OpenApiName;
			var itemPath = $"{Configuration.Current.DriveName}:{itemName}";
			WriteDebug($"itemPath={itemPath}");

			var doc = new OpenApiStreamReader(ReaderSettings).Read(stream, out var diagnostic);
			WriteDiagnostic(diagnostic);

			var importedItem = InvokeProvider.Item.Set(itemPath, doc).Single();
			if (PassThru) {
				WriteObject(importedItem);
			}
		}

		void WriteDiagnostic(OpenApiDiagnostic diagnostic) {
			WriteVerbose(diagnostic.SpecificationVersion.ToString());

			foreach (var warning in diagnostic.Warnings) {
				WriteWarning(warning.ToString());
			}

			foreach (var error in diagnostic.Errors) {
				WriteError(new(
					new Exception(error.ToString()),
					"OpenApi.Pwsh.InvalidData",
					ErrorCategory.InvalidData,
					null // Avoid setting the OpenAPI document which would be too long
				));
			}
		}
	}
}
