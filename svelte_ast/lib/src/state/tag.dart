import 'package:analyzer/dart/ast/ast.dart' as dart;
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/read/expression.dart';

final RegExp _eachAsOrEndRe = RegExp('(\\sas|})');

final RegExp _eachCommaOrEndRe = RegExp('(,|})');

final RegExp _eachClosingParenOrEndRe = RegExp('(\\)|})');

extension MustacheParser on Parser {
  void _open(int start) {
    if (scan('if')) {
      expectSpace();

      dart.Expression expression = readExpression('}');
      allowSpace();
      expect('}');

      IfBlock block = IfBlock(start: start, test: expression);
      add(block);
      stack.add(block);
      fragments.add(block.consequent);
    } else if (scan('each')) {
      expectSpace();

      dart.Expression expression = readExpression(_eachAsOrEndRe);

      // In case if `{#each list as item}` parsed as `as` cast.
      //                    ^^^^^^^^^^^^
      if (expression is dart.AsExpression) {
        expression = expression.expression;
        position = expression.end;
      }

      expectSpace();
      expect('as');
      expectSpace();

      dart.DartPattern context = readAssignmentPattern(_eachCommaOrEndRe);
      allowSpace();

      dart.SimpleIdentifier? index;

      if (scan(',')) {
        allowSpace();

        int identifierStart = position;
        String? identifier = readIdentifier();

        if (identifier == null) {
          expectedIdentifier(position);
        }

        index = simpleIdentifier(identifierStart, identifier);
        allowSpace();
      }

      dart.Expression? key;

      if (scan('(')) {
        allowSpace();
        key = readExpression(_eachClosingParenOrEndRe);
        allowSpace();
        expect(')');
      }

      allowSpace();
      expect('}');

      EachBlock block = EachBlock(
        start: start,
        expression: expression,
        context: context,
        index: index,
        key: key,
      );

      add(block);
      stack.add(block);
      fragments.add(block.body);
    } else if (scan('await')) {
      expectSpace();

      dart.Expression expression = readExpression('}');
      allowSpace();

      AwaitBlock block = AwaitBlock(start: start, expression: expression);
      add(block);

      if (scan('then')) {
        if (match('}')) {
          allowSpace();
        } else {
          expectSpace();
          block.value = readAssignmentPattern('}');
          allowSpace();
        }

        Fragment fragment = Fragment();
        block.then = fragment;
        fragments.add(fragment);
      } else if (scan('catch')) {
        if (match('}')) {
          allowSpace();
        } else {
          expectSpace();
          block.error = readAssignmentPattern('}');
          allowSpace();
        }

        Fragment fragment = Fragment();
        block.katch = fragment;
        fragments.add(fragment);
      } else {
        Fragment fragment = Fragment();
        block.pending = fragment;
        fragments.add(fragment);
      }

      stack.add(block);
    } else if (scan('key')) {
      expectSpace();

      dart.Expression expression = readExpression('}');
      allowSpace();
      expect('}');

      KeyBlock block = KeyBlock(start: start, expression: expression);
      add(block);
      stack.add(block);
      fragments.add(block.fragment);
    } else if (scan('snippet')) {
      expectSpace();

      int nameStart = position;
      String? name = readIdentifier();

      if (name == null) {
        expectedIdentifier(nameStart);
      }

      allowSpace();
      expect('(');
      position -= 1;

      // TODO(ast): parse without parens.
      dart.FormalParameterList parameters = readParameters('}');
      position -= 1;

      expect(')');
      allowSpace();
      expect('}');

      SnippetBlock block = SnippetBlock(
        start: start,
        expression: simpleIdentifier(nameStart, name),
        parameters: parameters.parameters,
      );

      add(block);
      stack.add(block);
      fragments.add(block.body);
    } else {
      expectedBlockType(position);
    }
  }

  void _next(int start) {
    Node block = current;

    if (block is IfBlock) {
      if (!scan('else')) {
        expectedToken('{:else} or {:else if ...}', position);
      }

      if (scan('if')) {
        blockInvalidElseIf(start);
      }

      allowSpace();

      Fragment alternate = Fragment();
      fragments.removeLast();
      fragments.add(alternate);

      if (scan('if')) {
        expectSpace();

        dart.Expression test = readExpression('}');
        allowSpace();
        expect('}');

        IfBlock child = IfBlock(start: start, elseIf: true, test: test);
        add(child);
        stack.add(child);
        fragments.removeLast();
        fragments.add(child.consequent);
      } else {
        allowSpace();
        expect('}');
      }
    } else if (block is EachBlock) {
      if (!scan('else')) {
        expectedToken('{:else}', start);
      }

      allowSpace();
      expect('}');

      Fragment fragment = Fragment();
      block.fallback = fragment;
      fragments.removeLast();
      fragments.add(fragment);
    } else if (block is AwaitBlock) {
      if (scan('then')) {
        if (block.then != null) {
          blockDuplicateClause('{:then}', start);
        }

        if (!scan('}')) {
          expectSpace();
          block.value = readAssignmentPattern('}');
          allowSpace();
          expect('}');
        }

        Fragment fragment = Fragment();
        block.then = fragment;
        fragments.removeLast();
        fragments.add(fragment);
      } else if (scan('catch')) {
        if (block.katch != null) {
          blockDuplicateClause('{:catch}', start);
        }

        if (!scan('}')) {
          expectSpace();
          block.error = readAssignmentPattern('}');
          allowSpace();
          expect('}');
        }

        Fragment fragment = Fragment();
        block.katch = fragment;
        fragments.removeLast();
        fragments.add(fragment);
      } else {
        expectedToken('{:then ...} or {:catch ...}', position);
      }
    } else {
      blockInvalidContinuationPlacement(start);
    }
  }

  void _special(int start) {
    if (scan('html')) {
      expectSpace();

      dart.Expression expression = readExpression('}');
      allowSpace();
      expect('}');

      add(HtmlTag(start: start, end: position, expression: expression));
    } else if (scan('debug')) {
      expectSpace();

      List<dart.SimpleIdentifier> identifiers;

      if (scan('}')) {
        identifiers = const <Never>[];
      } else {
        identifiers = readIdentifierList('}');
        allowSpace();
        expect('}');
      }

      add(DebugTag(start: start, end: position, identifiers: identifiers));
    } else if (scan('final')) {
      expectSpace();

      dart.Expression expression = readExpression('}');

      if (expression is! dart.AssignmentExpression &&
          expression is! dart.PatternAssignment) {
        finalTagInvalidExpression(expression.offset, expression.end);
      }

      allowSpace();
      expect('}');

      add(FinalTag(start: start, end: position, expression: expression));
    } else if (scan('render')) {
      expectSpace();

      dart.Expression expression = readExpression('}');

      if (expression is! dart.MethodInvocation) {
        renderTagInvalidExpression(expression.offset, expression.end);
      }

      allowSpace();
      expect('}');

      add(RenderTag(start: start, end: position, expression: expression));
    }
  }

  void _close(int start) {
    Node block = current;

    if (block is IfBlock) {
      expect('if');
      allowSpace();
      expect('}');

      while (block is IfBlock && block.elseIf) {
        block.end = position;
        stack.removeLast();
        block = current;
      }

      block.end = position;
      pop();
      return;
    } else if (block is EachBlock) {
      expect('each');
    } else if (block is AwaitBlock) {
      expect('await');
    } else if (block is KeyBlock) {
      expect('key');
    } else if (block is SnippetBlock) {
      expect('snippet');
    } else if (block is RegularElement) {
      // TODO(ast): handle implicitly closed elements.
      blockUnexpectedClose(start);
    } else {
      blockUnexpectedClose(start);
    }

    allowSpace();
    expect('}');
    block.end = position;
    pop();
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
      dart.Expression expression = readExpression('}');
      allowSpace();
      expect('}');

      add(ExpressionTag(start: start, end: position, expression: expression));
    }
  }
}
