import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

/// Represents the closing DOM element that was parsed.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class CloseElement implements Template {
  /// Creates a synthetic close element AST.
  factory CloseElement(String name) = _SyntheticCloseElementAst;

  /// Creates a synthetic close element AST from an existing AST node.
  factory CloseElement.from(Template origin, String name) = _SyntheticCloseElementAst.from;

  /// Creates a new close element AST from a parsed source.
  factory CloseElement.parsed(SourceFile sourceFile, NgToken closeTagStart, NgToken nameToken, NgToken closeTagEnd,
      {Element? openComplement}) = ParsedCloseElementAst;

  @override
  int get hashCode {
    return name.hashCode;
  }

  /// Whether this is a `</template>` tag and should be directly rendered.
  bool get isEmbeddedTemplate {
    return name == 'template';
  }

  /// Name (tag) of the close element.
  String get name;

  @override
  bool operator ==(Object? other) {
    return other is CloseElement && name == other.name;
  }

  @override
  R accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitCloseElement(this, context);
  }

  @override
  String toString() {
    return 'CloseElementAst </$name>';
  }
}

/// Represents a real, non-synthetic DOM close element that was parsed.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedCloseElementAst extends Template with CloseElement {
  /// [NgToken] that represents the identifier tag in `</tag>`.
  final NgToken identifierToken;

  ParsedCloseElementAst(SourceFile sourceFile, NgToken closeElementStart, this.identifierToken, NgToken closeElementEnd,
      {Element? openComplement})
      : super.parsed(closeElementStart, closeElementEnd, sourceFile);

  @override
  String get name {
    return identifierToken.lexeme;
  }
}

class _SyntheticCloseElementAst extends SyntheticTemplate with CloseElement {
  _SyntheticCloseElementAst(this.name);

  _SyntheticCloseElementAst.from(Template origin, this.name) : super.from(origin);

  @override
  final String name;
}
