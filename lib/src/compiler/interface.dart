import 'package:analyzer/dart/ast/ast.dart' show Expression;
import 'package:svelte/src/compiler/dart_to_json.dart';

const DartToJsonVisitor dartToJson = DartToJsonVisitor();

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

  List<Node>? children;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'start': start,
      'end': end,
      'type': type,
      if (children != null)
        'children': children!
            .map<Map<String, Object?>>((node) => node.toJson())
            .toList(),
    };
  }
}

abstract class Fragment implements Node {
  @override
  List<Node>? get children;
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
  List<Object?>? get identifiers;
}

abstract class Directive implements Node {
  String? get name;
}

abstract class ExpressionDirective implements Directive {
  List<String>? get modifiers;
}

abstract class Element implements Node {
  String? get name;

  List<Node>? attributes;
}

abstract class Atribute implements Node {
  String? get name;

  List<Node>? values;
}

abstract class SpreadAtribute implements Node {
  Expression? get expression;
}

abstract class Transition implements ExpressionDirective {
  bool? get intro;

  bool? get outro;
}

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
    this.tag,
    this.raw,
    this.data,
    this.ignores,
    this.modifiers,
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

  String? tag;

  @override
  String? raw;

  @override
  String? data;

  @override
  List<String>? ignores;

  @override
  List<String>? modifiers;

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
      if (tag != null) 'tag': tag,
      if (raw != null) 'raw': raw,
      if (data != null) 'data': data,
      if (ignores != null && ignores!.isNotEmpty) 'ignores': ignores,
      if (modifiers != null && modifiers!.isNotEmpty) 'modifiers': modifiers,
      if (expression != null) 'expression': expression!.accept(dartToJson),
      if (identifiers != null && identifiers!.isNotEmpty)
        'identifiers': identifiers!
            .map<Map<String, Object?>>(
                (identifier) => identifier.accept(dartToJson)!)
            .toList(),
      if (attributes != null && attributes!.isNotEmpty)
        'attributes': attributes!
            .map<Map<String, Object?>>((node) => node.toJson())
            .toList(),
      if (values != null && values!.isNotEmpty)
        'values':
            values!.map<Map<String, Object?>>((node) => node.toJson()).toList(),
      if (intro != null) 'intro': intro,
      if (outro != null) 'outro': outro,
      if (children != null && children!.isNotEmpty)
        'children': children!
            .map<Map<String, Object?>>((node) => node.toJson())
            .toList(),
    };
  }
}
