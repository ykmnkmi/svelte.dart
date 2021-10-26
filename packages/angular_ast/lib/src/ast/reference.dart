import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

/// Represents a reference to an element or exported directive instance.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class Reference implements Template {
  /// Create a new synthetic reference of [variable].
  factory Reference(String variable, [String identifier]) = _SyntheticReference;

  /// Create a new synthetic reference of [variable] from AST node [origin].
  factory Reference.from(Template origin, String variable, [String identifier]) = _SyntheticReference.from;

  /// Create new reference from tokens in [sourceFile].
  factory Reference.parsed(SourceFile sourceFile, NgToken prefixToken, NgToken elementDecoratorToken,
      [NgAttributeValueToken? valueToken, NgToken? equalSignToken]) = ParsedReference;

  /// What `exportAs` identifier to assign to [variable].
  ///
  /// If not set (i.e. `null`), the reference is the raw DOM element.
  String? get identifier;

  /// Local variable name being assigned.
  String get variable;

  @override
  int get hashCode => Object.hash(identifier, variable);

  @override
  bool operator ==(Object? other) {
    return other is Reference && identifier == other.identifier && variable == other.variable;
  }

  @override
  R accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
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

/// Represents a real, non-synthetic reference to an element or exported
/// directive instance.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedReference extends Template with Reference implements ParsedDecorator, TagOffsetInfo {
  ParsedReference(SourceFile sourceFile, this.prefixToken, this.nameToken, [this.valueToken, this.equalSignToken])
      : super.parsed(prefixToken, valueToken != null ? valueToken.rightQuote : nameToken, sourceFile);

  /// Tokens representing the `#reference` element decorator
  @override
  final NgToken prefixToken;

  @override
  final NgToken nameToken;

  /// [NgAttributeValueToken] that represents `identifier` in
  /// `#variable="reference"`.
  @override
  final NgAttributeValueToken? valueToken;

  /// [NgToken] that represents the equal sign token; may be `null` to have no
  /// value.
  final NgToken? equalSignToken;

  /// Offset of `variable` in `#variable="identifier"`.
  @override
  int get nameOffset => nameToken.offset;

  /// Offset of equal sign; may be `null` if no value.
  @override
  int? get equalSignOffset => equalSignToken?.offset;

  /// Offset of `identifier` in `#variable="identifier"`; may be `null` if no
  /// value.
  @override
  int? get valueOffset => valueToken?.innerValue?.offset;

  /// Offset of `identifier` starting at left quote; may be `null` if no value.
  @override
  int? get quotedValueOffset => valueToken?.leftQuote?.offset;

  /// Offset of `#` in `#variable`.
  @override
  int get prefixOffset => nameToken.offset;

  @override
  NgToken? get suffixToken => null;

  /// Always returns `null` since `#ref` has no suffix.
  @override
  int? get suffixOffset => null;

  /// Name `identifier` in `#variable="identifier"`.
  @override
  String? get identifier => valueToken?.innerValue?.lexeme;

  /// Name `variable` in `#variable="identifier"`.
  @override
  String get variable => nameToken.lexeme;
}

class _SyntheticReference extends SyntheticTemplate with Reference {
  _SyntheticReference(this.variable, [this.identifier]);

  _SyntheticReference.from(Template origin, this.variable, [this.identifier]) : super.from(origin);

  @override
  final String? identifier;

  @override
  final String variable;
}
