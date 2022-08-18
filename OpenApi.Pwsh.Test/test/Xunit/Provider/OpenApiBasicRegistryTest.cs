namespace OpenApi.Pwsh.Test.Xunit.Provider;

public class OpenApiBasicRegistryTest {

	[Fact]
	public void New_From_Hashtable() {
		Hashtable hashtable = new() {
			{ "Doc1", new OpenApiDocument() },
			{ "Doc2", new OpenApiDocument() }
		};

		OpenApiBasicRegistry registry = new(hashtable);

		foreach (DictionaryEntry entry in hashtable) {
			var name = (string)entry.Key;
			Assert.True(registry.TryGet(name, out var doc));
			Assert.Same(hashtable[name], doc);
		}
	}

	[Fact]
	public void New_From_Invalid_Hashtable_Fails() {
		_ = Assert.Throws<PSArgumentException>(() => new OpenApiBasicRegistry(new() {
			{ 1, new OpenApiDocument() }
		}));

		_ = Assert.Throws<PSArgumentException>(() => new OpenApiBasicRegistry(new() {
			{ "NotDoc", new OpenApiInfo() }
		}));
	}

	[Fact]
	public void Register_Null_Fails() {
		_ = Assert.Throws<PSArgumentNullException>(() => new OpenApiBasicRegistry().Register("Doc", null!));
	}

	[Fact]
	public void TryGet() {
		OpenApiBasicRegistry registry = new();
		OpenApiDocument doc1 = new();
		OpenApiDocument doc2 = new();
		registry.Register("Doc1", doc1);
		registry.Register("Doc2", doc2);

		Assert.True(registry.TryGet("Doc1", out var tryGet1));
		Assert.Same(doc1, tryGet1);

		Assert.True(registry.TryGet("Doc2", out var tryGet2));
		Assert.Same(doc2, tryGet2);
	}

	[Fact]
	public void TryGet_NotFound() {
		Assert.False(new OpenApiBasicRegistry().TryGet("NotFound", out var doc));
		Assert.Null(doc);
	}

	[Fact]
	public void GetNames() {
		OpenApiBasicRegistry registry = new(new() {
			{ "Doc1", new OpenApiDocument() },
			{ "Doc2", new OpenApiDocument() }
		});

		Assert.Equal(new[] { "Doc1", "Doc2" }, registry.GetNames().OrderBy(s => s));
	}

	[Fact]
	public void GetNames_Empty() {
		Assert.Empty(new OpenApiBasicRegistry().GetNames());
	}
}
