import 'package:analyzer/dart/ast/ast.dart'
    show AssignmentExpression, SimpleIdentifier;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/read.dart';

final RegExp comma = RegExp('\\s*,\\s*');

extension MustacheParser on Parser {
  Node mustache() {
    var start = position;
    expect('{');
    allowSpace();

    if (scan('#')) {
      return statement(start);
    }

    if (scan('@debug')) {
      return debugTag(start);
    }

    if (scan('@const')) {
      return constTag(start);
    }

    return expression(start);
  }

  Statement statement(int start) {
    if (scan('if')) {
      return ifStatement(start);
    }

    error(expectedBlockType);
  }

  Statement ifStatement(int start) {
    allowSpace(required: true);
    readExpression();
    allowSpace();
    expect('}');

    throw UnimplementedError();
  }

  DebugTag debugTag(int start) {
    var identifiers = <SimpleIdentifier>[];

    if (!scan(closeCurlRe)) {
      allowSpace(required: true);

      do {
        var expression = readExpression();

        if (expression is! SimpleIdentifier) {
          error(invalidDebugArgs, start);
        }

        identifiers.add(expression);
      } while (scan(comma));

      allowSpace();
      expect('}');
    }

    return DebugTag(
      start: start,
      end: position,
      identifiers: identifiers,
    );
  }

  ConstTag constTag(int start) {
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

  MustacheTag expression(int start) {
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
