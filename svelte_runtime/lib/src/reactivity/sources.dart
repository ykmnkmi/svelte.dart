import 'package:svelte_runtime/src/reactivity/signals.dart';
import 'package:svelte_runtime/src/runtime.dart';

State<T> createState<T>(T value) {
  return pushDerivedSource<T, State<T>>(State<T>(flags: 0, value: value));
}

LateState<T> createLateState<T>() {
  return pushDerivedSource<T, LateState<T>>(LateState<T>(flags: 0));
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
