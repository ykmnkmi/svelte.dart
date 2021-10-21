import 'package:source_span/source_span.dart';

import '../../ast.dart';
import '../../token/tokens.dart';
import '../../visitor.dart';

/// Represents the sugared form of `*directive="value"`.
///
/// This AST may only exist in the parses that do not de-sugar directives (i.e.
/// useful for tooling, but not useful for compilers).
///
/// Clients should not extend, implement, or mix-in this class.
abstract class StarAst implements TemplateAst {
  /// Create a new synthetic [StarAst] assigned to [name].
  factory StarAst(String name, [String? value]) = _SyntheticStarAst;

  /// Create a new synthetic property AST that originated from another AST.
  factory StarAst.from(TemplateAst origin, String name, [String? value]) = _SyntheticStarAst.from;

  /// Create a new property assignment parsed from tokens in [sourceFile].
  factory StarAst.parsed(SourceFile sourceFile, NgToken prefixToken, NgToken elementDecoratorToken,
      [NgAttributeValueToken? valueToken, NgToken? equalSignToken]) = ParsedStarAst;

  @override
  bool operator ==(Object? other) {
    return other is PropertyAst && value == other.value && name == other.name;
  }

  @override
  int get hashCode {
    return Object.hash(value, name);
  }

  /// Name of the directive being created.
  String get name;

  /// Name of expression string. Can be null.
  String? get value;

  @override
  R accept<R, C>(TemplateAstVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitStar(this, context);
  }

  @override
  String toString() {
    return value != null ? 'StarAst {$name="$value"}' : 'StarAst {$name}';
  }
}

/// Represents a real, non-synthetic sugared form of `*directive="value"`.
///
/// This AST may only exist in the parses that do not de-sugar directives (i.e.
/// useful for tooling, but not useful for compilers). Preserves offsets.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedStarAst extends TemplateAst with StarAst implements ParsedDecoratorAst, TagOffsetInfo {
  ParsedStarAst(SourceFile sourceFile, this.prefixToken, this.nameToken, [this.valueToken, this.equalSignToken])
      : super.parsed(prefixToken, valueToken != null ? valueToken.rightQuote : nameToken, sourceFile);

  @override
  final NgToken prefixToken;

  @override
  final NgToken nameToken;

  @override
  NgToken? get suffixToken => null;

  /// [NgAttributeValueToken] that represents `"value"`; may be `null` to have
  /// no value.
  @override
  final NgAttributeValueToken? valueToken;

  /// [NgToken] that represents the equal sign token; may be `null` to have no
  /// value.
  final NgToken? equalSignToken;

  /// Name `directive` in `*directive`.
  @override
  String get name {
    return nameToken.lexeme;
  }

  /// Offset of `directive` in `*directive`.
  @override
  int get nameOffset {
    return nameToken.offset;
  }

  /// Offset of equal sign; may be `null` to have no value.
  @override
  int? get equalSignOffset {
    return equalSignToken?.offset;
  }

  /// Value bound to `*directive`; may be `null` to have no value.
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

  /// Offset of template prefix `*`.
  @override
  int get prefixOffset {
    return prefixToken.offset;
  }

  /// Always returns `null` since `*directive` has no suffix.
  @override
  int? get suffixOffset {
    return null;
  }
}

class _SyntheticStarAst extends SyntheticTemplateAst with StarAst {
  _SyntheticStarAst(this.name, [this.value]);

  _SyntheticStarAst.from(TemplateAst origin, this.name, [this.value]) : super.from(origin);

  @override
  final String name;

  @override
  final String? value;
}
