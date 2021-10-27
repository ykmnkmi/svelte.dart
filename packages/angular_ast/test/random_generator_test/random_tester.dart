import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as path;
import 'package:angular_ast/angular_ast.dart';
import 'package:angular_ast/src/token/tokens.dart';

enum State {
  comment,
  element,
  interpolation,
  text,
}

const List<SimpleTokenType> elementMap = <SimpleTokenType>[
  SimpleTokenType.backSlash,
  SimpleTokenType.bang,
  SimpleTokenType.closeBanana,
  SimpleTokenType.closeBracket,
  SimpleTokenType.closeParen,
  SimpleTokenType.commentBegin, //Shift state
  SimpleTokenType.dash,
  SimpleTokenType.doubleQuote, // special
  SimpleTokenType.openTagStart,
  SimpleTokenType.tagEnd,
  SimpleTokenType.equalSign,
  SimpleTokenType.forwardSlash,
  SimpleTokenType.hash,
  SimpleTokenType.identifier,
  SimpleTokenType.openBanana,
  SimpleTokenType.openBracket,
  SimpleTokenType.openParen,
  SimpleTokenType.percent,
  SimpleTokenType.period,
  SimpleTokenType.singleQuote, //Special
  SimpleTokenType.star,
  SimpleTokenType.unexpectedChar,
  SimpleTokenType.voidCloseTag,
];

const List<SimpleTokenType> textMap = <SimpleTokenType>[
  SimpleTokenType.commentBegin,
  SimpleTokenType.openTagStart,
  SimpleTokenType.closeTagStart,
  SimpleTokenType.mustacheBegin,
  SimpleTokenType.text,
];

SimpleTokenType generateRandomSimple(State state) {
  var rng = Random();

  switch (state) {
    case State.comment:
      if (rng.nextInt(100) <= 20) {
        return SimpleTokenType.text;
      }

      return SimpleTokenType.commentEnd;
    case State.element:
      var i = rng.nextInt(elementMap.length);
      return elementMap[i];
    case State.interpolation:
      if (rng.nextInt(100) <= 20) {
        return SimpleTokenType.text;
      }

      return SimpleTokenType.mustacheEnd;
    case State.text:
      var i = rng.nextInt(textMap.length);
      return textMap[i];
    default:
      return SimpleTokenType.unexpectedChar;
  }
}

String generateHtmlString() {
  var state = State.text;
  var buffer = StringBuffer();
  var identifierCount = 0;

  for (var i = 0; i < 10000; i++) {
    var type = generateRandomSimple(state);

    switch (state) {
      case State.comment:
        if (type == SimpleTokenType.commentEnd) {
          state = State.text;
          buffer.write(SimpleToken.lexemeMap[type]);
        } else {
          buffer.write(' some comment');
        }

        break;
      case State.element:
        if (type == SimpleTokenType.commentBegin) {
          state = State.comment;
          buffer.write(SimpleToken.lexemeMap[type]);
        } else if (type == SimpleTokenType.doubleQuote) {
          buffer.write('"someDoubleQuoteValue"');
        } else if (type == SimpleTokenType.singleQuote) {
          buffer.write("'someSingleQuoteValue'");
        } else if (type == SimpleTokenType.identifier) {
          buffer.write('ident${identifierCount.toString()}');
          identifierCount++;
        } else if (type == SimpleTokenType.whitespace) {
          buffer.write(' ');
        } else if (type == SimpleTokenType.voidCloseTag || type == SimpleTokenType.tagEnd) {
          state = State.text;
          buffer.write(SimpleToken.lexemeMap[type]);
        } else {
          buffer.write(SimpleToken.lexemeMap[type]);
        }

        break;
      case State.interpolation:
        if (type == SimpleTokenType.mustacheEnd) {
          state = State.text;
          buffer.write(SimpleToken.lexemeMap[type]);
        } else {
          buffer.write(' + 1 + 2');
        }

        break;
      case State.text:
        if (type == SimpleTokenType.commentBegin) {
          state = State.comment;
          buffer.write(SimpleToken.lexemeMap[type]);
        } else if (type == SimpleTokenType.openTagStart || type == SimpleTokenType.closeTagStart) {
          state = State.element;
          buffer.write(SimpleToken.lexemeMap[type]);
        } else if (type == SimpleTokenType.mustacheBegin) {
          state = State.interpolation;
          buffer.write('${SimpleToken.lexemeMap[type]}0');
        } else {
          buffer.write('lorem ipsum');
        }

        break;
      default:
        buffer.write('');
    }
  }

  return buffer.toString();
}

String untokenize(Iterable<Token> tokens) {
  return tokens.fold(StringBuffer(), (buffer, token) => (buffer as StringBuffer)..write(token.lexeme)).toString();
}

void main() {
  var dir = path.join('test', 'random_generator_test');
  var totalIncorrectLength = 0;
  var totalLexerTime = 0;
  var totalParserTime = 0;

  for (var i = 0; i < 100; i++) {
    print('Iteration $i of 100 ...');
    var stopwatch = Stopwatch();

    var incorrectHtml = generateHtmlString();
    totalIncorrectLength += incorrectHtml.length;
    File(path.join(dir, 'incorrect.html')).writeAsStringSync(incorrectHtml);

    stopwatch.reset();
    stopwatch.start();
    var lexerTokens = const Lexer().tokenize(incorrectHtml);
    stopwatch.stop();
    totalLexerTime += stopwatch.elapsedMicroseconds;
    var lexerFixedString = untokenize(lexerTokens);
    File(path.join(dir, 'lexer_fixed.html')).writeAsStringSync(lexerFixedString);

    stopwatch.reset();
    stopwatch.start();
    var ast = const Parser().parse(incorrectHtml, sourceUrl: '/test/parser_test.dart#inline', desugar: false);
    stopwatch.stop();
    totalParserTime += stopwatch.elapsedMilliseconds;
    var visitor = const HumanizingTemplateAstVisitor();
    var fixedString = ast.map((t) => t.accept(visitor)).join('');
    File(path.join(dir, 'ast_fixed.html')).writeAsStringSync(fixedString);
  }

  print('Total lines scanned/parsed: $totalIncorrectLength');
  print('Total time for lexer: $totalLexerTime microseconds');
  print('Total time for parser: $totalParserTime ms');
}

// ignore_for_file: avoid_print
