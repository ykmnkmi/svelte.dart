import 'package:analyzer/dart/ast/ast.dart' show CompilationUnit, Expression;
import 'package:analyzer/error/error.dart';
import 'package:svelte/src/compiler/dart_to_json.dart';

const DartToJsonVisitor dartToJson = DartToJsonVisitor();

typedef Json = Map<String, Object?>;

extension on List<BaseNode> {
  List<Json> toJson() {
    return List<Json>.generate(length, (i) => this[i].toJson());
  }
}

extension on List<Expression> {
  List<Json> toJson() {
    return List<Json>.generate(length, (i) => this[i].accept(dartToJson)!);
  }
}

abstract class BaseNode {
  BaseNode({
    this.start,
    this.end,
    required this.type,
    this.children,
  });

  int? start;

  int? end;

  final String type;

  List<Node>? children;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': type,
      if (children != null) 'children': children!.toJson(),
    };
  }
}

abstract class Fragment implements BaseNode {
  @override
  List<Node>? get children;
}

abstract class Text implements BaseNode {
  String? get raw;

  String? get data;
}

abstract class Mustache implements BaseNode {
  Expression? get expression;
}

abstract class Comment implements BaseNode {
  String? get data;

  List<String>? get ignores;
}

abstract class Const implements BaseNode {
  Expression? get expression;
}

abstract class Debug implements BaseNode {
  List<Object?>? get identifiers;
}

abstract class Directive implements BaseNode {
  String? get name;
}

abstract class ExpressionDirective implements Directive {
  List<String>? get modifiers;
}

abstract class Element implements BaseNode {
  String? get name;

  covariant List<Node>? attributes;
}

abstract class Atribute implements BaseNode {
  String? get name;

  List<Node>? values;
}

abstract class SpreadAtribute implements BaseNode {
  Expression? get expression;
}

abstract class Transition implements ExpressionDirective {
  bool? get intro;

  bool? get outro;
}

class Node extends BaseNode
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
  Node({
    super.start,
    super.end,
    required super.type,
    this.name,
    this.raw,
    this.data,
    this.ignores,
    this.modifiers,
    this.tag,
    this.expression,
    this.identifiers,
    this.attributes,
    this.values,
    this.intro,
    this.outro,
    super.children,
  });

  @override
  String? name;

  @override
  String? raw;

  @override
  String? data;

  @override
  List<String>? ignores;

  @override
  List<String>? modifiers;

  Object? tag;

  @override
  Expression? expression;

  @override
  List<Expression>? identifiers;

  @override
  List<Node>? attributes;

  @override
  List<Node>? values;

  @override
  bool? intro;

  @override
  bool? outro;

  @override
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': type,
      if (name != null) 'name': name,
      if (raw != null) 'raw': raw,
      if (data != null) 'data': data,
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
      if (values != null && values!.isNotEmpty) 'values': values!.toJson(),
      if (intro != null) 'intro': intro,
      if (outro != null) 'outro': outro,
      if (children != null && children!.isNotEmpty)
        'children': children!.toJson(),
    };
  }
}

class Script extends BaseNode {
  Script({
    super.start,
    super.end,
    required this.context,
    required this.unit,
    this.errors,
  }) : super(type: 'Script');

  final String context;

  final CompilationUnit unit;

  final List<AnalysisError>? errors;
}
