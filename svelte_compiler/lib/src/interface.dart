import 'package:svelte_compiler/src/css_mode.dart';
import 'package:svelte_compiler/src/generate_mode.dart';
import 'package:svelte_compiler/src/utils/namespaces.dart';

typedef CssHash = String Function(String css);

typedef GetCssHash = String Function(
  String name,
  String? fileName,
  String css,
  CssHash hash,
);

class CompileOptions {
  static const CompileOptions defaultOptions = CompileOptions();

  const CompileOptions({
    this.name,
    this.fileName,
    this.uri,
    this.generateMode = GenerateMode.dom,
    this.enableSourceMap = true,
    this.debug = false,
    this.accessors = false,
    this.immutable = false,
    this.preserveWhitespace = false,
    this.tag,
    this.cssMode = CssMode.injected,
    this.namespace,
    this.cssHash,
  });

  final String? name;

  final String? fileName;

  final Uri? uri;

  final GenerateMode generateMode;

  final bool enableSourceMap;

  final bool debug;

  final bool accessors;

  final bool immutable;

  final bool preserveWhitespace;

  final String? tag;

  final CssMode cssMode;

  final Namespace? namespace;

  final GetCssHash? cssHash;
}

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
