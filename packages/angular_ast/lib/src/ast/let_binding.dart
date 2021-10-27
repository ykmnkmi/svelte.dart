import 'package:source_span/source_span.dart' show SourceFile;

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

abstract class LetBinding implements Node {
  factory LetBinding(String name, [String value]) = _SyntheticLetBinding;

  factory LetBinding.from(Node? origin, String name, [String value]) = _SyntheticLetBinding.from;

  factory LetBinding.parsed(SourceFile sourceFile, Token prefixToken, Token elementDecoratorToken,
      [AttributeValueToken? valueToken, Token? equalSignToken]) = ParsedLetBinding;

  String get name;

  String? get value;

  @override
  int get hashCode {
    return Object.hash(name, value);
  }

  @override
  bool operator ==(Object? other) {
    return other is LetBinding && name == other.name && value == other.value;
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitLetBinding(this, context);
  }

  @override
  String toString() {
    if (value == null) {
      return 'LetBindingAst {let-$name}';
    }

    return 'LetBindingAst {let-$name="$value"}';
  }
}

class ParsedLetBinding extends Node with LetBinding implements ParsedDecorator, TagOffsetInfo {
  ParsedLetBinding(SourceFile sourceFile, this.prefixToken, this.nameToken, [this.valueToken, this.equalSignToken])
      : super.parsed(prefixToken, valueToken == null ? nameToken : valueToken.rightQuote, sourceFile);

  @override
  final Token prefixToken;

  @override
  final Token nameToken;

  @override
  final AttributeValueToken? valueToken;

  final Token? equalSignToken;

  @override
  int get prefixOffset {
    return prefixToken.offset;
  }

  @override
  String get name {
    return nameToken.lexeme;
  }

  @override
  int get nameOffset {
    return nameToken.offset;
  }

  @override
  int? get equalSignOffset {
    return equalSignToken?.offset;
  }

  @override
  String? get value {
    return valueToken?.innerValue?.lexeme;
  }

  @override
  int? get valueOffset {
    return valueToken?.innerValue?.offset;
  }

  @override
  int? get quotedValueOffset {
    return valueToken?.leftQuote?.offset;
  }

  @override
  Token? get suffixToken {
    return null;
  }

  @override
  int? get suffixOffset {
    return null;
  }
}

class _SyntheticLetBinding extends Synthetic with LetBinding {
  _SyntheticLetBinding(this.name, [this.value]);

  _SyntheticLetBinding.from(Node? origin, this.name, [this.value]) : super.from(origin);

  @override
  final String name;

  @override
  final String? value;
}
