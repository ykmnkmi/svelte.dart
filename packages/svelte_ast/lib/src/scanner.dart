// ignore_for_file: constant_identifier_names, depend_on_referenced_packages, implementation_imports

import 'package:_fe_analyzer_shared/src/scanner/characters.dart';
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart';
import 'package:_fe_analyzer_shared/src/scanner/token.dart';
import 'package:_fe_analyzer_shared/src/scanner/token_constants.dart';
import 'package:analyzer/dart/analysis/features.dart' show FeatureSet;
import 'package:analyzer/src/dart/scanner/scanner.dart' as dart show Scanner;

enum ScannerState {
  tagStart,
  tag,
  mustache,
  data,
}

bool _isTagNameStartChar(int char) {
  return $A <= char && char <= $Z || $a <= char && char <= $z;
}

bool _isTagNameChar(int char) {
  return $A <= char && char <= $Z ||
      $a <= char && char <= $z ||
      $0 <= char && char <= $9 ||
      char == $MINUS ||
      char == $COLON;
}

bool _isTagSpace(int char) {
  return char == $SPACE || char == $TAB || char == $LF || char == $CR;
}

class SvelteToken extends SimpleToken {
  static const TokenType DATA =
      TokenType(200, '', 'DATA', NO_PRECEDENCE, STRING_TOKEN);
  static const TokenType LT_SLASH =
      TokenType(201, '</', 'LT_SLASH', NO_PRECEDENCE, STRING_TOKEN);
  static const TokenType SLASH_GT =
      TokenType(202, '/>', 'SLASH_GT', NO_PRECEDENCE, STRING_TOKEN);
  static const TokenType TAG_SPACE =
      TokenType(203, ' ', 'TAG_SPACE', NO_PRECEDENCE, STRING_TOKEN);
  static const TokenType TAG_IDENTIFIER =
      TokenType(204, '', 'TAG_IDENTIFIER', NO_PRECEDENCE, STRING_TOKEN);

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

  void appendDataToken() {
    if (tokenStart < scanOffset) {
      appendToken(SvelteStringToken.data(string, tokenStart, scanOffset));
    }
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

      if (next < 0x1f) {
        return unexpected(next);
      }

      next = currentAsUnicode(next);
      return unexpected(next);
    }

    if (state == ScannerState.tagStart) {
      if (identical(peek(), $SLASH)) {
        appendToken(SvelteToken(SvelteToken.LT_SLASH, tokenStart));
        next = advance();
      } else {
        appendPrecedenceToken(TokenType.LT);
      }

      next = advance();

      if (_isTagNameStartChar(next)) {
        beginToken();
        next = advance();

        while (_isTagNameChar(next)) {
          next = advance();
        }

        String value = string.substring(tokenStart, scanOffset);
        appendToken(SvelteToken(SvelteToken.TAG_IDENTIFIER, tokenStart, value));
        state = ScannerState.tag;
      }

      return next;
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

      throw UnimplementedError('tag');
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
