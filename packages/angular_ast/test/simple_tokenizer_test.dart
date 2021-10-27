import 'package:test/test.dart';
import 'package:angular_ast/src/simple_tokenizer.dart';
import 'package:angular_ast/src/token/tokens.dart';

Iterable<SimpleToken> tokenize(String html) {
  return const SimpleTokenizer().tokenize(html);
}

String untokenize(Iterable<SimpleToken> tokens) {
  var buffer = StringBuffer();

  for (var token in tokens) {
    buffer.write(token.lexeme);
  }

  return buffer.toString();
}

void main() {
  group('SimpleTokenizer', () {
    test('should tokenize plain text', () {
      expect(tokenize('Hello World'), <SimpleToken>[SimpleToken.text(0, 'Hello World'), SimpleToken.eof(11)]);
    });

    test('should tokenize multiline text', () {
      expect(tokenize('Hello\nWorld'), <SimpleToken>[SimpleToken.text(0, 'Hello\nWorld'), SimpleToken.eof(11)]);
    });

    test('should tokenize an HTML element', () {
      expect(tokenize('''<div></div>'''), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'div'),
        SimpleToken.tagEnd(4),
        SimpleToken.closeTagStart(5),
        SimpleToken.identifier(7, 'div'),
        SimpleToken.tagEnd(10),
        SimpleToken.eof(11)
      ]);
    });

    test('should tokenize an HTML element with dash', () {
      expect(tokenize('''<my-tag></my-tag>'''), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'my-tag'),
        SimpleToken.tagEnd(7),
        SimpleToken.closeTagStart(8),
        SimpleToken.identifier(10, 'my-tag'),
        SimpleToken.tagEnd(16),
        SimpleToken.eof(17)
      ]);
    });

    test('should tokenize an HTML element with local variable', () {
      expect(tokenize('''<div #myDiv></div>'''), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'div'),
        SimpleToken.whitespace(4, ' '),
        SimpleToken.hash(5),
        SimpleToken.identifier(6, 'myDiv'),
        SimpleToken.tagEnd(11),
        SimpleToken.closeTagStart(12),
        SimpleToken.identifier(14, 'div'),
        SimpleToken.tagEnd(17),
        SimpleToken.eof(18)
      ]);
    });

    test('should tokenize an HTML element with void', () {
      expect(tokenize('<hr/>'), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'hr'),
        SimpleToken.voidCloseTag(3),
        SimpleToken.eof(5)
      ]);
    });

    test('should tokenize nested HTML elements', () {
      expect(tokenize('<div><span></span></div>'), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'div'),
        SimpleToken.tagEnd(4),
        SimpleToken.openTagStart(5),
        SimpleToken.identifier(6, 'span'),
        SimpleToken.tagEnd(10),
        SimpleToken.closeTagStart(11),
        SimpleToken.identifier(13, 'span'),
        SimpleToken.tagEnd(17),
        SimpleToken.closeTagStart(18),
        SimpleToken.identifier(20, 'div'),
        SimpleToken.tagEnd(23),
        SimpleToken.eof(24)
      ]);
    });

    test('should tokenize HTML elements mixed with plain text', () {
      expect(tokenize('<div>Hello this is text</div>'), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'div'),
        SimpleToken.tagEnd(4),
        SimpleToken.text(5, 'Hello this is text'),
        SimpleToken.closeTagStart(23),
        SimpleToken.identifier(25, 'div'),
        SimpleToken.tagEnd(28),
        SimpleToken.eof(29)
      ]);
    });

    test('should tokenize an HTML template and untokenize back', () {
      const html = r'''
      <div>
        <span>Hello World</span>
        <ul>
          <li>1</li>
          <li>2</li>
          <li>
            <strong>3</strong>
          </li>
        </ul>
      </div>
    ''';
      expect(untokenize(tokenize(html)), html);
    });

    test('should tokenize an element with a decorator with a value', () {
      expect(tokenize(r'<button title="Submit \"quoted text\""></button>'), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'button'),
        SimpleToken.whitespace(7, ' '),
        SimpleToken.identifier(8, 'title'),
        SimpleToken.equalSign(13),
        SimpleQuoteToken.doubleQuotedText(14, '"Submit \"quoted text\""', true),
        SimpleToken.tagEnd(38),
        SimpleToken.closeTagStart(39),
        SimpleToken.identifier(41, 'button'),
        SimpleToken.tagEnd(47),
        SimpleToken.eof(48)
      ]);
    });

    test('should tokenize an HTML element with bracket and period in decorator', () {
      expect(tokenize('''<my-tag [attr.x]="y"></my-tag>'''), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'my-tag'),
        SimpleToken.whitespace(7, ' '),
        SimpleToken.openBracket(8),
        SimpleToken.identifier(9, 'attr'),
        SimpleToken.period(13),
        SimpleToken.identifier(14, 'x'),
        SimpleToken.closeBracket(15),
        SimpleToken.equalSign(16),
        SimpleQuoteToken.doubleQuotedText(17, '"y"', true),
        SimpleToken.tagEnd(20),
        SimpleToken.closeTagStart(21),
        SimpleToken.identifier(23, 'my-tag'),
        SimpleToken.tagEnd(29),
        SimpleToken.eof(30)
      ]);
    });

    test('should tokenize an HTML element with bracket, period, percentage, and backSlash', () {
      expect(tokenize(r'''<div [style.he\ight.%>'''), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'div'),
        SimpleToken.whitespace(4, ' '),
        SimpleToken.openBracket(5),
        SimpleToken.identifier(6, 'style'),
        SimpleToken.period(11),
        SimpleToken.identifier(12, 'he'),
        SimpleToken.backSlash(14),
        SimpleToken.identifier(15, 'ight'),
        SimpleToken.period(19),
        SimpleToken.percent(20),
        SimpleToken.tagEnd(21),
        SimpleToken.eof(22)
      ]);
    });

    test('should tokenize an HTML element with banana open and close', () {
      expect(tokenize('''<my-tag [(banana)]>'''), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'my-tag'),
        SimpleToken.whitespace(7, ' '),
        SimpleToken.openBanana(8),
        SimpleToken.identifier(10, 'banana'),
        SimpleToken.closeBanana(16),
        SimpleToken.tagEnd(18),
        SimpleToken.eof(19)
      ]);
    });

    test('should tokenize a HTML template with decorator values and back', () {
      const html = r'''
      <div>
        <span hidden>Hello World</span>
        <a href="www.somelink.com/index.html">Click me!</a>
        <!-- some random comment inserted here -->
        <ul>
          <li>1</li>
          <li>
            <textarea disabled name="box" readonly>Test</textarea>
          </li>
          <li>
            <myTag myAttr="some value "literal""></myTag>
            <button disabled [attr.x]="y">3</button>
          </li>
        </ul>
      </div>
    ''';
      expect(untokenize(tokenize(html)), html);
    });

    test('should tokenize a comment', () {
      expect(tokenize('<!--Hello World-->'), <SimpleToken>[
        SimpleToken.commentBegin(0),
        SimpleToken.text(4, 'Hello World'),
        SimpleToken.commentEnd(15),
        SimpleToken.eof(18)
      ]);
    });

    test('should tokenize copyright comments', () {
      expect(
        tokenize(''
            '<!--\n'
            '  Copyright (c) 2016, the Dart project authors.\n'
            '-->'),
        [
          SimpleToken.commentBegin(0),
          SimpleToken.text(
            4,
            '\n  Copyright (c) 2016, the Dart project authors.\n',
          ),
          SimpleToken.commentEnd(53),
          SimpleToken.eof(56),
        ],
      );
    });

    test('should tokenize asterisks', () {
      expect(tokenize('<span *ngIf="some bool"></span>'), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'span'),
        SimpleToken.whitespace(5, ' '),
        SimpleToken.star(6),
        SimpleToken.identifier(7, 'ngIf'),
        SimpleToken.equalSign(11),
        SimpleQuoteToken.doubleQuotedText(12, '"some bool"', true),
        SimpleToken.tagEnd(23),
        SimpleToken.closeTagStart(24),
        SimpleToken.identifier(26, 'span'),
        SimpleToken.tagEnd(30),
        SimpleToken.eof(31)
      ]);
    });

    test('should tokenize at signs', () {
      expect(tokenize('<div @deferred></div>'), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'div'),
        SimpleToken.whitespace(4, ' '),
        SimpleToken.atSign(5),
        SimpleToken.identifier(6, 'deferred'),
        SimpleToken.tagEnd(14),
        SimpleToken.closeTagStart(15),
        SimpleToken.identifier(17, 'div'),
        SimpleToken.tagEnd(20),
        SimpleToken.eof(21)
      ]);
    });

    //Error cases

    test('should tokenize unclosed comments', () {
      expect(
          tokenize(''
              '<!--\n'
              '  Copyright (c) 2016, the Dart project authors.\n'),
          [
            SimpleToken.commentBegin(0),
            SimpleToken.text(
              4,
              '\n  Copyright (c) 2016, the Dart project authors.\n',
            ),
            SimpleToken.eof(53),
          ]);
    });

    test('should tokenize unclosed element tag hitting EOF', () {
      expect(tokenize('<div '), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'div'),
        SimpleToken.whitespace(4, ' '),
        SimpleToken.eof(5)
      ]);
    });

    test('should tokenize unclosed element tags', () {
      expect(
          tokenize(''
              '<div>'
              ' some text stuff here '
              '<span'
              '</div>'),
          [
            SimpleToken.openTagStart(0),
            SimpleToken.identifier(1, 'div'),
            SimpleToken.tagEnd(4),
            SimpleToken.text(5, ' some text stuff here '),
            SimpleToken.openTagStart(27),
            SimpleToken.identifier(28, 'span'),
            SimpleToken.closeTagStart(32),
            SimpleToken.identifier(34, 'div'),
            SimpleToken.tagEnd(37),
            SimpleToken.eof(38),
          ]);
    });

    test('should tokenize dangling double quote', () {
      expect(tokenize('''<div [someInput]=" (someEvent)='do something'>'''), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'div'),
        SimpleToken.whitespace(4, ' '),
        SimpleToken.openBracket(5),
        SimpleToken.identifier(6, 'someInput'),
        SimpleToken.closeBracket(15),
        SimpleToken.equalSign(16),
        SimpleQuoteToken.doubleQuotedText(17, '" (someEvent)=\'do something\'>', false),
        SimpleToken.eof(46)
      ]);
    });

    test('should tokenize dangling single quote', () {
      expect(tokenize('''<div [someInput]=' (someEvent)="do something">'''), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'div'),
        SimpleToken.whitespace(4, ' '),
        SimpleToken.openBracket(5),
        SimpleToken.identifier(6, 'someInput'),
        SimpleToken.closeBracket(15),
        SimpleToken.equalSign(16),
        SimpleQuoteToken.singleQuotedText(17, "' (someEvent)=\"do something\">", false),
        SimpleToken.eof(46)
      ]);
    });

    test('should tokenize unclosed attr hitting EOF', () {
      expect(tokenize('<div someAttr '), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'div'),
        SimpleToken.whitespace(4, ' '),
        SimpleToken.identifier(5, 'someAttr'),
        SimpleToken.whitespace(13, ' '),
        SimpleToken.eof(14)
      ]);
    });

    test('should tokenize unclosed attr value hitting EOF', () {
      expect(tokenize('<div someAttr ='), <SimpleToken>[
        SimpleToken.openTagStart(0),
        SimpleToken.identifier(1, 'div'),
        SimpleToken.whitespace(4, ' '),
        SimpleToken.identifier(5, 'someAttr'),
        SimpleToken.whitespace(13, ' '),
        SimpleToken.equalSign(14),
        SimpleToken.eof(15)
      ]);
    });

    test('should tokenize text beginning with dangling close mustache', () {
      expect(tokenize('}} some text'),
          <SimpleToken>[SimpleToken.mustacheEnd(0), SimpleToken.text(2, ' some text'), SimpleToken.eof(12)]);
    });

    test('should tokenize mustaches despite incorrect ordering', () {
      expect(tokenize('blah {{ blah {{ blah }} blah }} blah {{ blah }}'), <SimpleToken>[
        SimpleToken.text(0, 'blah '),
        SimpleToken.mustacheBegin(5),
        SimpleToken.text(7, ' blah '),
        SimpleToken.mustacheBegin(13),
        SimpleToken.text(15, ' blah '),
        SimpleToken.mustacheEnd(21),
        SimpleToken.text(23, ' blah '),
        SimpleToken.mustacheEnd(29),
        SimpleToken.text(31, ' blah '),
        SimpleToken.mustacheBegin(37),
        SimpleToken.text(39, ' blah '),
        SimpleToken.mustacheEnd(45),
        SimpleToken.eof(47)
      ]);
    });

    test('should tokenize only up to newline with dangling open mustache', () {
      expect(tokenize('{{ some mustache \n unclosed'), <SimpleToken>[
        SimpleToken.mustacheBegin(0),
        SimpleToken.text(2, ' some mustache '),
        SimpleToken.whitespace(17, '\n'),
        SimpleToken.text(18, ' unclosed'),
        SimpleToken.eof(27)
      ]);
    });

    test('should tokenize only up to newline with dangling open mustache2', () {
      expect(tokenize('{{\n  blah'), <SimpleToken>[
        SimpleToken.mustacheBegin(0),
        SimpleToken.whitespace(2, '\n'),
        SimpleToken.text(3, '  blah'),
        SimpleToken.eof(9)
      ]);
    });

    test(
        'should tokenize "<" as expression within '
        'mustache if it begins with "{{"', () {
      expect(tokenize('{{ 5 < 3 }}'), <SimpleToken>[
        SimpleToken.mustacheBegin(0),
        SimpleToken.text(2, ' 5 < 3 '),
        SimpleToken.mustacheEnd(9),
        SimpleToken.eof(11)
      ]);
    });

    test(
        'should tokenize "<" as tag start if '
        'before dangling mustache close', () {
      expect(tokenize(' 5 < 3 }}'), <SimpleToken>[
        SimpleToken.text(0, ' 5 '),
        SimpleToken.openTagStart(3),
        SimpleToken.whitespace(4, ' '),
        SimpleToken.unexpectedChar(5, '3'),
        SimpleToken.whitespace(6, ' '),
        SimpleToken.unexpectedChar(7, '}'),
        SimpleToken.unexpectedChar(8, '}'),
        SimpleToken.eof(9)
      ]);
    });

    test('should tokenize simple doctype declaration', () {
      expect(tokenize('<!DOCTYPE html>'), <SimpleToken>[SimpleToken.text(0, '<!DOCTYPE html>'), SimpleToken.eof(15)]);
    });

    test('should tokenize complicated doctype declaration', () {
      var html = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"'
          ' "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">';
      expect(tokenize(html), <SimpleToken>[SimpleToken.text(0, html), SimpleToken.eof(109)]);
    });

    test('should tokenize long html with doctype', () {
      const html = r'''
<!DOCTYPE html>
<div>
</div>''';
      expect(tokenize(html), <SimpleToken>[
        SimpleToken.text(0, '<!DOCTYPE html>'),
        SimpleToken.text(15, '\n'),
        SimpleToken.openTagStart(16),
        SimpleToken.identifier(17, 'div'),
        SimpleToken.tagEnd(20),
        SimpleToken.text(21, '\n'),
        SimpleToken.closeTagStart(22),
        SimpleToken.identifier(24, 'div'),
        SimpleToken.tagEnd(27),
        SimpleToken.eof(28)
      ]);
    });

    test('should escape named entities', () {
      expect(tokenize('&lt;div&gt;'), <SimpleToken>[SimpleToken.text(0, '<div>'), SimpleToken.eof(11)]);
    });

    test('should escape dec values', () {
      expect(tokenize('&#8721;'), <SimpleToken>[SimpleToken.text(0, '∑'), SimpleToken.eof(7)]);
    });

    test('should escape hex values', () {
      expect(tokenize('&#x2211;'), <SimpleToken>[SimpleToken.text(0, '∑'), SimpleToken.eof(8)]);
    });
  });
}
