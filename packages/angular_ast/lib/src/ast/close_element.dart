import 'package:source_span/source_span.dart' show SourceFile;

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

abstract class CloseElement implements Node {
  factory CloseElement(String name) = _SyntheticCloseElement;

  factory CloseElement.from(Node origin, String name) = _SyntheticCloseElement.from;

  factory CloseElement.parsed(SourceFile sourceFile, Token closeTagStart, Token nameToken, Token closeTagEnd,
      {Element? openComplement}) = ParsedCloseElement;

  @override
  int get hashCode {
    return name.hashCode;
  }

  bool get isEmbeddedTemplate {
    return name == 'template';
  }

  String get name;

  @override
  bool operator ==(Object? other) {
    return other is CloseElement && name == other.name;
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitCloseElement(this, context);
  }

  @override
  String toString() {
    return 'CloseElementAst </$name>';
  }
}

class ParsedCloseElement extends Node with CloseElement {
  final Token identifierToken;

  ParsedCloseElement(SourceFile sourceFile, Token closeElementStart, this.identifierToken, Token closeElementEnd,
      {Element? openComplement})
      : super.parsed(closeElementStart, closeElementEnd, sourceFile);

  @override
  String get name {
    return identifierToken.lexeme;
  }
}

class _SyntheticCloseElement extends Synthetic with CloseElement {
  _SyntheticCloseElement(this.name);

  _SyntheticCloseElement.from(Node origin, this.name) : super.from(origin);

  @override
  final String name;
}
