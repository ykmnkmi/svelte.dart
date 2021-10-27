import 'package:test/test.dart';
import 'package:angular_ast/angular_ast.dart';
import 'package:angular_ast/src/expression/micro/ast.dart';
import 'package:angular_ast/src/expression/micro/parser.dart';
import 'package:angular_ast/src/parser_exception.dart';

MicroAST parse(String directive, String expression, int offset) {
  return const MicroParser()
      .parse(directive, expression, offset, sourceUrl: '/test/expression/micro/parser_test.dart#inline');
}

void main() {
  group('MicroParser', () {
    test('should parse a simple let', () {
      expect(parse('ngThing', 'let foo', 0), MicroAST(<LetBinding>[LetBinding('foo')], <Property>[]));
    });

    test('should parse a let assignment', () {
      expect(parse('ngThing', 'let foo = bar; let baz', 0),
          MicroAST(<LetBinding>[LetBinding('foo', 'bar'), LetBinding('baz')], <Property>[]));
    });

    test('should parse a simple let and a let assignment', () {
      expect(parse('ngThing', 'let baz; let foo = bar', 0),
          MicroAST(<LetBinding>[LetBinding('baz'), LetBinding('foo', 'bar')], <Property>[]));
    });

    test('should parse a simple let and a let assignment with extra spaces', () {
      expect(parse('ngThing', 'let baz; let foo = bar ', 0),
          MicroAST(<LetBinding>[LetBinding('baz'), LetBinding('foo', 'bar')], <Property>[]));
    });

    test('should parse a let with a full Dart expression', () {
      expect(
        parse('ngFor', 'let x of items.where(filter)', 0),
        MicroAST(<LetBinding>[LetBinding('x')], <Property>[Property('ngForOf', 'items.where(filter)')]),
      );
    });

    test('should parse a let/bind pair', () {
      expect(
        parse('ngFor', 'let item of items; trackBy: byId', 0),
        MicroAST(<LetBinding>[LetBinding('item')],
            <Property>[Property('ngForOf', 'items'), Property('ngForTrackBy', 'byId')]),
      );
    });

    test('should parse multiple binds', () {
      expect(
        parse('ngTemplateOutlet', 'templateRef; context: templateContext', 0),
        MicroAST(<LetBinding>[], <Property>[
          Property('ngTemplateOutlet', 'templateRef'),
          Property('ngTemplateOutletContext', 'templateContext')
        ]),
      );
    });

    test('should throw a parser error on trailing semi-colon', () {
      expect(() => parse('ngFor', 'let item of items;', 0), throwsA(TypeMatcher<ParserException>()));
    });
  });
}
