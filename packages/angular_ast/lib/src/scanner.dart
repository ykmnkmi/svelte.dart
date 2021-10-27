import 'parser_exception.dart';
import 'parser/reader.dart';
import 'simple_tokenizer.dart';
import 'token/tokens.dart';

enum NgScannerState {
  hasError,
  isEndOfFile,
  scanAfterComment,
  scanAfterElementDecorator,
  scanAfterElementDecoratorValue,
  scanAfterElementIdentifierClose,
  scanAfterElementIdentifierOpen,
  scanAfterInterpolation,
  scanBeforeElementDecorator,
  scanBeforeInterpolation,
  scanComment,
  scanElementDecorator,
  scanElementDecoratorValue,
  scanElementEndClose,
  scanElementEndOpen,
  scanElementIdentifierClose,
  scanElementIdentifierOpen,
  scanElementStart,
  scanInterpolation,
  scanSimpleElementDecorator,
  scanSpecialAnnotationDecorator,
  scanSpecialBananaDecorator,
  scanSpecialEventDecorator,
  scanSpecialPropertyDecorator,
  scanStart,
  scanSuffixBanana,
  scanSuffixEvent,
  scanSuffixProperty,
  scanText,
}

class Scanner {
  Scanner(String html, {Uri? sourceUrl})
      : reader = TokenReversibleReader<SimpleTokenType>(const SimpleTokenizer().tokenize(html).iterator),
        state = NgScannerState.scanStart;

  final TokenReversibleReader<Object> reader;

  NgScannerState state;

  SimpleToken? current;

  SimpleToken? lastToken;

  SimpleToken? lastErrorToken;

  // Storing last notable offsets to better generate exception offsets.
  // Due to the linear parsing nature of Angular, these values are recyclable.
  late int lastElementStartOffset;

  SimpleToken? lastDecoratorPrefix;

  int? lastOpenMustacheOffset;

  late int lastCommentStartOffset;

  late int lastEqualSignOffset;

  SimpleToken? moveNext() {
    lastToken = current;
    current = reader.next() as SimpleToken;
    return current;
  }

  Token? scan() {
    moveNext();
    Token? returnToken;

    while (returnToken == null) {
      switch (state) {
        case NgScannerState.hasError:
          throw StateError('An error occurred');
        case NgScannerState.isEndOfFile:
          return null;
        case NgScannerState.scanAfterComment:
          returnToken = scanAfterComment();
          break;
        case NgScannerState.scanAfterElementDecorator:
          returnToken = scanAfterElementDecorator();
          lastDecoratorPrefix = null;
          break;
        case NgScannerState.scanAfterElementDecoratorValue:
          returnToken = scanAfterElementDecoratorValue();
          break;
        case NgScannerState.scanAfterElementIdentifierClose:
          returnToken = scanAfterElementIdentifierClose();
          break;
        case NgScannerState.scanAfterElementIdentifierOpen:
          returnToken = scanAfterElementIdentifierOpen();
          break;
        case NgScannerState.scanAfterInterpolation:
          returnToken = scanAfterInterpolation();
          lastOpenMustacheOffset = null;
          break;
        case NgScannerState.scanBeforeElementDecorator:
          returnToken = scanBeforeElementDecorator();
          break;
        case NgScannerState.scanBeforeInterpolation:
          returnToken = scanBeforeInterpolation();
          break;
        case NgScannerState.scanElementEndClose:
          returnToken = scanElementEndClose();
          break;
        case NgScannerState.scanElementEndOpen:
          returnToken = scanElementEndOpen();
          break;
        case NgScannerState.scanComment:
          returnToken = scanComment();
          break;
        case NgScannerState.scanElementDecorator:
          returnToken = scanElementDecorator();
          break;
        case NgScannerState.scanElementDecoratorValue:
          returnToken = scanElementDecoratorValue();
          break;
        case NgScannerState.scanElementIdentifierClose:
          returnToken = scanElementIdentifier(wasOpenTag: false);
          break;
        case NgScannerState.scanElementIdentifierOpen:
          returnToken = scanElementIdentifier(wasOpenTag: true);
          break;
        case NgScannerState.scanElementStart:
          returnToken = scanElementStart();
          break;
        case NgScannerState.scanInterpolation:
          returnToken = scanInterpolation();
          break;
        case NgScannerState.scanSimpleElementDecorator:
          returnToken = scanSimpleElementDecorator();
          break;
        case NgScannerState.scanSpecialAnnotationDecorator:
          returnToken = scanSpecialAnnotationDecorator();
          break;
        case NgScannerState.scanSpecialBananaDecorator:
          returnToken = scanSpecialBananaDecorator();
          break;
        case NgScannerState.scanSpecialEventDecorator:
          returnToken = scanSpecialEventDecorator();
          break;
        case NgScannerState.scanSpecialPropertyDecorator:
          returnToken = scanSpecialPropertyDecorator();
          break;
        case NgScannerState.scanSuffixBanana:
          returnToken = scanSuffixBanana();
          break;
        case NgScannerState.scanSuffixEvent:
          returnToken = scanSuffixEvent();
          break;
        case NgScannerState.scanSuffixProperty:
          returnToken = scanSuffixProperty();
          break;
        case NgScannerState.scanStart:
          var type = current!.type;

          if (type == SimpleTokenType.eof && reader.isDone) {
            state = NgScannerState.isEndOfFile;
            return null;
          } else if (type == SimpleTokenType.openTagStart || type == SimpleTokenType.closeTagStart) {
            returnToken = scanElementStart();
          } else if (type == SimpleTokenType.commentBegin) {
            returnToken = scanBeforeComment();
          } else if (type == SimpleTokenType.mustacheBegin || type == SimpleTokenType.mustacheEnd) {
            // If [NgSimpleTokenType.mustacheEnd], then error - but let
            // scanBeforeInterpolation handle it.
            state = NgScannerState.scanBeforeInterpolation;
            return scanBeforeInterpolation();
          } else {
            returnToken = scanText();
          }

          break;
        case NgScannerState.scanText:
          returnToken = scanText();
          break;
      }
    }

    return returnToken;
  }

  Token? scanAfterComment() {
    var current = this.current!;

    if (current.type == SimpleTokenType.commentEnd) {
      state = NgScannerState.scanStart;
      return Token.commentEnd(current.offset);
    }

    // Only triggered by EOF.
    var length = current.offset - lastCommentStartOffset;
    throw ParserException(ParserErrorCode.unterminatedComment, lastCommentStartOffset, length);
  }

  // TODO: Better handle cases like 'prop]'. Instead of 'prop []' resolve, resolve as '[prop].
  Token? scanAfterElementDecorator() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.equalSign) {
      state = NgScannerState.scanElementDecoratorValue;
      lastEqualSignOffset = current.offset;
      return Token.beforeElementDecoratorValue(current.offset);
    } else if (type == SimpleTokenType.tagEnd || type == SimpleTokenType.voidCloseTag) {
      return scanElementEndOpen();
    } else if (type == SimpleTokenType.whitespace) {
      var nextType = reader.peekType();

      // Trailing whitespace check.
      if (nextType == SimpleTokenType.equalSign ||
          nextType == SimpleTokenType.voidCloseTag ||
          nextType == SimpleTokenType.tagEnd) {
        return Token.whitespace(current.offset, current.lexeme);
      }

      return scanBeforeElementDecorator();
    }

    if (type == SimpleTokenType.openBracket ||
        type == SimpleTokenType.openParen ||
        type == SimpleTokenType.openBanana ||
        type == SimpleTokenType.hash ||
        type == SimpleTokenType.star ||
        type == SimpleTokenType.atSign ||
        type == SimpleTokenType.closeBracket ||
        type == SimpleTokenType.closeParen ||
        type == SimpleTokenType.closeBanana ||
        type == SimpleTokenType.identifier) {
      throw ParserException(ParserErrorCode.expectedWhitespaceBeforeNewDecorator, current.offset, current.length);
    }

    if (type == SimpleTokenType.eof ||
        type == SimpleTokenType.commentBegin ||
        type == SimpleTokenType.openTagStart ||
        type == SimpleTokenType.closeTagStart) {
      var lastToken = this.lastToken!;
      var offset = lastToken.offset;
      var length = lastToken.length;
      throw ParserException(ParserErrorCode.expectedTagClose, offset, length);
    }

    if (type == SimpleTokenType.doubleQuote || type == SimpleTokenType.singleQuote) {
      var lastToken = this.lastToken!;
      var offset = lastToken.offset;
      var length = current.end - offset;
      throw ParserException(ParserErrorCode.expectedEuqlSign, offset, length);
    }

    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }

  Token? scanAfterElementDecoratorValue() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.tagEnd || type == SimpleTokenType.voidCloseTag) {
      return scanElementEndOpen();
    } else if (type == SimpleTokenType.whitespace) {
      var nextType = reader.peekType();

      if (nextType == SimpleTokenType.voidCloseTag || nextType == SimpleTokenType.tagEnd) {
        return Token.whitespace(current.offset, current.lexeme);
      }

      return scanBeforeElementDecorator();
    }

    if (type == SimpleTokenType.openBracket ||
        type == SimpleTokenType.openParen ||
        type == SimpleTokenType.openBanana ||
        type == SimpleTokenType.hash ||
        type == SimpleTokenType.star ||
        type == SimpleTokenType.atSign ||
        type == SimpleTokenType.identifier ||
        type == SimpleTokenType.closeBracket ||
        type == SimpleTokenType.closeParen ||
        type == SimpleTokenType.closeBanana ||
        type == SimpleTokenType.equalSign ||
        type == SimpleTokenType.doubleQuote ||
        type == SimpleTokenType.singleQuote) {
      var lastToken = this.lastToken!;
      throw ParserException(ParserErrorCode.expectedWhitespaceBeforeNewDecorator, lastToken.offset, lastToken.length);
    }

    if (type == SimpleTokenType.eof ||
        type == SimpleTokenType.commentBegin ||
        type == SimpleTokenType.openTagStart ||
        type == SimpleTokenType.closeTagStart) {
      var lastToken = this.lastToken!;
      throw ParserException(ParserErrorCode.expectedTagClose, lastToken.offset, lastToken.length);
    }

    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }

  Token? scanAfterElementIdentifierClose() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.whitespace) {
      state = NgScannerState.scanElementEndClose;
      return Token.whitespace(current.offset, current.lexeme);
    }

    if (type == SimpleTokenType.tagEnd) {
      state = NgScannerState.scanStart;
      return scanElementEndClose();
    }

    if (type == SimpleTokenType.commentBegin ||
        type == SimpleTokenType.openTagStart ||
        type == SimpleTokenType.closeTagStart ||
        type == SimpleTokenType.eof) {
      var lastToken = this.lastToken!;
      throw ParserException(ParserErrorCode.expectedAfterElementIdentifier, lastToken.offset, lastToken.length);
    }

    if (type == SimpleTokenType.voidCloseTag) {
      throw ParserException(ParserErrorCode.voidCloseInCloseTag, current.offset, current.length);
    }

    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }

  Token? scanAfterElementIdentifierOpen() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.whitespace) {
      var peeked = reader.peek()!;

      if (peeked.type == SimpleTokenType.voidCloseTag || peeked.type == SimpleTokenType.tagEnd) {
        state = NgScannerState.scanElementEndOpen;
        return Token.whitespace(current.offset, current.lexeme);
      }

      state = NgScannerState.scanElementDecorator;
      return scanBeforeElementDecorator();
    }

    if (type == SimpleTokenType.voidCloseTag || type == SimpleTokenType.tagEnd) {
      return scanElementEndOpen();
    }

    if (type == SimpleTokenType.openBracket ||
        type == SimpleTokenType.openParen ||
        type == SimpleTokenType.openBanana ||
        type == SimpleTokenType.hash ||
        type == SimpleTokenType.star ||
        type == SimpleTokenType.atSign ||
        type == SimpleTokenType.equalSign ||
        type == SimpleTokenType.closeBracket ||
        type == SimpleTokenType.closeParen ||
        type == SimpleTokenType.closeBanana ||
        type == SimpleTokenType.doubleQuote ||
        type == SimpleTokenType.singleQuote) {
      var lastToken = this.lastToken!;
      throw ParserException(ParserErrorCode.expectedWhitespaceBeforeNewDecorator, lastToken.offset, lastToken.length);
    }

    if (type == SimpleTokenType.commentBegin ||
        type == SimpleTokenType.openTagStart ||
        type == SimpleTokenType.closeTagStart ||
        type == SimpleTokenType.eof) {
      var lastToken = this.lastToken!;
      throw ParserException(ParserErrorCode.expectedAfterElementIdentifier, lastToken.offset, lastToken.length);
    }

    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }

  Token? scanAfterInterpolation() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.mustacheEnd) {
      state = NgScannerState.scanStart;
      return Token.interpolationEnd(current.offset);
    }

    if (type == SimpleTokenType.eof || type == SimpleTokenType.mustacheBegin || type == SimpleTokenType.whitespace) {
      throw ParserException(ParserErrorCode.unterminatedMustache, lastOpenMustacheOffset!, 2);
    }

    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }

  Token? scanBeforeComment() {
    var current = this.current!;

    if (current.type == SimpleTokenType.commentBegin) {
      state = NgScannerState.scanComment;
      lastCommentStartOffset = current.offset;
      return Token.commentStart(current.offset);
    }

    // Transient state, should theoretically never hit.
    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }

  Token? scanBeforeElementDecorator() {
    var current = this.current!;

    if (current.type == SimpleTokenType.whitespace) {
      if (reader.peekType() == SimpleTokenType.voidCloseTag || reader.peekType() == SimpleTokenType.tagEnd) {
        state = NgScannerState.scanAfterElementDecorator;
        return Token.whitespace(current.offset, current.lexeme);
      }

      state = NgScannerState.scanElementDecorator;
      return Token.beforeElementDecorator(current.offset, current.lexeme);
    }

    // Transient state, should theoretically never hit.
    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }

  Token? scanBeforeInterpolation() {
    var current = this.current!;

    if (current.type == SimpleTokenType.mustacheBegin) {
      state = NgScannerState.scanInterpolation;
      lastOpenMustacheOffset = current.offset;
      return Token.interpolationStart(current.offset);
    }

    var errorToken = current;

    if (current.type == SimpleTokenType.text && reader.peekType() == SimpleTokenType.mustacheEnd) {
      errorToken = reader.peek() as SimpleToken;
    }

    throw ParserException(ParserErrorCode.unopenedMustache, errorToken.offset, errorToken.length);
  }

  Token? scanComment() {
    var current = this.current!;

    if (current.type == SimpleTokenType.text) {
      state = NgScannerState.scanAfterComment;
      return Token.commentValue(current.offset, current.lexeme);
    }

    if (current.type == SimpleTokenType.commentEnd) {
      state = NgScannerState.scanAfterComment;
      return scanAfterComment();
    }

    // Only EOF should enable error.
    throw ParserException(ParserErrorCode.unterminatedComment, lastCommentStartOffset, 4);
  }

  // Doesn't switch states or check validity of current token.
  Token scanCompoundDecorator() {
    var current = this.current!;
    var offset = current.offset;
    var sb = StringBuffer();
    sb.write(current.lexeme);

    while (reader.peekType() == SimpleTokenType.period ||
        reader.peekType() == SimpleTokenType.identifier ||
        reader.peekType() == SimpleTokenType.dash ||
        reader.peekType() == SimpleTokenType.percent ||
        reader.peekType() == SimpleTokenType.backSlash) {
      moveNext();
      sb.write(this.current!.lexeme);
    }

    return Token.elementDecorator(offset, sb.toString());
  }

  Token? scanElementDecorator() {
    var current = this.current!;
    var type = current.type;
    var offset = current.offset;

    if (type == SimpleTokenType.identifier) {
      state = NgScannerState.scanAfterElementDecorator;
      return scanCompoundDecorator();
    }

    if (type == SimpleTokenType.openParen) {
      state = NgScannerState.scanSpecialEventDecorator;
      lastDecoratorPrefix = this.current;
      return Token.eventPrefix(offset);
    }

    if (type == SimpleTokenType.openBracket) {
      state = NgScannerState.scanSpecialPropertyDecorator;
      lastDecoratorPrefix = this.current;
      return Token.propertyPrefix(offset);
    }

    if (type == SimpleTokenType.openBanana) {
      state = NgScannerState.scanSpecialBananaDecorator;
      lastDecoratorPrefix = this.current;
      return Token.bananaPrefix(offset);
    }

    if (type == SimpleTokenType.hash) {
      state = NgScannerState.scanSimpleElementDecorator;
      lastDecoratorPrefix = this.current;
      return Token.referencePrefix(offset);
    }

    if (type == SimpleTokenType.star) {
      state = NgScannerState.scanSimpleElementDecorator;
      lastDecoratorPrefix = this.current;
      return Token.templatePrefix(offset);
    }

    if (type == SimpleTokenType.atSign) {
      state = NgScannerState.scanSpecialAnnotationDecorator;
      lastDecoratorPrefix = this.current;
      return Token.annotationPrefix(offset);
    }

    if (type == SimpleTokenType.equalSign ||
        type == SimpleTokenType.commentBegin ||
        type == SimpleTokenType.openTagStart ||
        type == SimpleTokenType.closeTagStart ||
        type == SimpleTokenType.eof ||
        type == SimpleTokenType.doubleQuote ||
        type == SimpleTokenType.singleQuote) {
      var lastToken = this.lastToken!;
      throw ParserException(ParserErrorCode.elementDecorator, lastToken.offset, lastToken.length);
    }

    if (type == SimpleTokenType.closeBracket ||
        type == SimpleTokenType.closeParen ||
        type == SimpleTokenType.closeBanana) {
      throw ParserException(ParserErrorCode.elementDecoratorSuffixBeforePrefix, current.offset, current.length);
    }

    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }

  Token? scanElementDecoratorValue() {
    var current = this.current!;
    var type = current.type;

    if (current is SimpleQuoteToken) {
      var isDouble = current.type == SimpleTokenType.doubleQuote;

      Token leftQuoteToken;
      Token innerValueToken;
      Token rightQuoteToken;
      int leftQuoteOffset;
      int rightQuoteOffset;

      var innerValue = current.contentLexeme;
      leftQuoteOffset = current.offset;

      if (current.quoteEndOffset == null) {
        throw ParserException(ParserErrorCode.uncloseQuote, current.offset, current.length);
      } else {
        rightQuoteOffset = current.quoteEndOffset!;
      }

      if (isDouble) {
        leftQuoteToken = Token.doubleQuote(leftQuoteOffset);
        rightQuoteToken = Token.doubleQuote(rightQuoteOffset);
      } else {
        leftQuoteToken = Token.singleQuote(leftQuoteOffset);
        rightQuoteToken = Token.singleQuote(rightQuoteOffset);
      }

      innerValueToken = Token.elementDecoratorValue(current.contentOffset, innerValue);
      state = NgScannerState.scanAfterElementDecoratorValue;
      return AttributeValueToken.generate(leftQuoteToken, innerValueToken, rightQuoteToken);
    }

    if (type == SimpleTokenType.whitespace) {
      return Token.whitespace(current.offset, current.lexeme);
    }

    if (type == SimpleTokenType.identifier) {
      throw ParserException(ParserErrorCode.elementDecoratorValueMissingQuotes, current.offset, current.length);
    }

    if (type == SimpleTokenType.openBracket ||
        type == SimpleTokenType.openParen ||
        type == SimpleTokenType.openBanana ||
        type == SimpleTokenType.closeBracket ||
        type == SimpleTokenType.closeParen ||
        type == SimpleTokenType.closeBanana ||
        type == SimpleTokenType.commentBegin ||
        type == SimpleTokenType.openTagStart ||
        type == SimpleTokenType.closeTagStart ||
        type == SimpleTokenType.tagEnd ||
        type == SimpleTokenType.voidCloseTag ||
        type == SimpleTokenType.eof ||
        type == SimpleTokenType.equalSign ||
        type == SimpleTokenType.hash ||
        type == SimpleTokenType.star ||
        type == SimpleTokenType.atSign) {
      var length = current.offset - lastEqualSignOffset;
      throw ParserException(ParserErrorCode.elementDecoratorValue, lastEqualSignOffset, length);
    }

    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }

  Token? scanElementIdentifier({bool wasOpenTag = false}) {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.identifier) {
      if (wasOpenTag) {
        state = NgScannerState.scanAfterElementIdentifierOpen;
      } else {
        state = NgScannerState.scanAfterElementIdentifierClose;
      }

      return Token.elementIdentifier(current.offset, current.lexeme);
    }

    if (wasOpenTag) {
      if (type == SimpleTokenType.openBracket ||
          type == SimpleTokenType.openParen ||
          type == SimpleTokenType.openBanana ||
          type == SimpleTokenType.hash ||
          type == SimpleTokenType.star ||
          type == SimpleTokenType.atSign ||
          type == SimpleTokenType.closeBracket ||
          type == SimpleTokenType.closeParen ||
          type == SimpleTokenType.closeBanana ||
          type == SimpleTokenType.commentBegin ||
          type == SimpleTokenType.openTagStart ||
          type == SimpleTokenType.closeTagStart ||
          type == SimpleTokenType.tagEnd ||
          type == SimpleTokenType.eof ||
          type == SimpleTokenType.equalSign ||
          type == SimpleTokenType.whitespace ||
          type == SimpleTokenType.doubleQuote ||
          type == SimpleTokenType.singleQuote) {
        var length = current.end - lastElementStartOffset;
        throw ParserException(ParserErrorCode.elementIdentifier, lastElementStartOffset, length);
      }

      throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
    } else {
      if (type == SimpleTokenType.closeTagStart ||
          type == SimpleTokenType.openTagStart ||
          type == SimpleTokenType.tagEnd ||
          type == SimpleTokenType.commentBegin ||
          type == SimpleTokenType.eof ||
          type == SimpleTokenType.whitespace) {
        var length = current.end - lastElementStartOffset;
        throw ParserException(ParserErrorCode.elementIdentifier, lastElementStartOffset, length);
      }

      throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
    }
  }

  // This state is technically a duplicate for [scanAfterElementIdentifierClose],
  // but keep for now in case we want to expand on recovery for close tags.
  Token? scanElementEndClose() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.tagEnd) {
      state = NgScannerState.scanStart;
      return Token.closeElementEnd(current.offset);
    }

    if (type == SimpleTokenType.whitespace) {
      return Token.whitespace(current.offset, current.lexeme);
    }

    if (type == SimpleTokenType.commentBegin ||
        type == SimpleTokenType.openTagStart ||
        type == SimpleTokenType.closeTagStart ||
        type == SimpleTokenType.eof) {
      var length = current.end - lastElementStartOffset;
      throw ParserException(ParserErrorCode.expectedTagClose, lastElementStartOffset, length);
    }

    if (type == SimpleTokenType.voidCloseTag) {
      throw ParserException(ParserErrorCode.voidCloseInCloseTag, current.offset, current.length);
    }

    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }

  Token? scanElementEndOpen() {
    var current = this.current!;

    if (current.type == SimpleTokenType.voidCloseTag) {
      state = NgScannerState.scanStart;
      return Token.openElementEndVoid(current.offset);
    }

    if (current.type == SimpleTokenType.tagEnd) {
      state = NgScannerState.scanStart;
      return Token.openElementEnd(current.offset);
    }

    // Directed state, should theoretically never hit.
    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }

  Token? scanElementStart() {
    var current = this.current!;

    if (current.type == SimpleTokenType.openTagStart) {
      state = NgScannerState.scanElementIdentifierOpen;
      lastElementStartOffset = current.offset;
      return Token.openElementStart(current.offset);
    }

    if (current.type == SimpleTokenType.closeTagStart) {
      state = NgScannerState.scanElementIdentifierClose;
      lastElementStartOffset = current.offset;
      return Token.closeElementStart(current.offset);
    }

    // Transient state, should theoretically never hit.
    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }

  Token? scanInterpolation() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.text) {
      state = NgScannerState.scanAfterInterpolation;
      return Token.interpolationValue(current.offset, current.lexeme);
    }

    if (this.current == lastErrorToken) {
      return null;
    }

    if (type == SimpleTokenType.eof || type == SimpleTokenType.mustacheBegin) {
      throw ParserException(ParserErrorCode.unterminatedMustache, lastOpenMustacheOffset!, 2);
    }

    if (type == SimpleTokenType.mustacheEnd) {
      var offset = lastOpenMustacheOffset!;
      var length = current.end - offset;
      throw ParserException(ParserErrorCode.emptyInterpolation, offset, length);
    }

    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }

  Token? scanSimpleElementDecorator() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.identifier) {
      state = NgScannerState.scanAfterElementDecorator;
      return Token.elementDecorator(current.offset, current.lexeme);
    }

    if (type == SimpleTokenType.bang ||
        type == SimpleTokenType.dash ||
        type == SimpleTokenType.forwardSlash ||
        type == SimpleTokenType.period ||
        type == SimpleTokenType.unexpectedChar) {
      throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
    }

    var lastToken = this.lastToken!;
    throw ParserException(ParserErrorCode.elementDecorator, lastToken.offset, lastToken.length);
  }

  Token? scanSpecialAnnotationDecorator() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.period || type == SimpleTokenType.identifier) {
      state = NgScannerState.scanAfterElementDecorator;
      return scanCompoundDecorator();
    }

    if (this.current == lastErrorToken) {
      return null;
    }

    if (type == SimpleTokenType.bang ||
        type == SimpleTokenType.dash ||
        type == SimpleTokenType.forwardSlash ||
        type == SimpleTokenType.unexpectedChar) {
      throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
    }

    var lastDecoratorPrefix = this.lastDecoratorPrefix!;
    throw ParserException(
        ParserErrorCode.elementDecoratorAfterPrefix, lastDecoratorPrefix.offset, lastDecoratorPrefix.length);
  }

  Token? scanSpecialBananaDecorator() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.period || type == SimpleTokenType.identifier) {
      state = NgScannerState.scanSuffixBanana;
      return scanCompoundDecorator();
    }

    if (this.current == lastErrorToken) {
      return null;
    }

    if (type == SimpleTokenType.bang ||
        type == SimpleTokenType.dash ||
        type == SimpleTokenType.forwardSlash ||
        type == SimpleTokenType.unexpectedChar) {
      throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
    }

    var lastDecoratorPrefix = this.lastDecoratorPrefix!;
    throw ParserException(
        ParserErrorCode.elementDecoratorAfterPrefix, lastDecoratorPrefix.offset, lastDecoratorPrefix.length);
  }

  Token? scanSpecialEventDecorator() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.period || type == SimpleTokenType.identifier) {
      state = NgScannerState.scanSuffixEvent;
      return scanCompoundDecorator();
    }

    if (this.current == lastErrorToken) {
      return null;
    }

    if (type == SimpleTokenType.bang ||
        type == SimpleTokenType.dash ||
        type == SimpleTokenType.forwardSlash ||
        type == SimpleTokenType.unexpectedChar) {
      throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
    }

    var lastDecoratorPrefix = this.lastDecoratorPrefix!;
    throw ParserException(
        ParserErrorCode.elementDecoratorAfterPrefix, lastDecoratorPrefix.offset, lastDecoratorPrefix.length);
  }

  Token? scanSpecialPropertyDecorator() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.period || type == SimpleTokenType.identifier) {
      state = NgScannerState.scanSuffixProperty;
      return scanCompoundDecorator();
    }

    if (this.current == lastErrorToken) {
      return null;
    }

    if (type == SimpleTokenType.bang ||
        type == SimpleTokenType.dash ||
        type == SimpleTokenType.forwardSlash ||
        type == SimpleTokenType.unexpectedChar) {
      throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
    }

    var lastDecoratorPrefix = this.lastDecoratorPrefix!;
    throw ParserException(
        ParserErrorCode.elementDecoratorAfterPrefix, lastDecoratorPrefix.offset, lastDecoratorPrefix.length);
  }

  Token? scanSuffixBanana() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.closeBanana) {
      state = NgScannerState.scanAfterElementDecorator;
      return Token.bananaSuffix(current.offset);
    }

    if (this.current == lastErrorToken) {
      return null;
    }

    if (type == SimpleTokenType.bang ||
        type == SimpleTokenType.forwardSlash ||
        type == SimpleTokenType.dash ||
        type == SimpleTokenType.unexpectedChar) {
      throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
    }

    var lastDecoratorPrefix = this.lastDecoratorPrefix!;
    var length = current.offset - lastDecoratorPrefix.offset;
    throw ParserException(ParserErrorCode.suffixBanana, lastDecoratorPrefix.offset, length);
  }

  Token? scanSuffixEvent() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.closeParen) {
      state = NgScannerState.scanAfterElementDecorator;
      return Token.eventSuffix(current.offset);
    }

    if (this.current == lastErrorToken) {
      return null;
    }

    if (type == SimpleTokenType.bang ||
        type == SimpleTokenType.forwardSlash ||
        type == SimpleTokenType.dash ||
        type == SimpleTokenType.unexpectedChar) {
      throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
    }

    var lastDecoratorPrefix = this.lastDecoratorPrefix!;
    var length = current.offset - lastDecoratorPrefix.offset;
    throw ParserException(ParserErrorCode.suffixEvent, lastDecoratorPrefix.offset, length);
  }

  Token? scanSuffixProperty() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.closeBracket) {
      state = NgScannerState.scanAfterElementDecorator;
      return Token.propertySuffix(current.offset);
    }

    if (this.current == lastErrorToken) {
      return null;
    }

    if (type == SimpleTokenType.bang ||
        type == SimpleTokenType.forwardSlash ||
        type == SimpleTokenType.dash ||
        type == SimpleTokenType.unexpectedChar) {
      throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
    }

    var lastDecoratorPrefix = this.lastDecoratorPrefix!;
    var offset = lastDecoratorPrefix.offset;
    var length = current.offset - offset;
    throw ParserException(ParserErrorCode.suffixProperty, offset, length);
  }

  Token? scanText() {
    var current = this.current!;
    var type = current.type;

    if (type == SimpleTokenType.text || type == SimpleTokenType.whitespace) {
      if (reader.peekType() == SimpleTokenType.mustacheEnd) {
        state = NgScannerState.scanBeforeInterpolation;
        return scanBeforeInterpolation();
      }

      var offset = current.offset;
      var sb = StringBuffer();
      sb.write(current.lexeme);

      while (reader.peekType() == SimpleTokenType.text || reader.peekType() == SimpleTokenType.whitespace) {
        // Specific use case for this is when newline splits dangling {{
        sb.write(moveNext()!.lexeme);
      }

      state = NgScannerState.scanStart;
      return Token.text(offset, sb.toString());
    }

    // No real errors in scanText state, but just in case.
    throw ParserException(ParserErrorCode.unexpectedToken, current.offset, current.length);
  }
}
