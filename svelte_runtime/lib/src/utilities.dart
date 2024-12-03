typedef VoidFunction = void Function();

const Object undefined = Object();

void noop([Object? _, Object? __]) {
  // ...
}

void run(VoidFunction function) {
  function();
}

void runAll(Iterable<VoidFunction> functions) {
  functions.forEach(run);
}
