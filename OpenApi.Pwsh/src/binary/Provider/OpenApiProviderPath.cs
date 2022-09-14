namespace OpenApi.Pwsh.Provider;

/// <summary>
/// A well-formed path of <see cref="OpenApiProvider"/>.
/// </summary>
internal class OpenApiProviderPath {

	internal string Path { get; }

	internal char Separator { get; }

	/// <summary>
	/// From root to leaf.
	/// </summary>
	internal string[] FullSegments { get; }

	/// <summary>
	/// Without root.
	/// </summary>
	internal string[] Segments => FullSegments.Skip(1).ToArray();

	/// <summary>
	/// Without root and leaf.
	/// </summary>
	internal string[] ContainerSegments => FullSegments.Skip(1).SkipLast(1).ToArray();

	internal string Root => FullSegments[0];
	internal string Leaf => FullSegments.TakeLast(1).Single();

	internal bool IsRoot => Path == Root;

	internal OpenApiProviderPath(string path, char separator) {
		Separator = separator;

		FullSegments = path.Split(Separator, StringSplitOptions.RemoveEmptyEntries);
		if (FullSegments.Length < 1) {
			throw new PSArgumentException(path, nameof(path));
		}

		Path = string.Join(Separator, FullSegments);
	}

	internal OpenApiProviderPath Join(string name) {
		return new(Path + Separator + name, Separator);
	}
}
