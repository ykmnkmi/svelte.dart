import 'package:source_span/source_span.dart' show SourceFile;

import '../../ast.dart';
import '../../token/tokens.dart';
import '../../visitor.dart';

abstract class Annotation implements Node {
  factory Annotation(String name, [String? value]) = _SyntheticAnnotation;

  factory Annotation.from(Node origin, String name, [String? value]) = _SyntheticAnnotation.from;

  factory Annotation.parsed(SourceFile sourceFile, Token prefixToken, Token nameToken,
      [AttributeValueToken? valueToken, Token? equalSignToken]) = ParsedAnnotation;

  @override
  int get hashCode {
    return Object.hash(name, value);
  }

  String get name;

  String? get value;

  @override
  bool operator ==(Object? other) {
    return other is Annotation && name == other.name && value == other.value;
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitAnnotation(this, context);
  }

  @override
  String toString() {
    if (value == null) {
      return 'AnnotationAst {$name}';
    }

    return 'AnnotationAst {$name="$value"}';
  }
}

class ParsedAnnotation extends Node with Annotation implements ParsedDecorator {
  ParsedAnnotation(SourceFile sourceFile, this.prefixToken, this.nameToken, [this.valueToken, this.equalSignToken])
      : super.parsed(prefixToken, valueToken != null ? valueToken.rightQuote : nameToken, sourceFile);

  @override
  final Token prefixToken;

  @override
  final Token nameToken;

  @override
  final AttributeValueToken? valueToken;

  final Token? equalSignToken;

  @override
  String get name {
    return nameToken.lexeme;
  }

  @override
  String? get value {
    return valueToken?.innerValue?.lexeme;
  }

  @override
  int get prefixOffset {
    return prefixToken.offset;
  }

  @override
  Token? get suffixToken {
    return null;
  }

  @override
  int? get suffixOffset {
    return null;
  }
}

class _SyntheticAnnotation extends Synthetic with Annotation {
  _SyntheticAnnotation(this.name, [this.value]);

  _SyntheticAnnotation.from(Node origin, this.name, [this.value]) : super.from(origin);

  @override
  final String name;

  @override
  final String? value;
}
