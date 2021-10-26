import 'package:source_span/source_span.dart';

import '../../ast.dart';
import '../../token/tokens.dart';
import '../../visitor.dart';

/// Represents the `[(property)]="value"` syntax.
///
/// This AST may only exist in the parses that do not de-sugar directives (i.e.
/// useful for tooling, but not useful for compilers).
///
/// Clients should not extend, implement, or mix-in this class.
abstract class Banana implements Template {
  /// Create a new synthetic [Banana] with a string [field].
  factory Banana(String name, [String? field]) = _SyntheticBanana;

  /// Create a new synthetic [Banana] that originated from node [origin].
  factory Banana.from(Template origin, String name, [String? field]) = _SyntheticBanana.from;

  /// Create a new [Banana] parsed from tokens from [sourceFile].
  factory Banana.parsed(SourceFile sourceFile, NgToken prefixToken, NgToken elementDecoratorToken,
      NgToken suffixToken, NgAttributeValueToken? valueToken, NgToken? equalSignToken) = ParsedBanana;

  @override
  int get hashCode {
    return Object.hash(name, value);
  }

  /// Name of the property.
  String get name;

  /// Value bound to.
  String? get value;

  @override
  bool operator ==(Object? other) {
    return other is Banana && name == other.name && value == other.value;
  }

  @override
  R accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitBanana(this, context);
  }

  @override
  String toString() {
    return 'BananaAst {$name="$value"}';
  }
}

/// Represents a real, non-synthetic `[(property)]="value"` syntax.
///
/// This AST may only exist in the parses that do not de-sugar directives (i.e.
/// useful for tooling, but not useful for compilers). Preserves offsets.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedBanana extends Template with Banana implements ParsedDecorator, TagOffsetInfo {
  ParsedBanana(
      SourceFile sourceFile, this.prefixToken, this.nameToken, this.suffixToken, this.valueToken, this.equalSignToken)
      : super.parsed(prefixToken, valueToken != null ? valueToken.rightQuote : suffixToken, sourceFile);

  /// Components of element decorator representing [(banana)].
  @override
  final NgToken prefixToken;

  @override
  final NgToken nameToken;

  @override
  final NgToken suffixToken;

  /// [NgAttributeValueToken] that represents `"value"`; may be `null` to have
  /// no value.
  @override
  final NgAttributeValueToken? valueToken;

  /// [NgToken] that represents the equal sign token; may be `null` to have
  /// no value.
  final NgToken? equalSignToken;

  /// Inner name `property` in `[(property)]`.
  @override
  String get name {
    return nameToken.lexeme;
  }

  /// Offset of `property` in `[(property)]`.
  @override
  int get nameOffset {
    return nameToken.offset;
  }

  /// Offset of equal sign; may be `null` to have no value.
  @override
  int? get equalSignOffset {
    return equalSignToken?.offset;
  }

  /// Value bound to banana property; may be `null` to have no value.
  @override
  String? get value {
    return valueToken?.innerValue?.lexeme;
  }

  /// Offset of value; may be `null` to have no value.
  @override
  int? get valueOffset {
    return valueToken?.innerValue?.offset;
  }

  /// Offset of value starting at left quote; may be `null` to have no value.
  @override
  int? get quotedValueOffset {
    return valueToken?.leftQuote?.offset;
  }

  /// Offset of banana prefix `[(`.
  @override
  int get prefixOffset {
    return prefixToken.offset;
  }

  /// Offset of banana suffix `)]`.
  @override
  int get suffixOffset {
    return suffixToken.offset;
  }
}

class _SyntheticBanana extends SyntheticTemplate with Banana {
  _SyntheticBanana(this.name, [this.value]);

  _SyntheticBanana.from(Template origin, this.name, [this.value]) : super.from(origin);

  @override
  final String name;

  @override
  final String? value;
}
