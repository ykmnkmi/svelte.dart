import 'nodes.dart';
import 'utils.dart';
import 'visitor.dart';

String compile(Library library) {
  return Compiler(library).toSource();
}

class Compiler extends Visitor<String?, String?> {
  Compiler(this.library)
      : sourceBuffer = StringBuffer(),
        initList = <String>[],
        constructorList = <String>[],
        finalFieldList = <String>[],
        fieldList = <String>[],
        createList = <String>[],
        mountList = <String>[],
        listenList = <String>[],
        removeList = <String>[],
        fragmentDetachList = <String>[],
        count = <String, int>{} {
    trim(library.fragment);

    for (final child in library.fragment.children) {
      final id = child.accept(this);

      if (id != null) {
        removeList.add(id);
      }
    }

    sourceBuffer
      ..write('class ${library.name}Fragment extends Fragment<${library.name}> {\n')
      ..write('  ${library.name}Fragment(${library.name} context, RenderTree tree)');

    if (listenList.isNotEmpty) {
      initList.add('mounted = true');
    }

    if (initList.isNotEmpty) {
      sourceBuffer.write('\n      : ${initList[0]},');

      for (final init in initList.skip(1)) {
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

    for (final finalField in finalFieldList) {
      sourceBuffer.write('\n\n  final $finalField;');
    }

    for (final field in fieldList) {
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

          for (final listen in listenList) {
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

        sourceBuffer.write('\n    }\n\n');
      }

      for (final fragmentRemove in fragmentDetachList) {
        sourceBuffer.write('    $fragmentRemove;');
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
  }

  final StringBuffer sourceBuffer;

  final Library library;

  final List<String> initList;

  final List<String> constructorList;

  final List<String> finalFieldList;

  final List<String> fieldList;

  final List<String> createList;

  final List<String> mountList;

  final List<String> listenList;

  final List<String> removeList;

  final List<String> fragmentDetachList;

  final Map<String, int> count;

  String getId(String tag) {
    var id = count[tag] ?? 0;
    count[tag] = id += 1;
    return id == 1 ? tag : '$tag$id';
  }

  void mount(String id, [String? parent]) {
    if (parent == null) {
      mountList.add('insert(target, $id, anchor)');
    } else {
      mountList.add('append($parent, $id)');
    }
  }

  String toSource() {
    return '$sourceBuffer';
  }

  @override
  String? visitAttribute(Attribute node, [String? context]) {
    createList.add('$context.${node.name} = true');
  }

  @override
  String? visitCondition(Condition node, [String? context]) {
    final id = getId('t');
    fieldList.add('late Text $id');
    fieldList.add('late String ${id}value');
    createList.add('$id = text(${id}value = \'${interpolate(node)}\')');
    mount(id, context);
    return id;
  }

  @override
  String? visitElement(Element node, [String? context]) {
    final id = getId(node.tag);
    fieldList.add('late Element $id');
    createList.add('$id = element(\'${node.tag}\')');
    mount(id, context);

    for (final attribute in node.attributes) {
      attribute.accept(this, id);
    }

    if (node.children.isNotEmpty) {
      if (node.children.every((node) => node is Expression)) {
        createList.add('$id.text = \'${interpolate(Interpolation(node.children.cast<Expression>()))}\'');
      } else {
        for (final child in node.children) {
          child.accept(this, id);
        }
      }
    }

    return id;
  }

  @override
  String? visitEventListener(EventListener node, [String? context]) {
    listenList.add('listen($context, \'${node.name}\', (event) { ${interpolate(node.callback, wrap: false)}(); })');
    return null;
  }

  @override
  String? visitIdentifier(Identifier node, [String? context]) {
    final id = getId('t');
    fieldList.add('late Text $id');
    createList.add('$id = text(\'\${context.${node.name}}\')');
    mount(id, context);
    return id;
  }

  @override
  String? visitInline(Inline node, [String? context]) {
    final id = getId(node.name[0].toLowerCase() + node.name.substring(1));
    final init = StringBuffer('$id = ${node.name}');

    if (node.sub.isNotEmpty) {
      init.write('.${node.sub}');
    }

    init.write('(');

    // TODO: handle arguments

    init.write(')');
    initList.add('$init');
    final fragment = '${id}Fragment';
    constructorList.add('$fragment = $id.render(tree)');
    finalFieldList.add('${node.name} $id');
    fieldList.add('late Fragment<${node.name}> $fragment');
    createList.add('createFragment($fragment)');

    if (context == null) {
      mountList.add('mountFragment($fragment, target, anchor)');
    } else {
      mountList.add('mountFragment($fragment, $context)');
    }

    fragmentDetachList.add('detachFragment($fragment)');
  }

  @override
  String? visitStyle(Style node, [String? context]) {
    // const/final
    // TODO: setStyle

    // dynamic
    createList.add('attr($context, \'style\', \'${interpolate(node.value)}\')');
  }

  @override
  String? visitText(Text node, [String? context]) {
    final id = getId('t');
    final text = node.escaped;
    fieldList.add('late Text $id');

    if (text == ' ') {
      createList.add('$id = space()');
    } else {
      createList.add('$id = text(\'${node.escaped}\')');
    }

    mount(id, context);
    return id;
  }

  @override
  String? visitValueAttribute(ValueAttribute node, [String? context]) {
    createList.add('attr($context, \'${node.name}\', \'${interpolate(node.value)}\')');
  }
}
