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
    writeln('class ${name}Fragment extends Fragment<$name> {');
    writeln('  ${name}Fragment($name context, Scheduler scheduler) : super(context, scheduler);');
    writeln();
    writeFragmentCreate(fragment);
    writeln();
    writeln('}');
  }

  void writeFragmentCreate(Fragment fragment) {
    if (fragment.isEmpty) {
      return;
    }

    FragmentCreate(this, fragment);
  }
}

class FragmentCreate extends Visitor<void> {
  FragmentCreate(this.buffer, this.fragment) {
    for (final child in fragment.children) {
      child.accept(this);
    }
  }

  final StringBuffer buffer;

  final Fragment fragment;

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
    throw UnimplementedError();
  }

  @override
  void visitIdentifier(Identifier node) {
    throw UnimplementedError();
  }

  @override
  void visitText(Text node) {
    throw UnimplementedError();
  }
}
