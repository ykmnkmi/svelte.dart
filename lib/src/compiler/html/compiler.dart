import 'nodes.dart';
import 'parser.dart';
import 'utils.dart';
import 'visitor.dart';

String compile(String source, {String name = 'Component'}) {
  final fragment = parse(source);
  return compileFragment(fragment, name: name);
}

String compileFragment(Fragment fragment, {String name = 'Component', bool preserveComments = false}) {
  if (!preserveComments) {
    removeComments(fragment);
  }

  trim(fragment);
  return CreateFragment(name, fragment).toSource();
}

class CreateFragment extends Visitor<String?> {
  CreateFragment(String name, this.fragment)
      : buffer = StringBuffer(),
        root = <String>[],
        create = <String>[],
        mount = <String>[],
        count = <String, int>{} {
    buffer
      ..write('class ${name}Fragment extends Fragment<$name> {\n')
      ..write('  ${name}Fragment($name context, Scheduler scheduler) : super(context, scheduler);');

    for (final child in fragment.children) {
      final id = child.accept(this);

      if (id != null) {
        root.add(id);
      }
    }

    writeCreate();

    writeMount();

    writeDetach();

    buffer.write('\n}');
  }

  final StringBuffer buffer;

  final Fragment fragment;

  final List<String> root;

  final List<String> create;

  final List<String> mount;

  final Map<String, int> count;

  String add(String tag) {
    var id = count[tag] ?? 0;
    count[tag] = id += 1;
    return '$tag$id';
  }

  String toSource() {
    return '$buffer';
  }

  @override
  String? visitComment(Comment node) {
    throw UnimplementedError();
  }

  @override
  String? visitElement(Element node) {
    throw UnimplementedError();
  }

  @override
  String? visitFragment(Fragment node) {
    throw UnimplementedError();
  }

  @override
  String? visitIdentifier(Identifier node) {
    final id = add('t');
    buffer.write('\n\n  late Text $id;');
    create.add('$id = text(context.${node.identifier})');
    mount.add('insert(target, $id, anchor)');
    return id;
  }

  @override
  String? visitText(Text node) {
    final id = add('t');
    buffer.write('\n\n  late Text $id;');
    create.add('$id = text(\'${node.escaped}\')');
    mount.add('insert(target, $id, anchor)');
    return id;
  }

  void writeCreate() {
    buffer.write('\n\n  @override\n  void create() {\n');

    for (var i = 0; i < create.length; i += 1) {
      if (i != 0) {
        buffer.writeln();
      }

      buffer.write('    ${create[i]};');
    }

    buffer.write('\n  }');
  }

  void writeMount() {
    buffer.write('\n\n  @override\n  void mount(Node target, [Node? anchor]) {\n');

    for (var i = 0; i < mount.length; i += 1) {
      if (i != 0) {
        buffer.writeln();
      }

      buffer.write('    ${mount[i]};');
    }

    buffer.write('\n  }');
  }

  void writeDetach() {
    buffer.write('\n\n  @override\n  void detach(bool detaching) {\n    if (detaching) {\n');

    for (final id in root) {
      buffer.write('      remove($id);\n');
    }

    buffer.write('    }\n  }');
  }
}
