import 'package:piko/src/compiler/visitor.dart';

import '../nodes.dart';
import 'program.dart';
import 'utils.dart';

Program dom(String name, Fragment fragment) {
  final buffer = StringBuffer();
  final library = getLibraryName(name);
  buffer.write('library $library;\n\nimport \'package:piko/internal.dart\';\n\n');
  CreateComponent(buffer, name, fragment);
  buffer.write('\n\n');
  CreateFragment(buffer, name, fragment);
  return Program(name, buffer.toString());
}

class CreateComponent extends Visitor<String?> {
  CreateComponent(this.buffer, String name, this.fragment) {
    buffer
      ..write('class $name extends Component<$name> {\n')
      ..write('  @override\n  Fragment<$name> render([Scheduler? scheduler]) {\n')
      ..write('    return ${name}Fragment(this, scheduler ?? Scheduler());\n  }\n}');
  }

  final StringBuffer buffer;

  final Fragment fragment;

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
    throw UnimplementedError();
  }

  @override
  String? visitText(Text node) {
    throw UnimplementedError();
  }
}

class CreateFragment extends Visitor<String?> {
  CreateFragment(this.buffer, String name, this.fragment)
      : root = <String>[],
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
