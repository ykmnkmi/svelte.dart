// ignore_for_file: constant_identifier_names, depend_on_referenced_packages, implementation_imports

import 'package:_fe_analyzer_shared/src/scanner/characters.dart';
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart';
import 'package:_fe_analyzer_shared/src/scanner/token.dart';
import 'package:_fe_analyzer_shared/src/scanner/token_constants.dart';
import 'package:analyzer/dart/analysis/features.dart' show FeatureSet;
import 'package:analyzer/src/dart/scanner/scanner.dart' as dart show Scanner;

enum ScannerState {
  data,
  tagStart,
  tag,
  tagAttributeValue,
  comment,
  mustache,
}

final RegExp spaceOrSlashOrClosingTag = RegExp('(\\s|\\/|>)');

final RegExp tokenEnding = RegExp('[\\s=\\/>"\']');

final RegExp startsWithQuoteCharacters = RegExp('^["\']');

bool _isTagSpace(int char) {
  return char == $SPACE || char == $TAB || char == $LF || char == $CR;
}

class SvelteToken extends SimpleToken {
  static const TokenType DATA =
      TokenType(200, '', 'DATA', NO_PRECEDENCE, STRING_TOKEN);
  static const TokenType COMMENT_START =
      TokenType(201, '<!--', 'COMMENT_START', NO_PRECEDENCE, STRING_TOKEN);
  static const TokenType COMMENT =
      TokenType(202, '-->', 'COMMENT', NO_PRECEDENCE, STRING_TOKEN);
  static const TokenType COMMENT_END =
      TokenType(203, '-->', 'COMMENT_END', NO_PRECEDENCE, STRING_TOKEN);
  static const TokenType LT_SLASH =
      TokenType(204, '</', 'LT_SLASH', NO_PRECEDENCE, STRING_TOKEN);
  static const TokenType SLASH_GT =
      TokenType(205, '/>', 'SLASH_GT', NO_PRECEDENCE, STRING_TOKEN);
  static const TokenType TAG_SPACE =
      TokenType(206, ' ', 'TAG_SPACE', NO_PRECEDENCE, STRING_TOKEN);
  static const TokenType TAG_IDENTIFIER =
      TokenType(207, '', 'TAG_IDENTIFIER', NO_PRECEDENCE, STRING_TOKEN);

  SvelteToken(this.type, int offset, [String? string])
      : lexeme = string ?? type.lexeme,
        super(type, offset);

  @override
  final TokenType type;

  @override
  final String lexeme;
}

class SvelteStringToken extends StringTokenImpl {
  factory SvelteStringToken.data(String data, int start, int end) {
    return SvelteStringToken(SvelteToken.DATA, data, start, end);
  }

  factory SvelteStringToken.comment(String data, int start, int end) {
    return SvelteStringToken(SvelteToken.COMMENT, data, start, end);
  }

  factory SvelteStringToken.space(String data, int start, int end) {
    return SvelteStringToken(SvelteToken.TAG_SPACE, data, start, end);
  }

  SvelteStringToken(this.type, String data, int start, int end)
      : super.fromSubstring(type, data, start, end, start);

  @override
  final TokenType type;
}

class SvelteStringScanner extends StringScanner {
  factory SvelteStringScanner.latest(String string) {
    FeatureSet featureSet = FeatureSet.latestLanguageVersion();
    ScannerConfiguration configuration = dart.Scanner.buildConfig(featureSet);
    return SvelteStringScanner(string, configuration: configuration);
  }

  SvelteStringScanner(super.string, {super.configuration})
      : state = ScannerState.data,
        super(includeComments: true);

  ScannerState state;

  @override
  int advance([int offset = 1]) {
    scanOffset += offset;
    return scanOffset >= string.length ? $EOF : string.codeUnitAt(scanOffset);
  }

  @override
  int peek([int offset = 1]) {
    int index = scanOffset + offset;
    return index >= string.length ? $EOF : string.codeUnitAt(index);
  }

  void appendDataToken() {
    if (tokenStart < scanOffset) {
      appendToken(SvelteStringToken.data(string, tokenStart, scanOffset));
    }
  }

  void appendCommentToken() {
    appendToken(SvelteStringToken.comment(string, tokenStart, scanOffset));
  }

  int appendSpaceToken() {
    int next = advance();

    while (_isTagSpace(next)) {
      next = advance();
    }

    if (tokenStart < scanOffset) {
      appendToken(SvelteStringToken.space(string, tokenStart, scanOffset));
    }

    return next;
  }

  @override
  int bigSwitch(int next, [ScannerState nextState = ScannerState.data]) {
    beginToken();

    if (state == ScannerState.data) {
      while (!atEndOfFile()) {
        if (identical(next, $OPEN_CURLY_BRACKET)) {
          appendDataToken();
          state = ScannerState.mustache;
          return next;
        }

        if (identical(next, $LT)) {
          appendDataToken();
          state = ScannerState.tagStart;
          return next;
        }

        next = advance();
      }

      appendDataToken();
      return next;
    }

    if (state == ScannerState.mustache) {
      if (identical(next, $SPACE) ||
          identical(next, $TAB) ||
          identical(next, $LF) ||
          identical(next, $CR)) {
        appendWhiteSpace(next);
        next = advance();

        // Sequences of spaces are common, so advance through them fast.
        while (identical(next, $SPACE)) {
          // We don't invoke [:appendWhiteSpace(next):] here for efficiency,
          // assuming that it does not do anything for space characters.
          next = advance();
        }

        return next;
      }

      int nextLower = next | 0x20;

      if ($a <= nextLower && nextLower <= $z) {
        if (identical($r, next)) {
          return tokenizeRawStringKeywordOrIdentifier(next);
        }

        return tokenizeKeywordOrIdentifier(next, true);
      }

      if (identical(next, $CLOSE_PAREN)) {
        return appendEndGroup(TokenType.CLOSE_PAREN, OPEN_PAREN_TOKEN);
      }

      if (identical(next, $OPEN_PAREN)) {
        appendBeginGroup(TokenType.OPEN_PAREN);
        return advance();
      }

      if (identical(next, $SEMICOLON)) {
        appendPrecedenceToken(TokenType.SEMICOLON);
        // Type parameters and arguments cannot contain semicolon.
        discardOpenLt();
        return advance();
      }

      if (identical(next, $PERIOD)) {
        return tokenizeDotsOrNumber(next);
      }

      if (identical(next, $COMMA)) {
        appendPrecedenceToken(TokenType.COMMA);
        return advance();
      }

      if (identical(next, $EQ)) {
        return tokenizeEquals(next);
      }

      if (identical(next, $CLOSE_CURLY_BRACKET)) {
        next = appendEndGroup(
            TokenType.CLOSE_CURLY_BRACKET, OPEN_CURLY_BRACKET_TOKEN);

        if (groupingStack.isEmpty) {
          state = nextState;
        }

        return next;
      }

      if (identical(next, $SLASH)) {
        return tokenizeSlashOrComment(next);
      }

      if (identical(next, $OPEN_CURLY_BRACKET)) {
        appendBeginGroup(TokenType.OPEN_CURLY_BRACKET);
        return advance();
      }

      if (identical(next, $DQ) || identical(next, $SQ)) {
        return tokenizeString(next, scanOffset, false);
      }

      if (identical(next, $_)) {
        return tokenizeKeywordOrIdentifier(next, true);
      }

      if (identical(next, $COLON)) {
        appendPrecedenceToken(TokenType.COLON);
        return advance();
      }

      if (identical(next, $LT)) {
        return tokenizeLessThan(next);
      }

      if (identical(next, $GT)) {
        return tokenizeGreaterThan(next);
      }

      if (identical(next, $BANG)) {
        return tokenizeExclamation(next);
      }

      if (identical(next, $OPEN_SQUARE_BRACKET)) {
        return tokenizeOpenSquareBracket(next);
      }

      if (identical(next, $CLOSE_SQUARE_BRACKET)) {
        return appendEndGroup(
            TokenType.CLOSE_SQUARE_BRACKET, OPEN_SQUARE_BRACKET_TOKEN);
      }

      if (identical(next, $AT)) {
        return tokenizeAt(next);
      }

      if (next >= $1 && next <= $9) {
        return tokenizeNumber(next);
      }

      if (identical(next, $AMPERSAND)) {
        return tokenizeAmpersand(next);
      }

      if (identical(next, $0)) {
        return tokenizeHexOrNumber(next);
      }

      if (identical(next, $QUESTION)) {
        return tokenizeQuestion(next);
      }

      if (identical(next, $BAR)) {
        return tokenizeBar(next);
      }

      if (identical(next, $PLUS)) {
        return tokenizePlus(next);
      }

      if (identical(next, $$)) {
        return tokenizeKeywordOrIdentifier(next, true);
      }

      if (identical(next, $MINUS)) {
        return tokenizeMinus(next);
      }

      if (identical(next, $STAR)) {
        return tokenizeMultiply(next);
      }

      if (identical(next, $CARET)) {
        return tokenizeCaret(next);
      }

      if (identical(next, $TILDE)) {
        return tokenizeTilde(next);
      }

      if (identical(next, $PERCENT)) {
        return tokenizePercent(next);
      }

      if (identical(next, $BACKPING)) {
        appendPrecedenceToken(TokenType.BACKPING);
        return advance();
      }

      if (identical(next, $BACKSLASH)) {
        appendPrecedenceToken(TokenType.BACKSLASH);
        return advance();
      }

      if (identical(next, $HASH)) {
        return tokenizeTag(next);
      }

      throw AssertionError('unreachable');
    }

    if (state == ScannerState.tagStart) {
      if (identical(next, $LT)) {
        if (identical(peek(), $SLASH)) {
          appendToken(SvelteToken(SvelteToken.LT_SLASH, tokenStart));
          return advance(2);
        } else {
          appendPrecedenceToken(TokenType.LT);
          return advance();
        }
      }

      if (identical(next, $BANG) &&
          identical(peek(), $MINUS) &&
          identical(peek(2), $MINUS)) {
        appendToken(SvelteToken(SvelteToken.COMMENT_START, tokenStart));
        next = advance(3);
        beginToken();

        int commentEnd = string.indexOf('-->', scanOffset);
        scanOffset = commentEnd == -1 ? string.length : commentEnd;
        appendCommentToken();

        if (string.startsWith('-->', scanOffset)) {
          appendToken(SvelteToken(SvelteToken.COMMENT_END, tokenStart));
          scanOffset += 2;
        }

        return advance();
      }

      int found = string.indexOf(spaceOrSlashOrClosingTag, scanOffset);

      if (found > 0) {
        String value = string.substring(tokenStart, scanOffset = found);
        appendToken(SvelteToken(SvelteToken.TAG_IDENTIFIER, tokenStart, value));
        state = ScannerState.tag;
        return string.codeUnitAt(scanOffset);
      }

      throw AssertionError('tagName');
    }

    if (state == ScannerState.tag) {
      if (_isTagSpace(next)) {
        return appendSpaceToken();
      }

      if (identical(next, $SLASH) && identical(peek(), $GT)) {
        appendToken(SvelteToken(SvelteToken.SLASH_GT, tokenStart));
        state = ScannerState.data;
        next = advance();
        return advance();
      }

      if (identical(next, $GT)) {
        appendPrecedenceToken(TokenType.GT);
        state = ScannerState.data;
        return advance();
      }

      if (string.indexOf(tokenEnding, scanOffset) case int tokenEnd
          when tokenEnd != 1) {
        String value = string.substring(tokenStart, tokenEnd);
        appendToken(SvelteToken(SvelteToken.TAG_IDENTIFIER, tokenStart, value));
        scanOffset = tokenEnd;
        state = ScannerState.tagAttributeValue;
        return string.codeUnitAt(tokenEnd);
      }

      throw AssertionError('unreachable');
    }

    if (state == ScannerState.tagAttributeValue) {
      if (_isTagSpace(next)) {
        next = appendSpaceToken();
      }

      if (identical(next, $EQ)) {
        appendPrecedenceToken(TokenType.EQ);
        next = advance();
      } else if (identical(next, $DQ)) {
        throw UnimplementedError('DQ');
      } else if (identical(next, $SQ)) {
        throw UnimplementedError('SQ');
      } else {
        state = ScannerState.tag;
        return advance();
      }

      if (_isTagSpace(next)) {
        next = appendSpaceToken();
      }

      int nameEnd = string.indexOf(tokenEnding, scanOffset);

      if (nameEnd != -1) {
        String value = string.substring(tokenStart, nameEnd);
        appendToken(SvelteToken(SvelteToken.TAG_IDENTIFIER, tokenStart, value));
        state = ScannerState.tagAttributeValue;
        return advance();
      }

      return next;
    }

    throw UnimplementedError('switch');
  }

  @override
  Token tokenize() {
    int next = advance();

    while (!identical(next, $EOF)) {
      next = bigSwitch(next);
    }

    if (atEndOfFile()) {
      appendEofToken();
    } else {
      unexpectedEof();
    }

    // Always pretend that there's a line at the end of the file.
    // lineStarts.add(stringOffset + 1);
    return firstToken();
  }
}
