import 'package:source_span/source_span.dart' show SourceFile;

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

abstract class Reference implements Node {
  factory Reference(String variable, [String identifier]) = _SyntheticReference;

  factory Reference.from(Node origin, String variable, [String identifier]) = _SyntheticReference.from;

  factory Reference.parsed(SourceFile sourceFile, Token prefixToken, Token elementDecoratorToken,
      [AttributeValueToken? valueToken, Token? equalSignToken]) = ParsedReference;

  String? get identifier;

  String get variable;

  @override
  int get hashCode => Object.hash(identifier, variable);

  @override
  bool operator ==(Object? other) {
    return other is Reference && identifier == other.identifier && variable == other.variable;
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitReference(this, context);
  }

  @override
  String toString() {
    if (identifier != null) {
      return 'ReferenceAst {#$variable="$identifier"}';
    }

    return 'ReferenceAst {#$variable}';
  }
}

class ParsedReference extends Node with Reference implements ParsedDecorator, TagOffsetInfo {
  ParsedReference(SourceFile sourceFile, this.prefixToken, this.nameToken, [this.valueToken, this.equalSignToken])
      : super.parsed(prefixToken, valueToken != null ? valueToken.rightQuote : nameToken, sourceFile);

  @override
  final Token prefixToken;

  @override
  final Token nameToken;

  @override
  final AttributeValueToken? valueToken;

  final Token? equalSignToken;

  @override
  int get nameOffset => nameToken.offset;

  @override
  int? get equalSignOffset => equalSignToken?.offset;

  @override
  int? get valueOffset => valueToken?.innerValue?.offset;

  @override
  int? get quotedValueOffset => valueToken?.leftQuote?.offset;

  @override
  int get prefixOffset => nameToken.offset;

  @override
  Token? get suffixToken => null;

  @override
  int? get suffixOffset => null;

  @override
  String? get identifier => valueToken?.innerValue?.lexeme;

  @override
  String get variable => nameToken.lexeme;
}

class _SyntheticReference extends Synthetic with Reference {
  _SyntheticReference(this.variable, [this.identifier]);

  _SyntheticReference.from(Node origin, this.variable, [this.identifier]) : super.from(origin);

  @override
  final String? identifier;

  @override
  final String variable;
}
