import 'package:analyzer/dart/ast/ast.dart'
    show CompilationUnit, Expression, SimpleIdentifier;
import 'package:svelte/src/compiler/dart_to_json.dart';

const DartToJsonVisitor dartToJson = DartToJsonVisitor();

extension on List<Node> {
  List<Map<String, Object?>> toJson() {
    return List<Map<String, Object?>>.generate(length, (i) => this[i].toJson());
  }
}

extension on List<Expression> {
  List<Map<String, Object?>> toJson() {
    return dartToJson.visitAll(this).cast<Map<String, Object?>>();
  }
}

abstract class Node {
  Node({
    this.start,
    this.end,
    required this.type,
    this.children,
  });

  int? start;

  int? end;

  final String type;

  List<TemplateNode>? children;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': type,
      if (children != null) 'children': children!.toJson(),
    };
  }

  @override
  String toString() {
    return type;
  }
}

abstract class Fragment implements Node {
  @override
  List<TemplateNode>? get children;
}

abstract class Text implements Node {
  String? get raw;

  String? get data;
}

abstract class Mustache implements Node {
  Expression? get expression;
}

abstract class Comment implements Node {
  String? get data;

  List<String>? get ignores;
}

abstract class Const implements Node {
  Expression? get expression;
}

abstract class Debug implements Node {
  List<SimpleIdentifier>? get identifiers;
}

abstract class Directive implements Node {
  String? get name;
}

abstract class ExpressionDirective implements Directive {
  List<String>? get modifiers;
}

abstract class Element implements Node {
  String? get name;

  covariant List<TemplateNode>? attributes;
}

abstract class Atribute implements Node {
  String? get name;

  List<TemplateNode>? value;
}

abstract class SpreadAtribute implements Node {
  Expression? get expression;
}

abstract class Transition implements ExpressionDirective {
  bool get intro;

  bool get outro;
}

// TODO(parser): try Expando with extensions or back to mixins
class TemplateNode extends Node
    implements
        Fragment,
        Text,
        Mustache,
        Comment,
        Const,
        Debug,
        Directive,
        ExpressionDirective,
        Element,
        Atribute,
        SpreadAtribute,
        Transition {
  TemplateNode({
    super.start,
    super.end,
    required super.type,
    this.name,
    this.data,
    this.raw,
    this.ignores,
    this.modifiers,
    this.tag,
    this.expression,
    this.identifiers,
    this.attributes,
    this.value,
    this.intro = false,
    this.outro = false,
    this.elseIf = false,
    this.elseNode,
    super.children,
  });

  @override
  String? name;

  @override
  String? data;

  @override
  String? raw;

  @override
  List<String>? ignores;

  @override
  List<String>? modifiers;

  Object? tag;

  @override
  Expression? expression;

  @override
  List<SimpleIdentifier>? identifiers;

  @override
  List<TemplateNode>? attributes;

  @override
  List<TemplateNode>? value;

  @override
  bool intro;

  @override
  bool outro;

  bool elseIf;

  TemplateNode? elseNode;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': type,
      if (name != null) 'name': name,
      if (data != null) 'data': data,
      if (raw != null) 'raw': raw,
      if (ignores != null && ignores!.isNotEmpty) 'ignores': ignores,
      if (modifiers != null && modifiers!.isNotEmpty) 'modifiers': modifiers,
      if (tag is String)
        'tag': tag
      else if (tag is Expression)
        'tag': (tag as Expression).accept(dartToJson),
      if (expression != null) 'expression': expression!.accept(dartToJson),
      if (identifiers != null && identifiers!.isNotEmpty)
        'identifiers': identifiers!.toJson(),
      if (attributes != null && attributes!.isNotEmpty)
        'attributes': attributes!.toJson(),
      if (value != null && value!.isNotEmpty) 'value': value!.toJson(),
      if (intro) 'intro': intro,
      if (outro) 'outro': outro,
      if (elseIf) 'elseIf': elseIf,
      if (elseNode != null) 'elseNode': elseNode!.toJson(),
      if (children != null && children!.isNotEmpty)
        'children': children!.toJson(),
    };
  }

  @override
  String toString() {
    switch (type) {
      case 'IfBlock':
        return '{#if} block';
      case 'ThenBlock':
        return '{:then} block';
      case 'ElseBlock':
        return '{:else} block';
      case 'PendingBlock':
      case 'AwaitBlock':
        return '{#await} block';
      case 'CatchBlock':
        return '{:catch} block';
      case 'EachBlock':
        return '{#each} block';
      case 'RawMustacheTag':
        return '{@html} block';
      case 'DebugTag':
        return '{@debug} block';
      case 'ConstTag':
        return '{@const} tag';
      case 'Element':
      case 'InlineComponent':
      case 'Slot':
      case 'Title':
        return '<$name> tag';
      default:
        return type;
    }
  }
}

class Script extends Node {
  Script({
    super.start,
    super.end,
    required this.context,
    required this.unit,
  }) : super(type: 'Script');

  final String context;

  final CompilationUnit unit;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': type,
      'unit': unit.accept(dartToJson),
    };
  }
}

class Style extends Node {
  Style({
    super.start,
    super.end,
    this.attributes,
    required this.content,
  }) : super(type: 'Style');

  final List<TemplateNode>? attributes;

  final StyleContent content;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': type,
      if (attributes != null && attributes!.isNotEmpty)
        'attributes': attributes!.toJson(),
      'content': content,
    };
  }
}

class StyleContent extends Node {
  StyleContent({
    super.start,
    super.end,
    required this.styles,
  }) : super(type: 'StyleContent');

  final String styles;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': type,
      'styles': styles,
    };
  }
}
