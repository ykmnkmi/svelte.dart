import 'package:svelte_compiler/src/utils/namespaces.dart';

class ComponentOptions {
  static const ComponentOptions defaultOptions = ComponentOptions();

  const ComponentOptions({
    this.accessors = false,
    this.immutable = false,
    this.preserveWhitespace = false,
    this.tag,
    this.namespace,
  });

  final bool accessors;

  final bool immutable;

  final bool preserveWhitespace;

  final String? tag;

  final Namespace? namespace;
}
