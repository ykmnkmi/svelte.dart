import 'package:source_span/source_span.dart' show SourceFile;

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

abstract class Interpolation implements Standalone {
  factory Interpolation(String value) = _SyntheticInterpolation;

  factory Interpolation.from(Node origin, String value) = _SyntheticInterpolation.from;

  factory Interpolation.parsed(SourceFile sourceFile, Token beginToken, Token valueToken, Token endToken) =
      ParsedInterpolation;

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
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitInterpolation(this, context);
  }

  @override
  String toString() {
    return 'InterpolationAst {$value}';
  }
}

class ParsedInterpolation extends Node with Interpolation {
  ParsedInterpolation(SourceFile sourceFile, Token beginToken, this.valueToken, Token endToken)
      : super.parsed(beginToken, endToken, sourceFile);

  final Token valueToken;

  @override
  String get value => valueToken.lexeme;
}

class _SyntheticInterpolation extends Synthetic with Interpolation {
  _SyntheticInterpolation(this.value);

  _SyntheticInterpolation.from(Node origin, this.value) : super.from(origin);

  @override
  final String value;
}
