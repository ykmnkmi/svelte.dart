import 'package:source_span/source_span.dart';

import '../../ast.dart';
import '../../token/tokens.dart';
import '../../visitor.dart';

/// Represents an annotation `@annotation` on an element.
///
/// This annotation may optionally be assigned a value `@annotation="value"`.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class Annotation implements Template {
  /// Create a new synthetic [Annotation] with a string [name].
  factory Annotation(String name, [String? value]) = _SyntheticAnnotation;

  /// Create a new synthetic [Annotation] that originated from node [origin].
  factory Annotation.from(Template origin, String name, [String? value]) = _SyntheticAnnotation.from;

  /// Create a new [Annotation] parsed from tokens from [sourceFile].
  factory Annotation.parsed(SourceFile sourceFile, NgToken prefixToken, NgToken nameToken,
      [NgAttributeValueToken? valueToken, NgToken? equalSignToken]) = ParsedAnnotation;

  @override
  int get hashCode {
    return Object.hash(name, value);
  }

  /// Static annotation name.
  String get name;

  /// Static annotation value.
  String? get value;

  @override
  bool operator ==(Object? other) {
    return other is Annotation && name == other.name && value == other.value;
  }

  @override
  R accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
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

/// Represents a real(non-synthetic) parsed AnnotationAst. Preserves offsets.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedAnnotation extends Template with Annotation implements ParsedDecorator {
  ParsedAnnotation(SourceFile sourceFile, this.prefixToken, this.nameToken, [this.valueToken, this.equalSignToken])
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

class _SyntheticAnnotation extends SyntheticTemplate with Annotation {
  _SyntheticAnnotation(this.name, [this.value]);

  _SyntheticAnnotation.from(Template origin, this.name, [this.value]) : super.from(origin);

  @override
  final String name;

  @override
  final String? value;
}
