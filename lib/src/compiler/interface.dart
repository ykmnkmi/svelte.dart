import 'package:analyzer/dart/ast/ast.dart'
    show CompilationUnit, Expression, SimpleIdentifier;
import 'package:csslib/visitor.dart' show StyleSheet;
import 'package:svelte/src/compiler/css_to_json.dart';
import 'package:svelte/src/compiler/dart_to_json.dart';

const DartToJsonVisitor dartToJson = DartToJsonVisitor();

const CssToJsonVisitor cssToJson = CssToJsonVisitor();

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
    this.expression,
    this.identifiers,
    this.attributes,
    this.value,
    this.intro = false,
    this.outro = false,
    super.children,
    this.tag,
    this.ifElseIf = false,
    this.ifElse,
    this.eachContext,
    this.eachIndex,
    this.eachKey,
    this.awaitValue,
    this.awaitError,
    this.awaitPending,
    this.awaitThen,
    this.awaitCatch,
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

  Object? tag;

  bool ifElseIf;

  TemplateNode? ifElse;

  SimpleIdentifier? eachContext;

  String? eachIndex;

  Expression? eachKey;

  SimpleIdentifier? awaitValue;

  SimpleIdentifier? awaitError;

  TemplateNode? awaitPending;

  TemplateNode? awaitThen;

  TemplateNode? awaitCatch;

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
      if (expression != null) 'expression': expression!.accept(dartToJson),
      if (identifiers != null && identifiers!.isNotEmpty)
        'identifiers': identifiers!.toJson(),
      if (attributes != null && attributes!.isNotEmpty)
        'attributes': attributes!.toJson(),
      if (value != null && value!.isNotEmpty) 'value': value!.toJson(),
      if (intro) 'intro': intro,
      if (outro) 'outro': outro,
      if (children != null && children!.isNotEmpty)
        'children': children!.toJson(),
      if (tag is String)
        'tag': tag
      else if (tag is Expression)
        'tag': (tag as Expression).accept(dartToJson),
      if (ifElseIf) 'elseIf': ifElseIf,
      if (ifElse != null) 'else': ifElse!.toJson(),
      if (eachContext != null) 'context': eachContext!.accept(dartToJson),
      if (eachIndex != null) 'index': eachIndex,
      if (eachKey != null) 'key': eachKey!.accept(dartToJson),
      if (awaitValue != null) 'value': awaitValue!.accept(dartToJson),
      if (awaitError != null) 'error': awaitError!.accept(dartToJson),
      if (awaitPending != null) 'pending': awaitPending!.toJson(),
      if (awaitThen != null) 'then': awaitThen!.toJson(),
      if (awaitCatch != null) 'catch': awaitCatch!.toJson(),
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
      'context': context,
      'unit': unit.accept(dartToJson),
    };
  }
}

class Style extends Node {
  Style({
    super.start,
    super.end,
    this.attributes,
    required this.sheet,
    required this.content,
  }) : super(type: 'Style');

  final List<TemplateNode>? attributes;

  final StyleSheet sheet;

  final StyleContent content;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': type,
      if (attributes != null && attributes!.isNotEmpty)
        'attributes': attributes!.toJson(),
      'sheet': sheet.visit(cssToJson),
      'content': content.toJson(),
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
      'styles': styles,
    };
  }
}

class Ast {
  Ast({
    required this.html,
    this.instance,
    this.module,
    this.style,
  });

  final Fragment html;

  final Script? instance;

  final Script? module;

  final Style? style;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'html': html.toJson(),
      if (instance != null) 'instance': instance!.toJson(),
      if (module != null) 'module': module!.toJson(),
      if (style != null) 'style': style!.toJson(),
    };
  }
}
