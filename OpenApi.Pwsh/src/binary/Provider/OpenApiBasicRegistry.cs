namespace OpenApi.Pwsh.Provider;

/// <summary>
/// A basic implementation of <see cref="IOpenApiRegistry"/>.
/// </summary>
public class OpenApiBasicRegistry : IOpenApiRegistry {

	private readonly Dictionary<string, OpenApiDocument> _docs = new(StringComparer.OrdinalIgnoreCase);

	/// <summary>
	/// Empty registry.
	/// </summary>
	public OpenApiBasicRegistry() {
	}

	/// <summary>
	/// Registers the entries of <paramref name="hashtable"/>.
	/// </summary>
	/// <param name="hashtable">The entries to be registered.</param>
	/// <exception cref="PSArgumentException">
	/// The key of the entry is not a <see cref="string"/> or the value is not an <see cref="OpenApiDocument"/>.
	/// </exception>
	public OpenApiBasicRegistry(Hashtable hashtable) {
		foreach (DictionaryEntry entry in hashtable) {
			if (entry.Key is string name && entry.Value is OpenApiDocument doc) {
				Register(name, doc);
			} else {
				throw new PSArgumentException(
					$"Cannot accept the entry <{entry.Key.GetType()}, {entry.Value?.GetType()}>. It should be <{typeof(string)}, {typeof(OpenApiDocument)}>.",
					nameof(hashtable)
				);
			}
		}
	}

	/// <inheritdoc/>
	public IEnumerable<string> GetNames() {
		return _docs.Keys;
	}

	/// <inheritdoc/>
	public void Register(string name, OpenApiDocument doc) {
		if (doc is null) {
			throw new PSArgumentNullException(nameof(doc));
		}

		_docs[name] = doc;
	}

	/// <inheritdoc/>
	public bool TryGet(string name, out OpenApiDocument doc) {
		return _docs.TryGetValue(name, out doc!);
	}
}
