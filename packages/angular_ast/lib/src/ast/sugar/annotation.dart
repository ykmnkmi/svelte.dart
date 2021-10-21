import 'package:source_span/source_span.dart';

import '../../ast.dart';
import '../../token/tokens.dart';
import '../../visitor.dart';

/// Represents an annotation `@annotation` on an element.
///
/// This annotation may optionally be assigned a value `@annotation="value"`.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class AnnotationAst implements TemplateAst {
  /// Create a new synthetic [AnnotationAst] with a string [name].
  factory AnnotationAst(String name, [String? value]) = _SyntheticAnnotationAst;

  /// Create a new synthetic [AnnotationAst] that originated from node [origin].
  factory AnnotationAst.from(TemplateAst origin, String name, [String? value]) = _SyntheticAnnotationAst.from;

  /// Create a new [AnnotationAst] parsed from tokens from [sourceFile].
  factory AnnotationAst.parsed(SourceFile sourceFile, NgToken prefixToken, NgToken nameToken,
      [NgAttributeValueToken? valueToken, NgToken? equalSignToken]) = ParsedAnnotationAst;

  @override
  bool operator ==(Object? other) {
    return other is AnnotationAst && name == other.name && value == other.value;
  }

  @override
  int get hashCode {
    return Object.hash(name, value);
  }

  /// Static annotation name.
  String get name;

  /// Static annotation value.
  String? get value;

  @override
  R accept<R, C>(TemplateAstVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitAnnotation(this, context);
  }

  @override
  String toString() {
    return value != null ? 'AnnotationAst {$name="$value"}' : 'AnnotationAst {$name}';
  }
}

/// Represents a real(non-synthetic) parsed AnnotationAst. Preserves offsets.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedAnnotationAst extends TemplateAst with AnnotationAst implements ParsedDecoratorAst {
  ParsedAnnotationAst(SourceFile sourceFile, this.prefixToken, this.nameToken, [this.valueToken, this.equalSignToken])
      : super.parsed(prefixToken, valueToken != null ? valueToken.rightQuote : nameToken, sourceFile);

  @override
  final NgToken prefixToken;

  /// [NgToken] that represents the annotation name.
  @override
  final NgToken nameToken;

  @override
  final NgAttributeValueToken? valueToken;

  /// Represents the equal sign token between the annotation name and value.
  ///
  /// May be `null` if the annotation has no value.
  final NgToken? equalSignToken;

  @override
  String get name {
    return nameToken.lexeme;
  }

  @override
  String? get value {
    return valueToken?.innerValue?.lexeme;
  }

  /// Offset of annotation prefix `@`.
  @override
  int get prefixOffset {
    return prefixToken.offset;
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

class _SyntheticAnnotationAst extends SyntheticTemplateAst with AnnotationAst {
  _SyntheticAnnotationAst(this.name, [this.value]);

  _SyntheticAnnotationAst.from(TemplateAst origin, this.name, [this.value]) : super.from(origin);

  @override
  final String name;

  @override
  final String? value;
}
