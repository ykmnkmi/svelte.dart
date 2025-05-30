import 'package:analyzer/dart/ast/ast.dart' as dart;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/patterns.dart';
import 'package:svelte_ast/src/read/expression.dart';

final RegExp _eachAsRe = RegExp('\\s+as');

final RegExp _eachAsOrIndexOrKeyOrEndRe = RegExp(
  '(\\s+as|\\s*,|\\s*\\(|\\s*})',
);

final RegExp _eachIndexOrKeyOrEndRe = RegExp('(\\s*,|\\s*\\(|\\s*})');

extension MustacheParser on Parser {
  void _open(int start) {
    if (scan('if')) {
      expectSpace();

      dart.Expression expression = readExpression(closingCurlyBracketRe);
      expect(closingCurlyBracketRe);

      IfBlock block = IfBlock(
        start: start,
        test: expression,
        consequent: Fragment(),
      );

      stack.add(block);
      fragments.add(block.consequent);
      return;
    }

    if (scan('each')) {
      expectSpace();

      dart.Expression expression = readExpression(_eachAsOrIndexOrKeyOrEndRe);

      if (expression is dart.AsExpression) {
        expression = expression.expression;
        index = expression.end;
      }

      expectSpace();
      expect('as');
      expectSpace();

      dart.DartPattern context = readAssignmentPattern(_eachIndexOrKeyOrEndRe);
      print(context);

      throw UnimplementedError('each');
    }

    throw UnimplementedError('open');
  }

  void _next(int start) {
    throw UnimplementedError(':next');
  }

  void _special(int start) {
    throw UnimplementedError('@special');
  }

  void _close(int start) {
    throw UnimplementedError('/close');
  }

  void tag(int start) {
    allowSpace();

    if (scan('#')) {
      _open(start);
    } else if (scan(':')) {
      _next(start);
    } else if (scan('@')) {
      _special(start);
    } else if (match('/')) {
      if (!match('/*') && !match('//')) {
        skip('/');
        _close(start);
      }
    } else {
      dart.Expression expression = readExpression(closingCurlyBracketRe);

      allowSpace();
      expect('}');

      add(ExpressionTag(start: start, end: index, expression: expression));
    }
  }
}
