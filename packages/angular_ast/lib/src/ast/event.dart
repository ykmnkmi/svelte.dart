import 'package:collection/collection.dart';
import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

const ListEquality<Object?> _listEquals = ListEquality<Object?>();

/// Represents an event listener `(eventName.reductions)="expression"` on an
/// element.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class Event implements Template {
  /// Create a new synthetic [Event] listening to [name].
  factory Event(String name, String? value, [List<String> reductions]) = _SyntheticEvent;

  /// Create a new synthetic [Event] that originated from [origin].
  factory Event.from(Template origin, String name, String? value, [List<String> reductions]) =
      _SyntheticEvent.from;

  /// Create a new [Event] parsed from tokens in [sourceFile].
  factory Event.parsed(
      SourceFile sourceFile, NgToken prefixToken, NgToken elementDecoratorToken, NgToken? suffixToken,
      [NgAttributeValueToken? valueToken, NgToken? equalSignToken]) = ParsedEvent;

  /// Name of the event being listened to.
  String get name;

  /// Unquoted value being bound to event.
  String? get value;

  /// An optional list of postfixes used to filter events that support it.
  ///
  /// For example `(keydown.ctrl.space)`.
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
  R accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
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

/// Represents a real, non-synthetic event listener `(event)="expression"`
/// on an element.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedEvent extends Template with Event implements ParsedDecorator, TagOffsetInfo {
  ParsedEvent(SourceFile sourceFile, this.prefixToken, this.nameToken, this.suffixToken,
      [this.valueToken, this.equalSignToken])
      : super.parsed(prefixToken, valueToken == null ? suffixToken : valueToken.rightQuote, sourceFile);

  @override
  final NgToken prefixToken;

  @override
  final NgToken nameToken;

  // [suffixToken] may be null if 'on-' is used instead of '('.
  @override
  final NgToken? suffixToken;

  /// [NgAttributeValueToken] that represents `"expression"`; may be `null` to
  /// have no value.
  @override
  final NgAttributeValueToken? valueToken;

  /// [NgToken] that represents the equal sign token; may be `null` to have no
  /// value.
  final NgToken? equalSignToken;

  String get _nameWithoutParentheses {
    return nameToken.lexeme;
  }

  /// Name `eventName` in `(eventName.reductions)`.
  @override
  String get name {
    return _nameWithoutParentheses.split('.').first;
  }

  /// Offset of name.
  @override
  int get nameOffset {
    return nameToken.offset;
  }

  /// Expression value as [String] bound to event; may be `null` if no value.
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

  /// Offset of equal sign; may be `null` if no value.
  @override
  int? get equalSignOffset {
    return equalSignToken?.offset;
  }

  /// Offset of `(` prefix in `(eventName.reductions)`.
  @override
  int get prefixOffset {
    return prefixToken.offset;
  }

  /// Offset of `)` suffix in `(eventName.reductions)`.
  @override
  int? get suffixOffset => suffixToken?.offset;

  /// Name `reductions` in `(eventName.ctrl.shift.a)`; may be empty.
  @override
  List<String> get reductions => _nameWithoutParentheses.split('.').sublist(1);
}

class _SyntheticEvent extends SyntheticTemplate with Event {
  @override
  final String name;

  @override
  final String? value;

  @override
  final List<String> reductions;

  _SyntheticEvent(this.name, this.value, [this.reductions = const []]);

  _SyntheticEvent.from(Template origin, this.name, this.value, [this.reductions = const []]) : super.from(origin);
}
