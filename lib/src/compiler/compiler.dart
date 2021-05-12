import 'nodes.dart';
import 'parser.dart';
import 'utils.dart';
import 'visitor.dart';

String compile(String source) {
  final fragment = parse(source);
  return compileFragment(fragment, 'App');
}

String compileFragment(NodeList<Node> nodes, String contextClass) {
  return Fragment(contextClass, nodes).toSource();
}

class Fragment extends Visitor<String?, String?> {
  Fragment(String name, this.nodes)
      : sourceBuffer = StringBuffer(),
        root = <String>[],
        createList = <String>[],
        mountList = <String>[],
        count = <String, int>{} {
    trim(nodes);

    sourceBuffer
      ..write('class ${name}Fragment extends Fragment<$name> {\n')
      ..write('  ${name}Fragment($name context, RenderTree tree) : super(context, tree);');

    for (final child in nodes.children) {
      final id = child.accept(this);

      if (id != null) {
        root.add(id);
      }
    }

    writeCreate();
    writeMount();
    writeDetach();

    sourceBuffer.write('\n}');
  }

  final StringBuffer sourceBuffer;

  final NodeList<Node> nodes;

  final List<String> root;

  final List<String> createList;

  final List<String> mountList;

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
    createList.add('attr($parent, \'${node.name}\', ${Interpolator.visitAll(node.children, 'context')})');
  }

  @override
  String? visitElement(Element node, [String? parent]) {
    final id = getId(node.tag);
    sourceBuffer.write('\n\n  late Element $id;');
    createList.add('$id = element(\'${node.tag}\')');
    mount(id, parent);

    for (final child in node) {
      child.accept(this, id);
    }

    for (final attribute in node.attributes) {
      attribute.accept(this, id);
    }

    return id;
  }

  @override
  String? visitIdentifier(Identifier node, [String? parent]) {
    final id = getId('t');
    sourceBuffer.write('\n\n  late Text $id;');
    createList.add('$id = text(\'\${context.${node.name}}\')');
    mount(id, parent);
    return id;
  }

  @override
  String? visitText(Text node, [String? parent]) {
    final id = getId('t');
    sourceBuffer.write('\n\n  late Text $id;');
    createList.add('$id = text(\'${node.escaped}\')');
    mount(id, parent);
    return id;
  }

  void writeCreate() {
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
  }

  void writeDetach() {
    if (root.isNotEmpty) {
      sourceBuffer.write('\n\n  @override\n  void detach(bool detaching) {\n    if (detaching) {\n');

      for (final id in root) {
        sourceBuffer.write('      remove($id);\n');
      }

      sourceBuffer.write('    }\n  }');
    }
  }

  void writeMount() {
    if (mountList.isNotEmpty) {
      sourceBuffer.write('\n\n  @override\n  void mount(Node target, [Node? anchor]) {\n');

      for (var i = 0; i < mountList.length; i += 1) {
        if (i != 0) {
          sourceBuffer.writeln();
        }

        sourceBuffer.write('    ${mountList[i]};');
      }

      sourceBuffer.write('\n  }');
    }
  }
}
