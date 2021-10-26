import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

/// Represents a block of static text (i.e. not bound to a directive).
///
/// Clients should not extend, implement, or mix-in this class.
abstract class Text implements StandaloneTemplate {
  /// Create a new synthetic [Text] with a string [value].
  factory Text(String value) = _SyntheticText;

  /// Create a new synthetic [Text] that originated from node [origin].
  factory Text.from(Template origin, String value) = _SyntheticText.from;

  /// Create a new [Text] parsed from tokens from [sourceFile].
  factory Text.parsed(SourceFile sourceFile, NgToken textToken) = _ParsedText;

  /// Static text value.
  String get value;

  @override
  int get hashCode {
    return value.hashCode;
  }

  @override
  bool operator ==(Object? other) {
    return other is Text && value == other.value;
  }

  @override
  R accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitText(this, context);
  }

  @override
  String toString() {
    return 'TextAst {$value}';
  }
}

class _ParsedText extends Template with Text {
  _ParsedText(SourceFile sourceFile, NgToken textToken) : super.parsed(textToken, textToken, sourceFile);

  @override
  String get value {
    return beginToken!.lexeme;
  }
}

class _SyntheticText extends SyntheticTemplate with Text {
  _SyntheticText(this.value);

  _SyntheticText.from(Template origin, this.value) : super.from(origin);

  @override
  final String value;
}
