namespace OpenApi.Pwsh.Provider;

/// <summary>
/// Represents a registry for OpenAPI definitions (<see cref="OpenApiDocument"/> objects).
/// </summary>
public interface IOpenApiRegistry {

	/// <summary>
	/// Gets OpenAPI names.
	/// </summary>
	/// <returns>OpenAPI names</returns>
	IEnumerable<string> GetNames();

	/// <summary>
	/// Creates or replaces the OpenAPI definition.
	/// </summary>
	/// <param name="name">The OpenAPI name.</param>
	/// <param name="doc">The OpenAPI definition.</param>
	/// <exception cref="PSArgumentNullException"><paramref name="doc"/> is null.</exception>
	void Register(string name, OpenApiDocument doc);

	/// <summary>
	/// Gets the OpenAPI definition by name.
	/// </summary>
	/// <param name="name">The OpenAPI name.</param>
	/// <param name="doc">The OpenAPI definition.</param>
	/// <returns><code>true</code> if it is registered.</returns>
	bool TryGet(string name, out OpenApiDocument doc);
}
