import 'package:analyzer/dart/ast/ast.dart' show AssignmentExpression;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/read.dart';

extension MustacheParser on Parser {
  Node mustache() {
    var start = position;
    expect('{');
    allowSpace();

    if (scan('@const')) {
      allowSpace(required: true);

      var expression = readExpression();

      if (expression is! AssignmentExpression) {
        error(invalidConstArgs, start);
      }

      allowSpace();
      expect('}');

      return ConstTag(
        start: start,
        end: position,
        expression: expression,
      );
    }

    var expression = readExpression();
    allowSpace();
    expect('}');

    return MustacheTag(
      start: start,
      end: position,
      expression: expression,
    );
  }
}
