import 'package:analyzer/dart/ast/ast.dart'
    show AstNode, DartPattern, Expression, SimpleIdentifier;
import 'package:csslib/visitor.dart' show TreeNode;

part 'ast/blocks.dart';
part 'ast/tags.dart';
part 'ast/visitor.dart';

typedef JsonMapper = Map<String, Object?>? Function(Object object);

abstract class Node {
  Node({
    this.start = -1,
    this.end = -1,
    this.children = const <Node>[],
  });

  int start;

  int end;

  List<Node> children;

  R accept<C, R>(Visitor<C, R> visitor, C context);

  Map<String, Object?> toJson([JsonMapper? mapper]);
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
  Map<String, Object?> toJson([JsonMapper? mapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Text',
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
  Map<String, Object?> toJson([JsonMapper? mapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'CommentTag',
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
  Map<String, Object?> toJson([JsonMapper? mapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'RawMustacheTag',
      if (mapper != null) 'expression': mapper(expression),
    };
  }
}

final class ConstTag extends Node {
  ConstTag({
    super.start,
    super.end,
    required this.expression,
  });

  final Expression expression;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitConstTag(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper? mapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'ConstTag',
      if (mapper != null) 'expression': mapper(expression),
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
  Map<String, Object?> toJson([JsonMapper? mapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'DebugTag',
      if (mapper != null)
        if (identifiers case List<SimpleIdentifier> identifiers?
            when identifiers.isNotEmpty)
          'identifiers': <Map<String, Object?>?>[
            for (var identifier in identifiers) mapper(identifier),
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
  Map<String, Object?> toJson([JsonMapper? mapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'MustacheTag',
      if (mapper != null) 'expression': mapper(expression),
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
  Map<String, Object?> toJson([JsonMapper? mapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Fragment',
      if (children.isNotEmpty)
        'children': <Map<String, Object?>>[
          for (var node in children) node.toJson(),
        ],
    };
  }
}

final class Script extends Node {
  Script({
    super.start,
    super.end,
    this.context = 'default',
    required this.content,
    required this.body,
  });

  final String context;

  final ({int start, int end, String data}) content;

  final List<AstNode> body;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitScript(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper? mapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Script',
      'context': context,
      'content': <String, Object>{
        'start': content.start,
        'end': content.end,
        'data': content.data,
      },
      if (mapper != null && body.isNotEmpty)
        'body': <Map<String, Object?>?>[
          for (AstNode node in body) mapper(node),
        ],
    };
  }
}

final class Style extends Node {
  Style({
    super.start,
    super.end,
    required this.content,
    this.attributes = const <Node>[],
    required this.topLevels,
  });

  final ({int start, int end, String data}) content;

  final List<Node> attributes;

  final List<TreeNode> topLevels;

  @override
  R accept<C, R>(Visitor<C, R> visitor, C context) {
    return visitor.visitStyle(this, context);
  }

  @override
  Map<String, Object?> toJson([JsonMapper? mapper]) {
    return <String, Object?>{
      'start': start,
      'end': end,
      'class': 'Style',
      'content': <String, Object>{
        'start': content.start,
        'end': content.end,
        'data': content.data,
      },
      if (attributes.isNotEmpty)
        'raw': <Map<String, Object?>>[
          for (Node node in attributes) node.toJson(),
        ],
      if (mapper != null && topLevels.isNotEmpty)
        'raw': <Map<String, Object?>?>[
          for (TreeNode node in topLevels) mapper(node),
        ],
    };
  }
}
