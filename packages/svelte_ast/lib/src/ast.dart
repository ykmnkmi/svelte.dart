import 'package:analyzer/dart/ast/ast.dart'
    show DartPattern, Expression, SimpleIdentifier;
import 'package:svelte_ast/src/dart_to_json.dart';

part 'ast/blocks.dart';
part 'ast/tags.dart';
part 'ast/visitor.dart';

const DartToJsonVisitor dart2Json = DartToJsonVisitor();

abstract final class Node {
  Node({required this.start, required this.end});

  final int start;

  final int end;

  R accept<C, R>(Visitor<C, R> visitor, C context);

  Map<String, Object?> toJson();
}

final class Text extends Node {
  Text({
    required super.start,
    required super.end,
    this.raw = '',
    this.data = '',
  });

  String raw;

  String data;

  bool get isLeaf {
    return trimmed.isEmpty;
  }

  String get literal {
    return "'${data.replaceAll("'", r"\'").replaceAll('\r\n', r'\n').replaceAll('\n', r'\n')}'";
  }

  String get trimmed {
    return data.trim();
  }

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitText(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'Text',
      'raw': raw,
      'data': data,
    };
  }
}

final class CommentTag extends Node {
  CommentTag({
    required super.start,
    required super.end,
    this.data,
    this.ignores = const <String>[],
  });

  final String? data;

  final List<String> ignores;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitCommentTag(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'CommentTag',
      if (data case String data?) 'data': data,
      if (ignores.isNotEmpty) 'ignores': ignores,
    };
  }
}

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

final class Fragment extends Node {
  Fragment({
    required super.start,
    required super.end,
    required this.nodes,
  });

  final List<Node> nodes;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitFragment(this, context);
  }

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      '_': 'Fragment',
      if (nodes.isNotEmpty)
        'nodes': <Map<String, Object?>>[
          for (var node in nodes) node.toJson(),
        ],
    };
  }
}
