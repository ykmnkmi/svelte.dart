import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

/// Represents a bound text element to an expression.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class Interpolation implements StandaloneTemplate {
  /// Create a new synthetic [Interpolation] with a bound [expression].
  factory Interpolation(String value) = _SyntheticInterpolation;

  /// Create a new synthetic [Interpolation] that originated from [origin].
  factory Interpolation.from(Template origin, String value) = _SyntheticInterpolation.from;

  /// Create a new [Interpolation] parsed from tokens in [sourceFile].
  factory Interpolation.parsed(SourceFile sourceFile, NgToken beginToken, NgToken valueToken, NgToken endToken) =
      ParsedInterpolation;

  /// Bound String value used in expression; used to preserve offsets
  String get value;

  @override
  int get hashCode {
    return value.hashCode;
  }

  @override
  bool operator ==(Object? other) {
    return other is Interpolation && other.value == value;
  }

  @override
  R accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitInterpolation(this, context);
  }

  @override
  String toString() {
    return 'InterpolationAst {$value}';
  }
}

class ParsedInterpolation extends Template with Interpolation {
  ParsedInterpolation(SourceFile sourceFile, NgToken beginToken, this.valueToken, NgToken endToken)
      : super.parsed(beginToken, endToken, sourceFile);

  final NgToken valueToken;

  @override
  String get value => valueToken.lexeme;
}

class _SyntheticInterpolation extends SyntheticTemplate with Interpolation {
  _SyntheticInterpolation(this.value);

  _SyntheticInterpolation.from(Template origin, this.value) : super.from(origin);

  @override
  final String value;
}
