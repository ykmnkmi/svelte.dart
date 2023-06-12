import 'package:analyzer/dart/ast/ast.dart'
    show DartPattern, Expression, SimpleIdentifier;
import 'package:svelte_ast/src/dart_to_json.dart';

part 'ast/blocks.dart';
part 'ast/tags.dart';
part 'ast/visitor.dart';

const DartToJsonVisitor dart2Json = DartToJsonVisitor();

abstract final class Node {
  Node({
    this.start = -1,
    this.end = -1,
    this.children = const <Node>[],
  });

  int start;

  int end;

  final List<Node> children;

  R accept<C, R>(Visitor<C, R> visitor, C context);

  Map<String, Object?> toJson();
}

final class Text extends Node {
  Text({
    super.start,
    super.end,
    this.raw = '',
    this.data = '',
  });

  final String raw;

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
    super.start,
    super.end,
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
    super.start,
    super.end,
    required this.expression,
  });

  final Expression expression;

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
      'expression': expression.accept(dart2Json),
    };
  }
}

final class ConstTag extends Node {
  ConstTag({
    super.start,
    super.end,
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
    super.start,
    super.end,
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
    super.start,
    super.end,
    required this.expression,
  });

  final Expression expression;

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
      'expression': expression.accept(dart2Json),
    };
  }
}

final class Fragment extends Node {
  Fragment({
    super.start,
    super.end,
    super.children,
  });

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
      if (children.isNotEmpty)
        'children': <Map<String, Object?>>[
          for (var node in children) node.toJson(),
        ],
    };
  }
}
