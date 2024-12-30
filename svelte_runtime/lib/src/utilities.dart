typedef VoidFunction = void Function();

final class _Undefined {
  const _Undefined();
}

const Object undefined = _Undefined();

void noop([Object? _, Object? __]) {
  // ...
}

void run(VoidFunction function) {
  function();
}

void runAll(Iterable<VoidFunction> functions) {
  functions.forEach(run);
}
