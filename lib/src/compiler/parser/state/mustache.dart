import 'package:analyzer/dart/ast/ast.dart'
    show AssignmentExpression, SimpleIdentifier;
import 'package:svelte/src/compiler/interface.dart';
import 'package:svelte/src/compiler/parser/errors.dart';
import 'package:svelte/src/compiler/parser/parser.dart';
import 'package:svelte/src/compiler/parser/read/expression.dart';

final RegExp comma = RegExp('\\s*, \\s*');

extension MustacheParser on Parser {
  void mustache() {
    var start = position;
    expect(openCurlRe);

    if (scan('/')) {
      throw UnimplementedError();
    } else if (scan(':')) {
      throw UnimplementedError();
    } else if (scan('#')) {
      throw UnimplementedError();
    } else if (scan('@html')) {
      allowSpace(require: true);

      var expression = readExpression();
      expect(closeCurlRe);

      current.children!.add(Node(
        start: start,
        end: position,
        type: 'RawMustacheTag',
        expression: expression,
      ));
    } else if (scan('@debug')) {
      var identifiers = <SimpleIdentifier>[];

      if (!scan(closeCurlRe)) {
        allowSpace(require: true);

        do {
          var expression = readExpression();

          if (expression is! SimpleIdentifier) {
            invalidDebugArgs(start);
          }

          identifiers.add(expression);
        } while (scan(comma));

        expect(closeCurlRe);
      }

      current.children!.add(Node(
        start: start,
        end: position,
        type: 'DebugTag',
        identifiers: identifiers,
      ));
    } else if (scan('@const')) {
      allowSpace(require: true);

      var expression = readExpression();

      if (expression is! AssignmentExpression ||
          expression.operator.lexeme != '=') {
        error(
          code: 'invalid-const-args',
          message: '{@const ...} must be an assignment',
          position: start,
        );
      }

      expect(closeCurlRe);

      current.children!.add(Node(
        start: start,
        end: position,
        type: 'ConstTag',
        expression: expression,
      ));
    } else {
      var expression = readExpression();
      expect(closeCurlRe);

      current.children!.add(Node(
        start: start,
        end: position,
        type: 'MustacheTag',
        expression: expression,
      ));
    }
  }
}
