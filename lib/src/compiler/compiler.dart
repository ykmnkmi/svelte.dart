abstract class Compiler {
  Compiler(this.name, [this.exports = const <String>[]])
      : buffer = StringBuffer(),
        fields = <String>[],
        initialized = <String>[],
        constructed = <String>[],
        created = <String>[],
        mounted = <String>[],
        listened = <String>[],
        removed = <String>[],
        counts = <String, int>{};

  final String name;

  final List<String> exports;

  final StringBuffer buffer;

  final List<String> fields;

  final List<String> initialized;

  final List<String> constructed;

  final List<String> created;

  final List<String> mounted;

  final List<String> listened;

  final List<String> removed;

  final Map<String, int> counts;

  String getId(String tag) {
    var id = counts[tag] ??= 0;
    counts[tag] = ++id;
    return '$tag$id';
  }

  void mount(String id, [String? context]) {
    if (context == null) {
      mounted.add('insert(target, $id, anchor)');
    } else {
      mounted.add('append($context, $id)');
    }
  }

  int indent = 0;

  void tab() {
    indent += 1;
  }

  void untab() {
    indent -= 1;
  }

  void newline() {
    buffer.writeln();
  }

  void pad() {
    buffer.write('  ' * indent);
  }

  void write(String string) {
    buffer.write(string);
  }

  void line(String string) {
    pad();
    write(string);
    newline();
  }

  String compile() {
    if (listened.isNotEmpty) {
      initialized.add('mounted = false');
      fields
        ..add('bool mounted')
        ..add('late ${listened.length == 1 ? 'Function' : 'List<Function>'} dispose');
    }

    initialized.add('super(context, tree)');

    var className = '${name}Fragment';
    line('class $className extends Fragment<$name> {');
    tab();
    line('$className($name context, RenderTree tree)');
    tab();
    tab();
    pad();
    write(': ${initialized.first}');

    if (initialized.length > 1) {
      tab();

      for (var expression in initialized.skip(1)) {
        write(',');
        newline();
        pad();
        write(expression);
      }

      untab();
    }

    untab();

    if (constructed.isEmpty) {
      write(';');
      untab();
    } else {
      write(' {');

      for (var expression in constructed) {
        newline();
        pad();
        write('$expression;');
      }

      newline();
      untab();
      pad();
      write('}');
    }

    newline();
    newline();

    for (var field in fields) {
      line('$field;');
    }

    if (created.isNotEmpty) {
      newline();
      line('@override');
      line('void create() {');
      tab();

      for (var expression in created) {
        line('$expression;');
      }

      untab();
      line('}');
    }

    if (mounted.isNotEmpty) {
      newline();
      line('@override');
      line('void mount(Element target, [Node? anchor]) {');
      tab();

      for (var expression in mounted) {
        line('$expression;');
      }

      if (listened.isNotEmpty) {
        newline();
        line('if (!mounted) {');
        tab();
        pad();
        write('dispose = ');

        if (listened.length == 1) {
          write(listened.first);
        } else {
          write('<Function>[');
          newline();
          tab();

          for (var expression in listened) {
            line('$expression;');
          }

          untab();
          write(']');
        }

        write(';');
        newline();
        untab();
        line('}');
      }

      untab();
      line('}');
    }

    if (removed.isNotEmpty) {
      newline();
      line('@override');
      line('void destroy([bool detaching = true]) {');
      tab();
      line('if (detaching) {');
      tab();

      for (var id in removed) {
        line('remove($id);');
      }

      untab();
      line('}');

      if (listened.isNotEmpty) {
        newline();
        line('mounted = false;');

        if (listened.length == 1) {
          line('dispose();');
        } else {
          line('dispose.forEach((fn) => fn());');
        }
      }

      untab();
      line('}');
    }

    untab();
    write('}');
    return buffer.toString();
  }
}
