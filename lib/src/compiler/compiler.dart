import 'package:angular_ast/angular_ast.dart' hide parse;
import 'package:code_builder/code_builder.dart';
import 'package:path/path.dart' as path;

import 'parser.dart';

String compile(String template, {required String sourceUrl, List<String> exports = const <String>[]}) {
  var nodes = parse(template, sourceUrl: sourceUrl);
  var name = sourceUrl.isEmpty ? 'App' : path.basenameWithoutExtension(sourceUrl);
  return compileNodes(name, nodes);
}

String compileNodes(String name, List<StandaloneTemplateAst> nodes, {List<String> exports = const <String>[]}) {
  var compiler = Compiler(name, exports: exports);
  return compiler.compile(nodes);
}

class Compiler implements TemplateAstVisitor<String?, String> {
  Compiler(this.name, {this.exports = const <String>[]})
      : inited = <Expression>[],
        constructed = <Expression>[],
        fields = <Field>[],
        created = <Expression>[],
        mounted = <Expression>[],
        listened = <Expression>[],
        removed = <Expression>[],
        counts = <String, int>{};

  final String name;

  final List<String> exports;

  final List<Expression> inited;

  final List<Expression> constructed;

  final List<Field> fields;

  final List<Expression> created;

  final List<Expression> mounted;

  final List<Expression> listened;

  final List<Expression> removed;

  final Map<String, int> counts;

  String getId(String tag) {
    var id = counts[tag] ??= 0;
    counts[tag] = ++id;
    return '$tag$id';
  }

  void mount(String id, [String? context]) {
    if (context == null) {
      mounted.add(refer('insert').call([refer('target'), refer(id), refer('anchor')]));
    } else {
      mounted.add(refer('append').call([refer(context), refer(id)]));
    }
  }

  @override
  String? visitAnnotation(AnnotationAst astNode, [String? context]) {
    throw UnimplementedError('visitAnnotation');
  }

  @override
  String? visitAttribute(AttributeAst node, [String? context]) {
    throw UnimplementedError('visitAttribute');
  }

  @override
  String? visitBanana(BananaAst astNode, [String? context]) {
    throw UnimplementedError('visitBanana');
  }

  @override
  String? visitCloseElement(CloseElementAst astNode, [String? context]) {
    throw UnimplementedError('visitCloseElement');
  }

  @override
  String? visitComment(CommentAst astNode, [String? context]) {
    throw UnimplementedError('visitComment');
  }

  @override
  String? visitContainer(ContainerAst astNode, [String? context]) {
    throw UnimplementedError('visitContainer');
  }

  @override
  String? visitElement(ElementAst node, [String? context]) {
    var id = getId(node.name);

    fields.add(Field((builder) {
      builder
        ..name = id
        ..type = refer('Element', 'dart:html')
        ..late = true;
    }));

    created.add(refer(id).assign(dom('element').call([literal(node.name)])));
    mount(id, context);

    for (var attribute in node.attributes) {
      attribute.accept(this, id);
    }

    for (var property in node.properties) {
      property.accept(this, id);
    }

    for (var event in node.events) {
      event.accept(this, id);
    }

    if (node.childNodes.isNotEmpty) {
      for (var child in node.childNodes) {
        child.accept(this, id);
      }
    }

    return id;
  }

  @override
  String? visitEmbeddedContent(EmbeddedContentAst astNode, [String? context]) {
    throw UnimplementedError('visitEmbeddedContent');
  }

  @override
  String? visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [String? context]) {
    throw UnimplementedError('visitEmbeddedTemplate');
  }

  @override
  String? visitEvent(EventAst astNode, [String? context]) {
    assert(context != null && astNode.value != null);
    var method = Method((method) => method
      ..requiredParameters.add(Parameter((parameter) => parameter
        ..name = 'event'
        ..type = refer('Event', 'dart:html')))
      ..lambda = true
      ..body = Code('context.${astNode.value}'));
    listened.add(dom('listen').call([refer(context!), literal(astNode.name), method.closure]));
  }

  @override
  String? visitInterpolation(InterpolationAst astNode, [String? context]) {
    var id = getId('text');
    var identifier = astNode.value.trim();

    fields.add(Field((builder) {
      builder
        ..name = id
        ..type = refer('Text', 'dart:html')
        ..late = true;
    }));

    created.add(refer(id).assign(dom('text').call([refer('context').property(identifier)])));
    mount(id, context);
    return id;
  }

  @override
  String? visitLetBinding(LetBindingAst astNode, [String? context]) {
    throw UnimplementedError('visitLetBinding');
  }

  @override
  String? visitProperty(PropertyAst astNode, [String? context]) {
    throw UnimplementedError('visitProperty');
  }

  @override
  String? visitReference(ReferenceAst astNode, [String? context]) {
    throw UnimplementedError('visitReference');
  }

  @override
  String? visitStar(StarAst astNode, [String? context]) {
    throw UnimplementedError('visitStar');
  }

  @override
  String? visitText(TextAst astNode, [String? context]) {
    var id = getId('text');
    var text = escape(astNode.value);

    fields.add(Field((builder) {
      builder
        ..name = id
        ..type = refer('Text', 'dart:html')
        ..late = true;
    }));

    Expression expression;

    if (text == ' ') {
      expression = refer(id).assign(dom('space').call([]));
    } else {
      expression = refer(id).assign(dom('text').call([literal(text)]));
    }

    created.add(expression);
    mount(id, context);
    return id;
  }

  String compile(List<StandaloneTemplateAst> nodes) {
    for (var node in nodes) {
      var id = node.accept(this);

      if (id != null) {
        removed.add(refer(id));
      }
    }

    if (listened.isNotEmpty) {
      inited.add(refer('mounted').assign(literalTrue));
      fields
        ..add(Field((field) => field
          ..name = 'mounted'
          ..type = refer('bool')))
        ..add(Field((field) => field
          ..name = 'dispose'
          ..type = listened.length == 1
              ? refer('Function')
              : TypeReference((type) => type
                ..symbol = 'List'
                ..types.add(refer('Function')))
          ..late = true));
    }

    inited.add(refer('super').call([refer('context'), refer('tree')]));

    var fragment = Class((klass) {
      klass
        ..name = '${name}Fragment'
        ..extend = runtime('Fragment', [refer(name)])
        ..constructors.add(Constructor((constructor) => constructor
          ..requiredParameters.add(Parameter((parameter) => parameter
            ..name = 'context'
            ..type = refer(name)))
          ..requiredParameters.add(Parameter((builder) => builder
            ..name = 'tree'
            ..type = runtime('RenderTree')))
          ..initializers.addAll(inited.map((init) => init.code))
          ..body = Block.of(constructed.map((expression) => expression.statement))))
        ..fields.addAll(fields);

      if (created.isNotEmpty) {
        klass.methods.add(Method((method) => method
          ..name = 'create'
          ..annotations.add(refer('override'))
          ..returns = refer('void')
          ..body = Block.of(created.map((expression) => expression.statement))));
      }

      if (mounted.isNotEmpty) {
        var body = <Code>[];

        for (var mount in mounted) {
          body.add(mount.statement);
        }

        if (listened.isNotEmpty) {
          body.add(Code('\nif (!mounted) {'));
          Expression expression;

          if (listened.length == 1) {
            expression = listened.first;
          } else {
            expression = literalList(listened, refer('Function'));
          }

          var assign = refer('dispose').assign(expression);
          body
            ..add(assign.statement)
            ..add(Code('}\n'));
        }

        klass.methods.add(Method((method) => method
          ..name = 'mount'
          ..annotations.add(refer('override'))
          ..returns = refer('void')
          ..requiredParameters.add(Parameter((parameter) => parameter
            ..name = 'target'
            ..type = refer('Element', 'dart:html')))
          ..optionalParameters.add(Parameter((parameter) => parameter
            ..name = 'anchor'
            ..type = TypeReference((type) => type
              ..symbol = 'Node'
              ..url = 'dart:html'
              ..isNullable = true)))
          ..body = Block.of(body)));
      }

      if (removed.isNotEmpty) {
        var body = <Code>[];

        if (removed.isNotEmpty) {
          body.add(Code('\nif (detaching) {'));

          for (var id in removed) {
            var call = dom('remove').call([id]);
            body.add(call.statement);
          }

          body.add(Code('}\n'));
        }

        if (listened.isNotEmpty) {
          var assign = refer('mounted').assign(literalFalse);
          body.add(assign.statement);

          if (listened.length == 1) {
            var call = refer('dispose').call([]);
            body.add(call.statement);
          } else {
            var method = Method((method) => method
              ..requiredParameters.add(Parameter((parameter) => parameter..name = 'fn'))
              ..body = Code('fn'));
            var call = refer('dispose').property('forEach').call([method.closure]);
            body.add(call.statement);
          }
        }

        klass.methods.add(Method((method) => method
          ..name = 'detach'
          ..annotations.add(refer('override'))
          ..returns = refer('void')
          ..optionalParameters.add(Parameter((parameter) => parameter
            ..name = 'detaching'
            ..type = refer('bool')
            ..defaultTo = literalTrue.code))
          ..body = Block.of(body)));
      }
    });

    return fragment.accept<StringSink>(DartEmitter(orderDirectives: true, useNullSafetySyntax: true)).toString();
  }

  static String escape(String text) {
    return text.replaceAll("'", r"\'").replaceAll('\r', r'\r').replaceAll('\n', r'\n');
  }

  static Reference dom(String symbol) {
    return refer(symbol, 'package:piko/dom.dart');
  }

  static Reference runtime(String symbol, [List<Reference>? types]) {
    if (types == null) {
      return refer(symbol, 'package:piko/runtim.dart');
    }

    return TypeReference((type) => type
      ..symbol = symbol
      ..url = 'package:piko/runtim.dart'
      ..types.addAll(types));
  }
}
