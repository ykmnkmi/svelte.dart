import 'package:piko/src/compiler/visitor.dart';

import '../nodes.dart';
import 'program.dart';
import 'utils.dart';

Program dom(String name, Fragment fragment) {
  final buffer = StringBuffer()
    ..writeLibrary(name)
    ..writeln()
    ..writeComponent(name)
    ..writeln()
    ..writeFragment(name, fragment);
  return Program(name, buffer.toString());
}

extension on StringBuffer {
  void writeLibrary(String name) {
    final library = getLibraryName(name);
    writeln('library $library;');
  }

  void writeComponent(String name) {
    writeln('class $name extends Component<$name> {');
    writeln('  @override');
    writeln('  Fragment<$name> render([Scheduler? scheduler]) {');
    writeln('    return ${name}Fragment(this, scheduler ?? Scheduler());');
    writeln('  }');
    writeln('}');
  }

  void writeFragment(String name, Fragment fragment) {
    CreateFragment(this, name, fragment);
  }
}

class CreateFragment extends Visitor<void> {
  CreateFragment(this.source, String name, this.fragment)
      : create = StringBuffer(),
        detach = StringBuffer(),
        mount = StringBuffer(),
        count = <String, int>{} {
    source
      ..writeln('class ${name}Fragment extends Fragment<$name> {')
      ..writeln('  ${name}Fragment($name context, Scheduler scheduler) : super(context, scheduler);')
      ..writeln();

    visitFragment(fragment);

    source
      ..writeln('  @override')
      ..writeln('  void create() {')
      ..write(create)
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  void mount(Node target, [Node? anchor]) {')
      ..write(mount)
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  void detach(bool detaching) {')
      ..write(detach)
      ..writeln('  }')
      ..writeln('}');
  }

  final StringBuffer source;

  final Fragment fragment;

  final StringBuffer create;

  final StringBuffer mount;

  final StringBuffer detach;

  final Map<String, int> count;

  String add(String tag) {
    var id = count[tag] ?? 0;
    count[tag] = id += 1;
    return '$tag$id';
  }

  @override
  void visitComment(Comment node) {
    throw UnimplementedError();
  }

  @override
  void visitElement(Element node) {
    throw UnimplementedError();
  }

  @override
  void visitFragment(Fragment node) {
    for (final child in node.children) {
      child.accept(this);
    }
  }

  @override
  void visitIdentifier(Identifier node) {
    throw UnimplementedError();
  }

  @override
  void visitText(Text node) {
    final id = add('t');
    source..writeln('  late Text $id;')..writeln();
    create.writeln('    $id = text(\'${node.escaped}\')');
  }
}
