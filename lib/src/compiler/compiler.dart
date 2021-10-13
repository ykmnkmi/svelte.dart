import 'package:angular_ast/angular_ast.dart' hide parse;
import 'package:path/path.dart' as path;

import 'parser.dart';

String compile(String template, {required String sourceUrl, List<String> exports = const <String>[]}) {
  var nodes = parse(template, sourceUrl: sourceUrl);
  var name = sourceUrl.isEmpty ? 'App' : path.basenameWithoutExtension(sourceUrl);
  return compileNodes(name, nodes);
}

String compileNodes(String name, List<StandaloneTemplateAst> nodes, {List<String> exports = const <String>[]}) {
  var compiler = Compiler(name, exports);
  return compiler.visitAll(nodes);
}

class Compiler implements TemplateAstVisitor<String?, String> {
  Compiler(this.name, this.exports)
      : sourceBuffer = StringBuffer(),
        initList = <String>[],
        constructorList = <String>[],
        finalFieldList = <String>[],
        fieldList = <String>[],
        createList = <String>[],
        mountList = <String>[],
        listenList = <String>[],
        updateMap = <String, List<String>>{},
        removeList = <String>[],
        fragmentDetachList = <String>[],
        countMap = <String, int>{};

  final String name;

  final List<String> exports;

  final StringBuffer sourceBuffer;

  final List<String> initList;

  final List<String> constructorList;

  final List<String> finalFieldList;

  final List<String> fieldList;

  final List<String> createList;

  final List<String> mountList;

  final List<String> listenList;

  final Map<String, List<String>> updateMap;

  final List<String> removeList;

  final List<String> fragmentDetachList;

  final Map<String, int> countMap;

  String getId(String tag) {
    var id = countMap[tag] ?? 0;
    countMap[tag] = id += 1;
    return id == 1 ? tag : '$tag$id';
  }

  void mount(String id, [String? context]) {
    if (context == null) {
      mountList.add('insert(target, $id, anchor)');
    } else {
      mountList.add('append($context, $id)');
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
    fieldList.add('late Element $id');
    createList.add('$id = element(\'${node.name}\')');
    mount(id, context);

    for (var attribute in node.attributes) {
      attribute.accept(this, id);
    }

    for (var property in node.properties) {
      property.accept(this, id);
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
    throw UnimplementedError('visitEvent');
  }

  @override
  String? visitInterpolation(InterpolationAst node, [String? context]) {
    throw UnimplementedError('visitInterpolation');
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
  String? visitText(TextAst node, [String? context]) {
    var id = getId('t');
    var text = escape(node.value);
    fieldList.add('late Text $id');

    if (text == ' ') {
      createList.add('$id = space()');
    } else {
      createList.add('$id = text(\'${escape(node.value)}\')');
    }

    mount(id, context);
    return id;
  }

  String visitAll(List<StandaloneTemplateAst> nodes) {
    for (var node in nodes) {
      var id = node.accept(this);

      if (id != null) {
        removeList.add(id);
      }
    }

    sourceBuffer
      ..write('class ${name}Fragment extends Fragment<$name> {\n')
      ..write('  ${name}Fragment($name context, RenderTree tree)');

    if (listenList.isNotEmpty) {
      initList.add('mounted = true');
    }

    if (initList.isNotEmpty) {
      sourceBuffer.write('\n      : ${initList[0]},');

      for (var init in initList.skip(1)) {
        sourceBuffer.write('\n        $init,');
      }

      sourceBuffer.write('\n        super(context, tree)');
    } else {
      sourceBuffer.write(' : super(context, tree)');
    }

    if (constructorList.isEmpty) {
      sourceBuffer.write(';');
    } else {
      sourceBuffer.write(' {');

      for (var i = 0; i < constructorList.length; i += 1) {
        sourceBuffer.write('\n    ${constructorList[i]};');
      }

      sourceBuffer.write('\n  }');
    }

    for (var finalField in finalFieldList) {
      sourceBuffer.write('\n\n  final $finalField;');
    }

    for (var field in fieldList) {
      sourceBuffer.write('\n\n  $field;');
    }

    if (listenList.isNotEmpty) {
      sourceBuffer.write('\n\n  bool mounted;');

      if (listenList.length == 1) {
        sourceBuffer.write('\n\n  late Function dispose;');
      } else {
        sourceBuffer.write('\n\n  late List<Function> dispose;');
      }
    }

    // create

    if (createList.isNotEmpty) {
      sourceBuffer.write('\n\n  @override\n  void create() {\n');

      for (var i = 0; i < createList.length; i += 1) {
        if (i != 0) {
          sourceBuffer.writeln();
        }

        sourceBuffer.write('    ${createList[i]};');
      }

      sourceBuffer.write('\n  }');
    }

    // mount

    if (mountList.isNotEmpty) {
      sourceBuffer.write('\n\n  @override\n  void mount(Element target, [Node? anchor]) {\n');

      for (var i = 0; i < mountList.length; i += 1) {
        if (i != 0) {
          sourceBuffer.writeln();
        }

        sourceBuffer.write('    ${mountList[i]};');
      }

      if (listenList.isNotEmpty) {
        sourceBuffer.write('\n\n    if (!mounted) {');

        if (listenList.length == 1) {
          sourceBuffer.write('\n      dispose = ${listenList[0]};');
        } else {
          sourceBuffer.write('\n      dispose = <Function>[');

          for (var listen in listenList) {
            sourceBuffer.write('\n        $listen;');
          }

          sourceBuffer.write('\n      ];');
        }

        sourceBuffer.write('\n    }');
      }

      sourceBuffer.write('\n  }');
    }

    // detach

    if (removeList.isNotEmpty || fragmentDetachList.isNotEmpty) {
      sourceBuffer.write('\n\n  @override\n  void detach(bool detaching) {\n');

      if (removeList.isNotEmpty) {
        sourceBuffer.write('    if (detaching) {');

        for (final id in removeList) {
          sourceBuffer.write('\n      remove($id);');
        }

        sourceBuffer.write('\n    }');
      }

      for (final fragmentRemove in fragmentDetachList) {
        sourceBuffer.write('\n    $fragmentRemove;');
      }

      if (listenList.isNotEmpty) {
        sourceBuffer.write('\n\n    mounted = false;');

        if (listenList.length == 1) {
          sourceBuffer.write('\n    dispose();');
        } else {
          sourceBuffer.write('\n    dispose.forEach((fn) => fn());');
        }
      }

      sourceBuffer.write('\n  }');
    }

    sourceBuffer.write('\n}');
    return sourceBuffer.toString();
  }

  static String escape(String text) {
    return text.replaceAll("'", r"\'").replaceAll('\r', r'\r').replaceAll('\n', r'\n');
  }
}
