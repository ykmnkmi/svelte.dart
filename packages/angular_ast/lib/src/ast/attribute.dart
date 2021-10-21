import 'package:collection/collection.dart';
import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

const _listEquals = ListEquality<Object?>();

/// Represents a static attribute assignment (i.e. not bound to an expression).
///
/// Clients should not extend, implement, or mix-in this class.
abstract class AttributeAst implements TemplateAst {
  /// Create a new synthetic [AttributeAst] with a string [value].
  factory AttributeAst(String name, [String? value, List<StandaloneTemplateAst> childNodes]) = _SyntheticAttributeAst;

  /// Create a new synthetic [AttributeAst] that originated from node [origin].
  factory AttributeAst.from(TemplateAst origin, String name, [String? value, List<StandaloneTemplateAst> childNodes]) =
      _SyntheticAttributeAst.from;

  /// Create a new [AttributeAst] parsed from tokens from [sourceFile].
  factory AttributeAst.parsed(SourceFile sourceFile, NgToken nameToken,
      [NgAttributeValueToken? valueToken,
      NgToken? equalSignToken,
      List<StandaloneTemplateAst> childNod]) = ParsedAttributeAst;

  @override
  bool operator ==(Object? other) {
    return other is AttributeAst && name == other.name && _listEquals.equals(childNodes, other.childNodes);
  }

  @override
  int get hashCode {
    return Object.hash(name, value);
  }

  /// Static attribute name.
  String get name;

  /// Static attribute value; may be `null` to have no value.
  String? get value;

  /// Static attribute value with quotes attached;
  /// may be `null` to have no value.
  String? get quotedValue;

  /// Mustaches found within value; may be `null` if value is null.
  /// If value exists but has no mustaches, will be empty list.
  @override
  List<StandaloneTemplateAst> get childNodes;

  @override
  R accept<R, C>(TemplateAstVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitAttribute(this, context);
  }

  @override
  String toString() {
    return 'AttributeAst {$name}';
  }
}

/// Represents a real(non-synthetic) parsed AttributeAst. Preserves offsets.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedAttributeAst extends TemplateAst with AttributeAst implements ParsedDecoratorAst, TagOffsetInfo {
  ParsedAttributeAst(SourceFile sourceFile, this.nameToken,
      [this.valueToken, this.equalSignToken, this.childNodes = const <StandaloneTemplateAst>[]])
      : super.parsed(nameToken, valueToken == null ? nameToken : valueToken.rightQuote, sourceFile);

  /// [NgToken] that represents the attribute name.
  @override
  final NgToken nameToken;

  /// [NgAttributeValueToken] that represents the attribute value. May be `null`
  /// to have no value.
  @override
  final NgAttributeValueToken? valueToken;

  /// [NgToken] that represents the equal sign token. May be `null` to have no
  /// value.
  final NgToken? equalSignToken;

  /// Static attribute value offset; may be `null` to have no value.
  @override
  final List<StandaloneTemplateAst> childNodes;

  /// Static attribute name.
  @override
  String get name {
    return nameToken.lexeme;
  }

  /// Static attribute name offset.
  @override
  int get nameOffset {
    return nameToken.offset;
  }

  /// Static offset of equal sign; may be `null` to have no value.
  @override
  int? get equalSignOffset {
    return equalSignToken?.offset;
  }

  /// Static attribute value; may be `null` to have no value.
  @override
  String? get value {
    return valueToken?.innerValue?.lexeme;
  }

  /// Static attribute value offset; may be `null` to have no value.
  @override
  int? get valueOffset {
    return valueToken?.innerValue?.offset;
  }

  /// Static attribute value including quotes; may be `null` to have no value.
  @override
  String? get quotedValue {
    return valueToken?.lexeme;
  }

  /// Static attribute value including quotes offset; may be `null` to have no
  /// value.
  @override
  int? get quotedValueOffset {
    return valueToken?.leftQuote?.offset;
  }

  @override
  NgToken? get prefixToken {
    return null;
  }

  @override
  int? get prefixOffset {
    return null;
  }

  @override
  NgToken? get suffixToken {
    return null;
  }

  @override
  int? get suffixOffset {
    return null;
  }
}

class _SyntheticAttributeAst extends SyntheticTemplateAst with AttributeAst {
  _SyntheticAttributeAst(this.name, [this.value, this.childNodes = const <StandaloneTemplateAst>[]]);

  _SyntheticAttributeAst.from(TemplateAst origin, this.name,
      [this.value, this.childNodes = const <StandaloneTemplateAst>[]])
      : super.from(origin);

  @override
  final String name;

  @override
  final String? value;

  @override
  final List<StandaloneTemplateAst> childNodes;

  @override
  String? get quotedValue => value == null ? null : '"$value"';
}
