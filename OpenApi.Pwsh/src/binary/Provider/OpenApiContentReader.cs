using System.Management.Automation.Provider;
using Microsoft.OpenApi.Extensions;
using OpenApi.Pwsh.Provider.Item;

namespace OpenApi.Pwsh.Provider;

internal class OpenApiContentReader : IContentReader {

	private readonly OpenApiSpecVersion _version;
	private readonly OpenApiFormat _format;
	private readonly OpenApiWriterSettings _writerSettings;

	private readonly StreamReader _reader;

	public OpenApiContentReader(IItem item, OpenApiSpecVersion version, OpenApiFormat format, OpenApiWriterSettings writerSettings) {
		var value = item.Value switch {
			IOpenApiSerializable serializable => serializable,
			_ => throw new PSArgumentException($"The value of the item '{item.Value}' should implement {nameof(IOpenApiSerializable)}.")
		};

		_version = version;
		_format = format;
		_writerSettings = writerSettings;

		MemoryStream stream = new();
		value.Serialize(stream, _version, _format, _writerSettings);
		_reader = new(stream);
		_reader.BaseStream.Position = 0;
	}

	public IList Read(long readCount) {
		List<string> list = new();

		if (readCount < 1) {
			// Read all
			while (_reader.Peek() > -1) {
				list.Add(_reader.ReadLine()!);
			}
		} else {
			for (long i = 0; i < readCount && _reader.Peek() > -1; i++) {
				list.Add(_reader.ReadLine()!);
			}
		}

		return list;
	}

	public void Seek(long offset, SeekOrigin origin) {
		throw new PSNotSupportedException($"Seek({nameof(offset)}: {offset}, {nameof(origin)}: {origin}) will not be invoked.");
	}

	public void Close() {
		_reader.Close();
	}

	public void Dispose() {
		_reader.Dispose();
		GC.SuppressFinalize(this);
	}
}
