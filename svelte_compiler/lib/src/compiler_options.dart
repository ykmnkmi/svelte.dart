import 'package:svelte_compiler/src/css_mode.dart';
import 'package:svelte_compiler/src/generate_mode.dart';

class CompilerOptions {
  static const CompilerOptions defaultOptions = CompilerOptions();

  const CompilerOptions({
    this.name,
    this.fileName,
    this.uri,
    this.generateMode = GenerateMode.dom,
    this.debug = false,
    this.sourceMap = true,
    this.cssMode = CssMode.injected,
  });

  final String? name;

  final String? fileName;

  final Uri? uri;

  final GenerateMode generateMode;

  final bool debug;

  final bool sourceMap;

  final CssMode cssMode;

  CompilerOptions copyWith({
    String? name,
    String? fileName,
    GenerateMode? generateMode,
    bool? debug,
    bool? sourceMap,
    CssMode? cssMode,
  }) {
    return CompilerOptions(
      name: name ?? this.name,
      fileName: fileName ?? this.fileName,
      generateMode: generateMode ?? this.generateMode,
      debug: debug ?? this.debug,
      sourceMap: sourceMap ?? this.sourceMap,
      cssMode: cssMode ?? this.cssMode,
    );
  }
}
