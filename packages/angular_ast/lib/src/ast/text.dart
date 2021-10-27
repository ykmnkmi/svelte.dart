import 'package:source_span/source_span.dart' show SourceFile;

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

abstract class Text implements Standalone {
  factory Text(String value) = _SyntheticText;

  factory Text.from(Node origin, String value) = _SyntheticText.from;

  factory Text.parsed(SourceFile sourceFile, Token textToken) = _ParsedText;

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
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitText(this, context);
  }

  @override
  String toString() {
    return 'TextAst {$value}';
  }
}

class _ParsedText extends Node with Text {
  _ParsedText(SourceFile sourceFile, Token textToken) : super.parsed(textToken, textToken, sourceFile);

  @override
  String get value {
    return beginToken!.lexeme;
  }
}

class _SyntheticText extends Synthetic with Text {
  _SyntheticText(this.value);

  _SyntheticText.from(Node origin, this.value) : super.from(origin);

  @override
  final String value;
}
