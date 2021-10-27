import 'package:collection/collection.dart' show ListEquality;
import 'package:source_span/source_span.dart' show SourceFile;

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

const ListEquality<Object?> _listEquals = ListEquality<Object?>();

abstract class Event implements Node {
  factory Event(String name, String? value, [List<String> reductions]) = _SyntheticEvent;

  factory Event.from(Node origin, String name, String? value, [List<String> reductions]) = _SyntheticEvent.from;

  factory Event.parsed(SourceFile sourceFile, Token prefixToken, Token elementDecoratorToken, Token? suffixToken,
      [AttributeValueToken? valueToken, Token? equalSignToken]) = ParsedEvent;

  String get name;

  String? get value;

  List<String> get reductions;

  @override
  int get hashCode {
    return Object.hash(name, reductions);
  }

  @override
  bool operator ==(Object? other) {
    return other is Event && name == other.name && _listEquals.equals(reductions, other.reductions);
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitEvent(this, context);
  }

  @override
  String toString() {
    if (reductions.isEmpty) {
      return 'EventAst {$name=$value}';
    }

    return 'EventAst {$name.${reductions.join(',')}="$value"}';
  }
}

class ParsedEvent extends Node with Event implements ParsedDecorator, TagOffsetInfo {
  ParsedEvent(SourceFile sourceFile, this.prefixToken, this.nameToken, this.suffixToken,
      [this.valueToken, this.equalSignToken])
      : super.parsed(prefixToken, valueToken == null ? suffixToken : valueToken.rightQuote, sourceFile);

  @override
  final Token prefixToken;

  @override
  final Token nameToken;

  // [suffixToken] may be null if 'on-' is used instead of '('.
  @override
  final Token? suffixToken;

  @override
  final AttributeValueToken? valueToken;

  final Token? equalSignToken;

  String get _nameWithoutParentheses {
    return nameToken.lexeme;
  }

  @override
  String get name {
    return _nameWithoutParentheses.split('.').first;
  }

  @override
  int get nameOffset {
    return nameToken.offset;
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
  int? get equalSignOffset {
    return equalSignToken?.offset;
  }

  @override
  int get prefixOffset {
    return prefixToken.offset;
  }

  @override
  int? get suffixOffset => suffixToken?.offset;

  @override
  List<String> get reductions => _nameWithoutParentheses.split('.').sublist(1);
}

class _SyntheticEvent extends Synthetic with Event {
  @override
  final String name;

  @override
  final String? value;

  @override
  final List<String> reductions;

  _SyntheticEvent(this.name, this.value, [this.reductions = const []]);

  _SyntheticEvent.from(Node origin, this.name, this.value, [this.reductions = const []]) : super.from(origin);
}
