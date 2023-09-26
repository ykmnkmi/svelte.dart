typedef VoidFunction = void Function();

void noop() {
  // ...
}

void run(VoidFunction function) {
  function();
}

void runAll(List<VoidFunction> functions) {
  functions.forEach(run);
}
