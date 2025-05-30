import 'package:analyzer/dart/ast/ast.dart' as dart;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/patterns.dart';
import 'package:svelte_ast/src/read/expression.dart';

extension MustacheParser on Parser {
  void _open() {
    throw UnimplementedError('#open');
  }

  void _next() {
    throw UnimplementedError(':next');
  }

  void _special() {
    throw UnimplementedError('@special');
  }

  void _close() {
    throw UnimplementedError('/close');
  }

  void tag() {
    int start = index;

    expect('{');
    allowSpace();

    if (scan('#')) {
      _open();
    } else if (scan(':')) {
      _next();
    } else if (scan('@')) {
      _special();
    } else if (match('/')) {
      if (!match('/*') && !match('//')) {
        skip('/');
        _close();
      }
    } else {
      dart.Expression expression = readExpression(closingCurlyBracketRe);

      allowSpace();
      expect('}');

      add(ExpressionTag(start: start, end: index, expression: expression));
    }
  }
}
