import 'package:svelte_ast/svelte_ast.dart' hide Visitor;
import 'package:svelte_compiler/src/component.dart';
import 'package:svelte_compiler/src/interface.dart';
import 'package:svelte_compiler/src/utils/hash.dart';

String getDefaultCSSHash(
  String name,
  String? fileName,
  String css,
  CssHash hash,
) {
  return 'svelte-${hash(css)}';
}

final class StyleSheet {
  factory StyleSheet.hash({
    required SvelteAst ast,
    required String source,
    String? fileName,
    required String componentName,
    bool debug = false,
    GetCssHash? getCssHash,
  }) {
    bool hasStyles;
    String? id;

    if (ast.style case Style style? when style.topLevels.isNotEmpty) {
      hasStyles = true;

      getCssHash ??= getDefaultCSSHash;
      id = getCssHash(componentName, fileName, style.content.data, hash);
      // TODO(stylesheet): visit
    } else {
      hasStyles = false;
    }

    return StyleSheet(
      ast: ast,
      source: source,
      fileName: fileName,
      componentName: componentName,
      debug: debug,
      hasStyles: hasStyles,
      id: id,
    );
  }

  StyleSheet({
    required this.ast,
    required this.source,
    this.fileName,
    required this.componentName,
    this.debug = false,
    required this.hasStyles,
    required this.id,
  });

  final SvelteAst ast;

  final String source;

  final String? fileName;

  final String componentName;

  final bool debug;

  final bool hasStyles;

  final String? id;

  void validate(Component component) {
    // TODO(stylesheet): validate
  }
}
