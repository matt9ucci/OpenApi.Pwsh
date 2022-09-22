using System.Management.Automation.Provider;
using OpenApi.Pwsh.Provider.Item;

namespace OpenApi.Pwsh.Provider;

internal class OpenApiContentWriter : IContentWriter {

	private readonly IContainer _container;
	private readonly string _name;
	private readonly OpenApiReaderSettings _readerSettings;
	private readonly OpenApiProvider _provider;

	internal OpenApiContentWriter(IContainer container, string name, OpenApiReaderSettings readerSettings, OpenApiProvider provider) {
		_container = container;
		_name = name;
		_readerSettings = readerSettings;
		_provider = provider;
	}

	public IList Write(IList content) {
		// All the elements of the content should be string. If not, throw an exception.
		var contentString = string.Join('\n', content.Cast<string>());

		// Normalize line endings. It is required for OpenApiStringReader.Read() method.
		contentString = contentString.Replace("\r\n", "\n").Replace("\r", "\n");

		// Only OpenApiDocument is supported now. The other models will be supported in the future.
		OpenApiDocument doc = new OpenApiStringReader(_readerSettings).Read(contentString, out var diagnostic);

		_provider.WriteVerbose(diagnostic.SpecificationVersion.ToString());
		foreach (var warning in diagnostic.Warnings) {
			_provider.WriteWarning(warning.ToString());
		}
		foreach (var error in diagnostic.Errors) {
			_provider.WriteError(new(
				new Exception(error.ToString()),
				"OpenApi.Pwsh.InvalidData",
				ErrorCategory.InvalidData,
				null // Avoid setting the content which would be too long
			));
		}

		_ = _container.SetChildItem(_name, doc);

		return content;
	}

	public void Seek(long offset, SeekOrigin origin) {
		throw new PSNotSupportedException($"Seek({nameof(offset)}: {offset}, {nameof(origin)}: {origin}) will not be invoked.");
	}

	public void Close() { }
	public void Dispose() { }
}
