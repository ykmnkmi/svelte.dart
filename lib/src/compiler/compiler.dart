import 'nodes.dart';
import 'parser.dart';
import 'utils.dart';
import 'visitor.dart';

String compile(String source) {
  final fragment = parse(source);
  return compileFragment(fragment, 'App');
}

String compileFragment(Fragment fragment, String contextClass) {
  return FragmentCompiler(contextClass, fragment).toSource();
}

class FragmentCompiler extends Visitor<String?, String?> {
  FragmentCompiler(String name, this.fragment)
      : sourceBuffer = StringBuffer(),
        nodeList = <String>[],
        createList = <String>[],
        rootIds = <String>[],
        mountList = <String>[],
        listenList = <String>[],
        count = <String, int>{} {
    trim(fragment);

    for (final child in fragment.children) {
      final id = child.accept(this);

      if (id != null) {
        rootIds.add(id);
      }
    }

    sourceBuffer..write('class ${name}Fragment extends Fragment<$name> {\n')..write('  ${name}Fragment($name context, RenderTree tree)');

    if (listenList.isNotEmpty) {
      sourceBuffer.write('\n      : mounted = false,\n        super(context, tree);');
    } else {
      sourceBuffer.write(' : super(context, tree);');
    }

    if (nodeList.isNotEmpty) {
      for (final node in nodeList) {
        sourceBuffer.write('\n\n  $node;');
      }
    }

    if (listenList.isNotEmpty) {
      sourceBuffer.write('\n\n  bool mounted;');

      if (listenList.length == 1) {
        sourceBuffer.write('\n\n  late VoidCallback dispose;');
      } else {
        sourceBuffer.write('\n\n  late List<VoidCallback> dispose;');
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
          sourceBuffer.write('\n      dispose = <VoidCallback>[');

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

    if (rootIds.isNotEmpty) {
      sourceBuffer.write('\n\n  @override\n  void detach(bool detaching) {\n    if (detaching) {');

      for (final id in rootIds) {
        sourceBuffer.write('\n      remove($id);');
      }

      sourceBuffer.write('\n    }');

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

  final Fragment fragment;

  final List<String> nodeList;

  final List<String> createList;

  final List<String> rootIds;

  final List<String> mountList;

  final List<String> listenList;

  final Map<String, int> count;

  String getId(String tag) {
    var id = count[tag] ?? 0;
    count[tag] = id += 1;
    return '$tag$id';
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
  String? visitAttribute(Attribute node, [String? parent]) {
    createList.add('$parent.${node.name} = true');
  }

  @override
  String? visitCondition(Condition node, [String? parent]) {
    final id = getId('t');
    nodeList.add('late Text $id');
    nodeList.add('late String ${id}value');
    createList.add('$id = text(${id}value = \'${interpolate(node)}\')');
    mount(id, parent);
    return id;
  }

  @override
  String? visitElement(Element node, [String? parent]) {
    final id = getId(node.tag);
    nodeList.add('late Element $id');
    createList.add('$id = element(\'${node.tag}\')');
    mount(id, parent);

    for (final attribute in node.attributes) {
      attribute.accept(this, id);
    }

    for (final child in node.children) {
      child.accept(this, id);
    }

    return id;
  }

  @override
  String? visitEventListener(EventListener node, [String? parent]) {
    listenList.add('listen($parent, \'${node.name}\', (Event event) { ${interpolate(node.callback, wrap: false)}(); })');
    return null;
  }

  @override
  String? visitIdentifier(Identifier node, [String? parent]) {
    final id = getId('t');
    nodeList.add('late Text $id');
    createList.add('$id = text(\'\${context.${node.name}}\')');
    mount(id, parent);
    return id;
  }

  @override
  String? visitText(Text node, [String? parent]) {
    final id = getId('t');
    nodeList.add('late Text $id');
    createList.add('$id = text(\'${node.escaped}\')');
    mount(id, parent);
    return id;
  }

  @override
  String? visitValueAttribute(ValueAttribute node, [String? parent]) {
    createList.add('attr($parent, \'${node.name}\', \'${interpolate(node.value)}\')');
  }
}
