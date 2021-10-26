import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

/// Represents a bound property assignment `[name.postfix.unit]="value"`for an
/// element.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class Property implements Template {
  /// Create a new synthetic [Property] assigned to [name].
  factory Property(String name, [String? value, String? postfix, String? unit]) = _SyntheticProperty;

  /// Create a new synthetic property AST that originated from another AST.
  factory Property.from(Template? origin, String name, [String? value, String? postfix, String? unit]) =
      _SyntheticProperty.from;

  /// Create a new property assignment parsed from tokens in [sourceFile].
  factory Property.parsed(
      SourceFile sourceFile, NgToken prefixToken, NgToken elementDecoratorToken, NgToken? suffixToken,
      [NgAttributeValueToken? valueToken, NgToken? equalSignToken]) = ParsedProperty;

  /// Name of the property being set.
  String get name;

  /// Unquoted value being bound to property.
  String? get value;

  @override
  int get hashCode {
    return Object.hash(name, postfix, unit);
  }

  /// An optional indicator for some properties as a shorthand syntax.
  ///
  /// For example:
  /// ```html
  /// <div [class.foo]="isFoo"></div>
  /// ```
  ///
  /// Means _has class "foo" while "isFoo" evaluates to true_.
  String? get postfix;

  /// An optional indicator the unit coercion before assigning.
  ///
  /// For example:
  /// ```html
  /// <div [style.height.px]="height"></div>
  /// ```
  ///
  /// Means _assign style.height to height plus the "px" suffix_.
  String? get unit;

  @override
  bool operator ==(Object? other) {
    return other is Property && name == other.name && postfix == other.postfix && unit == other.unit;
  }

  @override
  R accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitProperty(this, context);
  }

  @override
  String toString() {
    if (unit != null) {
      return 'PropertyAst {$name.$postfix.$unit}';
    }

    if (postfix != null) {
      return 'PropertyAst {$name.$postfix}';
    }

    return 'PropertyAst {$name}';
  }
}

/// Represents a real, non-synthetic bound property assignment
/// `[name.postfix.unit]="value"`for an element.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedProperty extends Template with Property implements ParsedDecorator, TagOffsetInfo {
  ParsedProperty(SourceFile sourceFile, this.prefixToken, this.nameToken, this.suffixToken,
      [this.valueToken, this.equalSignToken])
      : super.parsed(prefixToken, valueToken == null ? suffixToken : valueToken.rightQuote, sourceFile);

  @override
  final NgToken prefixToken;

  @override
  final NgToken nameToken;

  // [suffixToken] may be null of 'bind-' is used instead of '['.
  @override
  final NgToken? suffixToken;

  /// [NgAttributeValueToken] that represents `"value"`; may be `null` to
  /// have no value.
  @override
  final NgAttributeValueToken? valueToken;

  /// [NgToken] that represents the equal sign token; may be `null` to have no
  /// value.
  final NgToken? equalSignToken;

  String get _nameWithoutBrackets {
    return nameToken.lexeme;
  }

  /// Offset of `[` prefix in `[name.postfix.unit]`.
  @override
  int get prefixOffset {
    return prefixToken.offset;
  }

  /// Name `name` of `[name.postfix.unit]`.
  @override
  String get name {
    return _nameWithoutBrackets.split('.').first;
  }

  /// Offset of name.
  @override
  int get nameOffset {
    return nameToken.offset;
  }

  /// Offset of equal sign; may be `null` if no value.
  @override
  int? get equalSignOffset {
    return equalSignToken?.offset;
  }

  /// Expression value as [String] bound to property; may be `null` if no value.
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

  /// Name `postfix` in `[name.postfix.unit]`; may be `null` to have no value.
  @override
  String? get postfix {
    final split = _nameWithoutBrackets.split('.');
    return split.length > 1 ? split[1] : null;
  }

  /// Name `unit` in `[name.postfix.unit]`; may be `null` to have no value.
  @override
  String? get unit {
    final split = _nameWithoutBrackets.split('.');
    return split.length > 2 ? split[2] : null;

  }

  /// Offset of `]` suffix in `[name.postfix.unit]`.
  @override
  int? get suffixOffset {
    return suffixToken?.offset;
  }
}

class _SyntheticProperty extends SyntheticTemplate with Property {
  _SyntheticProperty(this.name, [this.value, this.postfix, this.unit]);

  _SyntheticProperty.from(Template? origin, this.name, [this.value, this.postfix, this.unit])
      : super.from(origin);

  @override
  final String name;

  @override
  final String? value;

  @override
  final String? postfix;

  @override
  final String? unit;
}
