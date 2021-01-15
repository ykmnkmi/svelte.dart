import '../utils.dart';

class Frame {
  Frame(this.name)
      : ids = <String, int>{},
        variables = <String, String>{},
        expressions = <String, String>{},
        created = StringBuffer(),
        mounted = StringBuffer();

  final String name;

  final Map<String, int> ids;

  final Map<String, String> variables;

  final Map<String, String> expressions;

  final StringBuffer created;

  final StringBuffer mounted;

  String compile() {
    final clazz = '${name}Fragemnt';
    final buffer = StringBuffer()
      ..writeln('class $clazz extends Fragment<$name> {')
      ..writeln('$clazz($name context): super(context);')
      ..writeln('}');
    return buffer.toString();
  }

  String variable(String type) {
    final normalType = type.toLowerCase();

    if (!ids.containsKey(normalType)) {
      ids[normalType] = 0;
    }

    final name = '$normalType${ids[normalType]}';
    ids[normalType] += 1;
    variables[name] = type;
    return name;
  }

  void text(String text, [String parent]) {
    final name = variable('Text');

    if (text.trim() == '') {
      created.writeln('$name = space();');
    } else {
      created.writeln('$name = text(${text.toLiteral()});');
    }

    if (parent == null) {
      mounted.writeln('insert(target, $name);');
    } else {
      mounted.writeln('append($parent, $name);');
    }
  }

  void interpolation(String interpolation, [String parent]) {
    final name = variable('Text');

    if (interpolation.isIdentifier) {
      created.writeln('$name = text($interpolation);');
    } else {
      final value = '${name}Value';
      expressions[value] = interpolation;
      created.writeln('$name = text($value);');
    }

    if (parent == null) {
      mounted.writeln('insert(target, $name);');
    } else {
      mounted.writeln('append($parent, $name);');
    }
  }
}
