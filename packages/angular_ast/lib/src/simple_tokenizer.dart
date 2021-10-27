import 'package:charcode/charcode.dart' show $close_bracket, $dash, $exclamation, $gt, $open_paren, $slash;
import 'package:meta/meta.dart' show literal;
import 'package:string_scanner/string_scanner.dart' show StringScanner;

import 'token/chars.dart';
import 'token/tokens.dart';

enum SimpleScannerState {
  doctype,
  text,
  element,
  comment,
  commentEnd,
  interpolation,
}

class SimpleTokenizer {
  @literal
  const SimpleTokenizer();

  Iterable<SimpleToken> tokenize(String template) sync* {
    var scanner = SimpleScanner(template);
    scanner.resetState();
    var token = scanner.scan();

    while (token.type != SimpleTokenType.eof) {
      yield token;
      token = scanner.scan();
    }

    yield token; // Explicitly yield the EOF token.
  }
}

class SimpleScanner {
  SimpleScanner(String html, {Object? sourceUrl})
      : scanner = StringScanner(html, sourceUrl: sourceUrl),
        state = SimpleScannerState.doctype;

  final StringScanner scanner;

  SimpleScannerState state;

  SimpleToken scan() {
    switch (state) {
      case SimpleScannerState.comment:
        return scanComment();
      case SimpleScannerState.commentEnd:
        return scanCommentEnd();
      case SimpleScannerState.doctype:
        return scanDoctype();
      case SimpleScannerState.element:
        return scanElement();
      case SimpleScannerState.text:
        return scanText();
      case SimpleScannerState.interpolation:
        return scanInterpolation();
    }
  }

  SimpleToken scanComment() {
    var offset = scanner.position;

    while (true) {
      if (scanner.peekChar() == $dash && scanner.peekChar(1) == $dash && scanner.peekChar(2) == $gt) {
        break;
      }

      if (scanner.position < scanner.string.length) {
        scanner.position++;
      }

      if (scanner.isDone) {
        state = SimpleScannerState.text;
        var substring = scanner.string.substring(offset);
        return newTextToken(offset, substring);
      }
    }

    state = SimpleScannerState.commentEnd;
    return newTextToken(offset, scanner.substring(offset));
  }

  SimpleToken scanCommentEnd() {
    var offset = scanner.position;
    scanner.scan(commentEnd);
    state = SimpleScannerState.text;
    return SimpleToken.commentEnd(offset);
  }

  SimpleToken scanDoctype() {
    var offset = scanner.position;

    if (scanner.isDone) {
      return SimpleToken.eof(offset);
    }

    state = SimpleScannerState.text;

    if (scanner.scan(doctypeBegin)) {
      // DOCTYPE declaration exists
      var text = scanner.string.substring(scanner.position);
      var endOffset = scanner.string.length;
      var match = gt.firstMatch(text);

      if (match != null) {
        endOffset = scanner.position + match.end;
      }

      scanner.position = endOffset;
      return newTextToken(offset, scanner.string.substring(offset, endOffset));
    }

    return scanText();
  }

  SimpleToken scanElement() {
    var offset = scanner.position;

    if (scanner.isDone) {
      return SimpleToken.eof(offset);
    }

    if (scanner.scan(allElementMatches)) {
      var match = scanner.lastMatch!;

      if (matchesGroup(match, 1)) {
        return SimpleToken.closeBracket(offset);
      }

      if (matchesGroup(match, 2)) {
        return SimpleToken.bang(offset);
      }

      if (matchesGroup(match, 3)) {
        return SimpleToken.dash(offset);
      }

      if (matchesGroup(match, 4)) {
        if (scanner.peekChar() == $close_bracket) {
          scanner.position++;
          return SimpleToken.closeBanana(offset);
        }

        return SimpleToken.closeParen(offset);
      }

      if (matchesGroup(match, 5)) {
        state = SimpleScannerState.text;
        return SimpleToken.tagEnd(offset);
      }

      if (matchesGroup(match, 6)) {
        if (scanner.peekChar() == $gt) {
          scanner.position++;
          state = SimpleScannerState.text;
          return SimpleToken.voidCloseTag(offset);
        }

        return SimpleToken.forwardSlash(offset);
      }

      if (matchesGroup(match, 7)) {
        if (scanner.peekChar() == $open_paren) {
          scanner.position++;
          return SimpleToken.openBanana(offset);
        }

        return SimpleToken.openBracket(offset);
      }

      if (matchesGroup(match, 8)) {
        return SimpleToken.openParen(offset);
      }

      if (matchesGroup(match, 9)) {
        return SimpleToken.whitespace(offset, scanner.substring(offset));
      }

      if (matchesGroup(match, 10)) {
        var string = scanner.substring(offset);
        return SimpleToken.identifier(offset, string);
      }

      if (matchesGroup(match, 12)) {
        var lexeme = scanner.substring(offset).replaceAll(r'\"', '"');
        var isClosed = (lexeme.length > 1) && lexeme[lexeme.length - 1] == '"';
        return SimpleQuoteToken.doubleQuotedText(offset, lexeme, isClosed);
      }

      if (matchesGroup(match, 14)) {
        var lexeme = scanner.substring(offset).replaceAll(r"\'", "'");
        var isClosed = (lexeme.length > 1) && lexeme[lexeme.length - 1] == "'";
        return SimpleQuoteToken.singleQuotedText(offset, lexeme, isClosed);
      }

      if (matchesGroup(match, 16)) {
        if (scanner.peekChar() == $exclamation && scanner.peekChar(1) == $dash && scanner.peekChar(2) == $dash) {
          state = SimpleScannerState.comment;
          scanner.position = offset + 4;
          return SimpleToken.commentBegin(offset);
        }

        if (scanner.peekChar() == $slash) {
          scanner.position++;
          return SimpleToken.closeTagStart(offset);
        }

        return SimpleToken.openTagStart(offset);
      }

      if (matchesGroup(match, 17)) {
        return SimpleToken.equalSign(offset);
      }

      if (matchesGroup(match, 18)) {
        return SimpleToken.star(offset);
      }

      if (matchesGroup(match, 19)) {
        return SimpleToken.hash(offset);
      }

      if (matchesGroup(match, 20)) {
        return SimpleToken.period(offset);
      }

      if (matchesGroup(match, 21)) {
        return SimpleToken.percent(offset);
      }

      if (matchesGroup(match, 22)) {
        return SimpleToken.backSlash(offset);
      }

      if (matchesGroup(match, 23)) {
        return SimpleToken.atSign(offset);
      }
    }

    return SimpleToken.unexpectedChar(offset, String.fromCharCode(scanner.readChar()));
  }

  SimpleToken scanText() {
    var offset = scanner.position;

    if (scanner.isDone) {
      return SimpleToken.eof(offset);
    }

    if (scanner.scan(allTextMatches)) {
      var match = scanner.lastMatch!;

      if (matchesGroup(match, 1)) {
        var text = scanner.substring(offset);
        var mustacheMatch = mustaches.firstMatch(text);

        // Mustache exists
        if (mustacheMatch != null) {
          var mustacheStart = offset + mustacheMatch.start;

          // Mustache exists, but text precedes it - return the text first.
          if (mustacheStart != offset) {
            scanner.position = mustacheStart;
            return newTextToken(offset, scanner.substring(offset, mustacheStart));
          }

          // Mustache exists and text doesn't precede it - return mustache.
          scanner.position = offset + mustacheMatch.end;

          if (matchesGroup(mustacheMatch, 1)) {
            state = SimpleScannerState.interpolation;
            return SimpleToken.mustacheBegin(mustacheStart);
          }

          if (matchesGroup(mustacheMatch, 2)) {
            return SimpleToken.mustacheEnd(mustacheStart);
          }
        }

        // Mustache doesn't exist; simple text.
        return newTextToken(offset, text);
      }

      if (matchesGroup(match, 2)) {
        state = SimpleScannerState.comment;
        return SimpleToken.commentBegin(offset);
      }

      if (matchesGroup(match, 3)) {
        if (scanner.peekChar() == $slash) {
          scanner.position++;
          state = SimpleScannerState.element;
          return SimpleToken.closeTagStart(offset);
        }

        state = SimpleScannerState.element;
        return SimpleToken.openTagStart(offset);
      }
    }

    return SimpleToken.unexpectedChar(offset, String.fromCharCode(scanner.readChar()));
  }

  SimpleToken scanInterpolation() {
    // Need a separate scan state to ensure that '<' isn't
    // automatically mistaken as a element start. It can be a less than sign
    // used in interpolation expression.
    var offset = scanner.position;

    if (scanner.peekChar() == null) {
      return SimpleToken.eof(offset);
    }

    var text = scanner.string.substring(offset);
    var match = mustaches.firstMatch(text);

    // No matches found, meaning that mustache continues until EOF,
    // or until first newline found.
    if (match == null) {
      var newlineMatch = newline.firstMatch(text);

      // New line encountered before EOF.
      if (newlineMatch != null) {
        var newlineStart = offset + newlineMatch.start;
        var newlineEnd = offset + newlineMatch.end;

        // If text precedes it, return text.
        if (newlineStart != offset) {
          scanner.position = newlineStart;
          return newTextToken(offset, scanner.substring(offset));
        }

        // Otherwise, return the newline and switch state back to text.
        state = SimpleScannerState.text;
        scanner.position = newlineEnd;
        return SimpleToken.whitespace(offset, scanner.substring(offset));
      }

      // Simply scan text until EOF hit.
      scanner.position = offset + text.length;
      state = SimpleScannerState.text;
      return newTextToken(offset, scanner.substring(offset));
    }

    var matchStartOffset = offset + match.start;

    // Match exists, but text precedes it - return the text first.
    if (matchStartOffset != offset) {
      scanner.position = matchStartOffset;
      return newTextToken(offset, scanner.substring(offset));
    }

    scanner.position = offset + match.end;

    if (matchesGroup(match, 1)) {
      return SimpleToken.mustacheBegin(matchStartOffset);
    }

    if (matchesGroup(match, 2)) {
      state = SimpleScannerState.text;
      return SimpleToken.mustacheEnd(matchStartOffset);
    }

    return SimpleToken.unexpectedChar(offset, String.fromCharCode(scanner.readChar()));
  }

  void resetState() {
    state = SimpleScannerState.doctype;
  }

  SimpleToken newTextToken(int offset, String lexme) {
    return SimpleToken.decodedText(offset, unEscapeText(lexme), lexme.length);
  }

  String unEscapeText(String string) {
    return string.replaceAllMapped(escape, (match) {
      // decimal
      if (matchesGroup(match, 1)) {
        return String.fromCharCode(int.parse(match.group(1)!));
      }

      // hex
      if (matchesGroup(match, 2)) {
        return String.fromCharCode(int.parse(match.group(2)!, radix: 16));
      }

      // named
      if (matchesGroup(match, 3)) {
        return namedEntities[match.group(3)] ?? match.group(3)!;
      }

      return '';
    });
  }

  static RegExp get allTextMatches {
    return RegExp(r'([^\<]+)|(<!--)|(<)');
  }

  static RegExp get allElementMatches {
    return RegExp(r'(\])|' //1  ]
        r'(\!)|' //2  !
        r'(\-)|' //3  -
        r'(\))|' //4  )
        r'(>)|' //5  >
        r'(\/)|' //6  /
        r'(\[)|' //7  [
        r'(\()|' //8  (
        r'([\s]+)|' //9 whitespace
        //10 any alphanumeric + '-' + '_' + ':'
        r'([a-zA-Z]([\w\_\-:])*[a-zA-Z0-9]?)|'
        r'("([^"\\]+|\\.)*"?)|' //12 closed double quote (includes group 13)
        r"('([^'\\]+|\\.)*'?)|" //14 closed single quote (includes group 15)
        r'(<)|' //16 <
        r'(=)|' //17 =
        r'(\*)|' //18 *
        r'(\#)|' //19 #
        r'(\.)|' //20 .
        r'(\%)|' //21 %
        r'(\\)|' //22 \
        r'(\@)');
  } //23 @

  static RegExp get commentEnd {
    return RegExp('-->');
  }

  static RegExp get mustaches {
    return RegExp(r'({{)|(}})');
  }

  static RegExp get newline {
    return RegExp('\n');
  }

  static RegExp get escape {
    return RegExp(r'&#([0-9]{2,4});|' // 1 decimal
        '&#x([0-9A-Fa-f]{2,4});|' // 2 hex
        '&([a-zA-Z]+);');
  } // 3 named

  static RegExp get doctypeBegin {
    return RegExp(r'(<!DOCTYPE)|(>)');
  }

  static RegExp get gt {
    return RegExp(r'>');
  }

  static bool matchesGroup(Match match, int group) {
    return match.group(group) != null;
  }
}
