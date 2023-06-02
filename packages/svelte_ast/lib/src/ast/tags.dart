part of '../ast.dart';

final class RawMustacheTag extends Node {
  RawMustacheTag({
    required super.start,
    required super.end,
    required this.value,
  });

  final Expression value;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitRawMustacheTag(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'RawMustacheTag',
      'value': value.accept(dart2Json),
    };
  }
}

final class ConstTag extends Node {
  ConstTag({
    required super.start,
    required super.end,
    required this.assign,
  });

  final Expression assign;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitConstTag(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'ConstTag',
      'assign': assign.accept(dart2Json),
    };
  }
}

final class DebugTag extends Node {
  DebugTag({
    required super.start,
    required super.end,
    this.identifiers,
  });

  final List<SimpleIdentifier>? identifiers;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitDebugTag(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'DebugTag',
      if (identifiers case List<SimpleIdentifier> identifiers?
          when identifiers.isNotEmpty)
        'identifiers': <Map<String, Object?>?>[
          for (var identifier in identifiers) identifier.accept(dart2Json),
        ],
    };
  }
}

final class MustacheTag extends Node {
  MustacheTag({
    required super.start,
    required super.end,
    required this.value,
  });

  final Expression value;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitMustacheTag(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'MustacheTag',
      'value': value.accept(dart2Json),
    };
  }
}
