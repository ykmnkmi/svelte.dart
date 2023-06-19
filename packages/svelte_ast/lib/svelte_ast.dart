import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';

export 'package:svelte_ast/src/ast.dart';
export 'package:svelte_ast/src/errors.dart' show ParseError;
export 'package:svelte_ast/src/parser.dart' show CssMode;

final class SvelteAst {
  SvelteAst({
    required this.html,
    this.style,
  });

  final Node html;

  final Style? style;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'html': html.toJson(),
      if (style case Style style?) 'style': style.toJson(),
    };
  }
}

SvelteAst parse(
  String string, {
  String? fileName,
  Uri? uri,
  CssMode? cssMode,
  bool customElement = false,
}) {
  var Parser(
    :Node html,
    :List<Style> styles,
    :Never Function(ErrorCode errorCode, [int? position]) error,
  ) = Parser(
    string: string.trimRight(),
    fileName: fileName,
    uri: uri,
    cssMode: cssMode,
    customElement: customElement,
  );

  Style? style;

  if (styles.length == 1) {
    style = styles.first;
  } else if (styles.length > 1) {
    error(duplicateStyle, styles[1].start);
  }

  return SvelteAst(
    html: html,
    style: style,
  );
}
