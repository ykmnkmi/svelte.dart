import 'package:test/test.dart';
import 'package:angular_ast/angular_ast.dart';

Iterable<Token> tokenize(String html) {
  return const Lexer().tokenize(html);
}

String untokenize(Iterable<Token> tokens) {
  var buffer = StringBuffer();

  for (var token in tokens) {
    buffer.write(token.lexeme);
  }

  return buffer.toString();
}

void main() {
  group('Lexer', () {
    test('should tokenize plain text', () {
      expect(tokenize('Hello World'), <Token>[Token.text(0, 'Hello World')]);
    });

    test('should tokenize mulitline text', () {
      expect(tokenize('Hello\nWorld'), <Token>[Token.text(0, 'Hello\nWorld')]);
    });

    test('should tokenize escaped text', () {
      expect(tokenize('&lt;div&gt;'), <Token>[Token.text(0, '<div>')]);
    });

    test('should tokenize an HTML element', () {
      expect(tokenize('<div></div>'), <Token>[
        Token.openElementStart(0),
        Token.elementIdentifier(1, 'div'),
        Token.openElementEnd(4),
        Token.closeElementStart(5),
        Token.elementIdentifier(7, 'div'),
        Token.closeElementEnd(10)
      ]);
    });

    test('should tokenize an HTML element that is explicitly void', () {
      expect(tokenize('<hr  />'), <Token>[
        Token.openElementStart(0),
        Token.elementIdentifier(1, 'hr'),
        Token.whitespace(3, '  '),
        Token.openElementEndVoid(5)
      ]);
    });

    test('should tokenize nested HTML elements', () {
      expect(tokenize('<div><span></span></div>'), <Token>[
        Token.openElementStart(0),
        Token.elementIdentifier(1, 'div'),
        Token.openElementEnd(4),
        Token.openElementStart(5),
        Token.elementIdentifier(6, 'span'),
        Token.openElementEnd(10),
        Token.closeElementStart(11),
        Token.elementIdentifier(13, 'span'),
        Token.closeElementEnd(17),
        Token.closeElementStart(18),
        Token.elementIdentifier(20, 'div'),
        Token.closeElementEnd(23)
      ]);
    });

    test('should tokenize HTML elements mixed with plain text', () {
      expect(tokenize('<div >Hello</div>'), <Token>[
        Token.openElementStart(0),
        Token.elementIdentifier(1, 'div'),
        Token.whitespace(4, ' '),
        Token.openElementEnd(5),
        Token.text(6, 'Hello'),
        Token.closeElementStart(11),
        Token.elementIdentifier(13, 'div'),
        Token.closeElementEnd(16)
      ]);
    });

    // This is both easier to write than a large Iterable<NgToken> assertion and
    // also verifies that the tokenizing is stable - that is, you can reproduce
    // the original parsed string from the tokens.
    test('should tokenize a HTML template and untokenize back', () {
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

    test('should tokenize an element with a value-less decorator', () {
      expect(tokenize('<button disabled></button>'), <Token>[
        Token.openElementStart(0),
        Token.elementIdentifier(1, 'button'),
        Token.beforeElementDecorator(7, ' '),
        Token.elementDecorator(8, 'disabled'),
        Token.openElementEnd(16),
        Token.closeElementStart(17),
        Token.elementIdentifier(19, 'button'),
        Token.closeElementEnd(25)
      ]);
    });

    test('should tokenize an element with multiple value-less decorators', () {
      expect(tokenize('<button disabled hidden></button>'), <Token>[
        Token.openElementStart(0),
        Token.elementIdentifier(1, 'button'),
        Token.beforeElementDecorator(7, ' '),
        Token.elementDecorator(8, 'disabled'),
        Token.beforeElementDecorator(16, ' '),
        Token.elementDecorator(17, 'hidden'),
        Token.openElementEnd(23),
        Token.closeElementStart(24),
        Token.elementIdentifier(26, 'button'),
        Token.closeElementEnd(32)
      ]);
    });

    // This is both easier to write than a large Iterable<NgToken> assertion and
    // also verifies that the tokenizing is stable - that is, you can reproduce
    // the original parsed string from the tokens.
    test('should tokenize a HTML template with decorators and back', () {
      const html = r'''
      <div>
        <span hidden>Hello World</span>
        <ul>
          <li>1</li>
          <li>2</li>
          <li>
            <button disabled>3</button>
          </li>
        </ul>
      </div>
    ''';
      expect(untokenize(tokenize(html)), html);
    });

    test('should tokenize an element with a decorator with a value', () {
      expect(tokenize('<button title =  "Submit"  ></button>'), <Token>[
        Token.openElementStart(0),
        Token.elementIdentifier(1, 'button'),
        Token.beforeElementDecorator(7, ' '),
        Token.elementDecorator(8, 'title'),
        Token.whitespace(13, ' '),
        Token.beforeElementDecoratorValue(14),
        Token.whitespace(15, '  '),
        AttributeValueToken.generate(
            Token.doubleQuote(17), Token.elementDecoratorValue(18, 'Submit'), Token.doubleQuote(24)),
        Token.whitespace(25, '  '),
        Token.openElementEnd(27),
        Token.closeElementStart(28),
        Token.elementIdentifier(30, 'button'),
        Token.closeElementEnd(36)
      ]);
    });

    test('should tokenize an element with a namespaced attribute', () {
      expect(tokenize('<use xlink:href="foo"></use>'), <Token>[
        Token.openElementStart(0),
        Token.elementIdentifier(1, 'use'),
        Token.beforeElementDecorator(4, ' '),
        Token.elementDecorator(5, 'xlink:href'),
        Token.beforeElementDecoratorValue(15),
        AttributeValueToken.generate(
            Token.doubleQuote(16), Token.elementDecoratorValue(17, 'foo'), Token.doubleQuote(20)),
        Token.openElementEnd(21),
        Token.closeElementStart(22),
        Token.elementIdentifier(24, 'use'),
        Token.closeElementEnd(27)
      ]);
    });

    // This is both easier to write than a large Iterable<NgToken> assertion and
    // also verifies that the tokenizing is stable - that is, you can reproduce
    // the original parsed string from the tokens.
    test('should tokenize a HTML template with decorator values and back', () {
      const html = r'''
      <div>
        <span hidden>Hello World</span>
        <ul>
          <li>1</li>
          <li>
            <textarea disabled name  =  "box" readonly>Test</textarea>
          </li>
          <li>
            <button disabled>3</button>
          </li>
        </ul>
      </div>
    ''';
      expect(untokenize(tokenize(html)), html);
    });

    test('should tokenize a comment', () {
      expect(tokenize('<!--Hello World-->'),
          <Token>[Token.commentStart(0), Token.commentValue(4, 'Hello World'), Token.commentEnd(15)]);
    });

    test('should tokenize copyright comments', () {
      expect(
          tokenize(''
              '<!--\n'
              '  Copyright (c) 2016, the Dart project authors.\n'
              '-->'),
          <Token>[
            Token.commentStart(0),
            Token.commentValue(4, '\n  Copyright (c) 2016, the Dart project authors.\n'),
            Token.commentEnd(53)
          ]);
    });

    test('should tokenize interpolation', () {
      expect(tokenize('{{name}}'),
          <Token>[Token.interpolationStart(0), Token.interpolationValue(2, 'name'), Token.interpolationEnd(6)]);
    });

    test('should tokenize function call interpolations', () {
      expect(tokenize('{{msgCharacterCounter(inputTextLength, maxCount)}}'), <Token>[
        Token.interpolationStart(0),
        Token.interpolationValue(2, 'msgCharacterCounter(inputTextLength, maxCount)'),
        Token.interpolationEnd(48)
      ]);
    });

    test('should tokenize an HTML element with property binding', () {
      expect(tokenize('<div [style.max-height.px]  =  "contentHeight"></div>'), <Token>[
        Token.openElementStart(0),
        Token.elementIdentifier(1, 'div'),
        Token.beforeElementDecorator(4, ' '),
        Token.propertyPrefix(5),
        Token.elementDecorator(6, 'style.max-height.px'),
        Token.propertySuffix(25),
        Token.whitespace(26, '  '),
        Token.beforeElementDecoratorValue(28),
        Token.whitespace(29, '  '),
        AttributeValueToken.generate(
            Token.doubleQuote(31), Token.elementDecoratorValue(32, 'contentHeight'), Token.doubleQuote(45)),
        Token.openElementEnd(46),
        Token.closeElementStart(47),
        Token.elementIdentifier(49, 'div'),
        Token.closeElementEnd(52)
      ]);
    });

    test('should tokenize an HTML element with a namespaced attr binding', () {
      expect(tokenize('<use [attr.xlink:href]="foo"></use>'), <Token>[
        Token.openElementStart(0),
        Token.elementIdentifier(1, 'use'),
        Token.beforeElementDecorator(4, ' '),
        Token.propertyPrefix(5),
        Token.elementDecorator(6, 'attr.xlink:href'),
        Token.propertySuffix(21),
        Token.beforeElementDecoratorValue(22),
        AttributeValueToken.generate(
            Token.doubleQuote(23), Token.elementDecoratorValue(24, 'foo'), Token.doubleQuote(27)),
        Token.openElementEnd(28),
        Token.closeElementStart(29),
        Token.elementIdentifier(31, 'use'),
        Token.closeElementEnd(34)
      ]);
    });

    test('should tokenize an HTML element with event binding', () {
      expect(tokenize('<div (someEvent.someInnerValue)  =  "x + 5"></div>'), <Token>[
        Token.openElementStart(0),
        Token.elementIdentifier(1, 'div'),
        Token.beforeElementDecorator(4, ' '),
        Token.eventPrefix(5),
        Token.elementDecorator(6, 'someEvent.someInnerValue'),
        Token.eventSuffix(30),
        Token.whitespace(31, '  '),
        Token.beforeElementDecoratorValue(33),
        Token.whitespace(34, '  '),
        AttributeValueToken.generate(
            Token.doubleQuote(36), Token.elementDecoratorValue(37, 'x + 5'), Token.doubleQuote(42)),
        Token.openElementEnd(43),
        Token.closeElementStart(44),
        Token.elementIdentifier(46, 'div'),
        Token.closeElementEnd(49)
      ]);
    });

    test('should tokenize an HTML element with banana binding', () {
      expect(tokenize('<div [(banana)]="doSomething"></div>'), [
        Token.openElementStart(0),
        Token.elementIdentifier(1, 'div'),
        Token.beforeElementDecorator(4, ' '),
        Token.bananaPrefix(5),
        Token.elementDecorator(7, 'banana'),
        Token.bananaSuffix(13),
        Token.beforeElementDecoratorValue(15),
        AttributeValueToken.generate(
            Token.doubleQuote(16), Token.elementDecoratorValue(17, 'doSomething'), Token.doubleQuote(28)),
        Token.openElementEnd(29),
        Token.closeElementStart(30),
        Token.elementIdentifier(32, 'div'),
        Token.closeElementEnd(35),
      ]);
    });

    test('should tokenize elementDecorator ending in period', () {
      expect(tokenize('<div blah.>'), <Token>[
        Token.openElementStart(0),
        Token.elementIdentifier(1, 'div'),
        Token.beforeElementDecorator(4, ' '),
        Token.elementDecorator(5, 'blah.'),
        Token.openElementEnd(10)
      ]);
    });
  });
}
