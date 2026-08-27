/// Qualifies a dependency with an explicit instance tag / string token for injection.
class Inject {
  /// The registration tag or string token.
  final String tag;

  /// Creates an [@Inject] annotation with a string tag / token.
  const Inject(this.tag);
}

/// Marks a parameter of a factory constructor to be passed at resolution runtime.
class FactoryParam {
  const FactoryParam();
}

/// Constant instance for [@factoryParam] annotation.
const factoryParam = FactoryParam();

/// Marks a method to be called when disposing of an instance.
class DisposeMethod {
  const DisposeMethod();
}

/// Constant instance for [@disposeMethod] annotation.
const disposeMethod = DisposeMethod();

/// Marks a method to be executed immediately after the instance is created.
class PostLocalInit {
  const PostLocalInit();
}

/// Constant instance for [@postLocalInit] annotation.
const postLocalInit = PostLocalInit();
