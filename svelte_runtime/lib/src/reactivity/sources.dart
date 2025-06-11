import 'package:svelte_runtime/src/reactivity/signals.dart';
import 'package:svelte_runtime/src/runtime.dart';

Source<T> source<T>(T value) {
  return pushDerivedSource<T, Source<T>>(Source<T>(flags: 0, value: value));
}

LazySource<T> lazySource<T>() {
  return pushDerivedSource<T, LazySource<T>>(LazySource<T>(flags: 0));
}

S pushDerivedSource<T, S extends Value<T>>(S source) {
  if (activeReaction is Derived) {
    List<Value>? sources = derivedSources;

    if (sources == null) {
      setDerivedSources(<S>[source]);
    } else {
      sources.add(source);
    }
  }

  return source;
}
