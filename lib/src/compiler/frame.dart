import '../utils.dart';

class Frame {
  Frame()
      : ids = <String, int>{},
        variables = <String>{},
        expressions = <String, String>{},
        created = StringBuffer(),
        mounted = StringBuffer();

  final Map<String, int> ids;

  final Set<String> variables;

  final Map<String, String> expressions;

  final StringBuffer created;

  final StringBuffer mounted;

  String variable(String type) {
    if (!ids.containsKey(type)) {
      ids[type] = 0;
    }

    final name = 'text${ids[type]}';
    ids[type] += 1;
    variables.add(name);
    return name;
  }

  void text(String text, [String parent]) {
    final name = variable('text');

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
    final name = variable('text');

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
