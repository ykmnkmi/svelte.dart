import 'package:svelte_runtime/src/reactivity/signals.dart';
import 'package:svelte_runtime/src/runtime.dart';

Source<T> createSource<T>(T value) {
  return pushDerivedSource<T, Source<T>>(source<T>(value));
}

Source<T> source<T>(T value) {
  return Source<T>(flags: 0, value: value);
}

LazySource<T> createLazySource<T>() {
  return pushDerivedSource<T, LazySource<T>>(lazySource<T>());
}

LazySource<T> lazySource<T>() {
  return LazySource<T>(flags: 0);
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
