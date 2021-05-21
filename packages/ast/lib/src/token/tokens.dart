import '../hash.dart';

part 'lexeme.dart';
part 'types.dart';

abstract class BaseToken<T> {
  int get offset;

  int get end;

  int get length;

  String get lexeme;

  T get type;
}

class SimpleToken implements BaseToken<SimpleTokenType> {
  static final Map<SimpleTokenType, String> lexemeMap = const {
    SimpleTokenType.atSign: '@',
    SimpleTokenType.backSlash: '\\',
    SimpleTokenType.bang: '!',
    SimpleTokenType.closeBanana: ')]',
    SimpleTokenType.closeBracket: ']',
    SimpleTokenType.closeParen: ')',
    SimpleTokenType.closeTagStart: '</',
    SimpleTokenType.commentBegin: '<!--',
    SimpleTokenType.commentEnd: '-->',
    SimpleTokenType.dash: '-',
    SimpleTokenType.openTagStart: '<',
    SimpleTokenType.tagEnd: '>',
    SimpleTokenType.EOF: '',
    SimpleTokenType.equalSign: '=',
    SimpleTokenType.forwardSlash: '/',
    SimpleTokenType.hash: '#',
    SimpleTokenType.identifier: '',
    SimpleTokenType.mustacheBegin: '{{',
    SimpleTokenType.mustacheEnd: '}}',
    SimpleTokenType.openBanana: '[(',
    SimpleTokenType.openBracket: '[',
    SimpleTokenType.openParen: '(',
    SimpleTokenType.percent: '%',
    SimpleTokenType.period: '.',
    SimpleTokenType.star: '*',
    SimpleTokenType.text: '',
    SimpleTokenType.unexpectedChar: '?',
    SimpleTokenType.voidCloseTag: '/>',
    SimpleTokenType.whitespace: ' ',
  };

  factory SimpleToken.atSign(int offset) {
    return SimpleToken(SimpleTokenType.atSign, offset);
  }

  factory SimpleToken.backSlash(int offset) {
    return SimpleToken(SimpleTokenType.backSlash, offset);
  }

  factory SimpleToken.bang(int offset) {
    return SimpleToken(SimpleTokenType.bang, offset);
  }

  factory SimpleToken.closeBanana(int offset) {
    return SimpleToken(SimpleTokenType.closeBanana, offset);
  }

  factory SimpleToken.closeBracket(int offset) {
    return SimpleToken(SimpleTokenType.closeBracket, offset);
  }

  factory SimpleToken.closeParen(int offset) {
    return SimpleToken(SimpleTokenType.closeParen, offset);
  }

  factory SimpleToken.closeTagStart(int offset) {
    return SimpleToken(SimpleTokenType.closeTagStart, offset);
  }

  factory SimpleToken.commentBegin(int offset) {
    return SimpleToken(SimpleTokenType.commentBegin, offset);
  }

  factory SimpleToken.commentEnd(int offset) {
    return SimpleToken(SimpleTokenType.commentEnd, offset);
  }

  factory SimpleToken.dash(int offset) {
    return SimpleToken(SimpleTokenType.dash, offset);
  }

  factory SimpleToken.openTagStart(int offset) {
    return SimpleToken(SimpleTokenType.openTagStart, offset);
  }

  factory SimpleToken.tagEnd(int offset) {
    return SimpleToken(SimpleTokenType.tagEnd, offset);
  }

  factory SimpleToken.EOF(int offset) {
    return SimpleToken(SimpleTokenType.EOF, offset);
  }

  factory SimpleToken.equalSign(int offset) {
    return SimpleToken(SimpleTokenType.equalSign, offset);
  }

  factory SimpleToken.forwardSlash(int offset) {
    return SimpleToken(SimpleTokenType.forwardSlash, offset);
  }

  factory SimpleToken.hash(int offset) {
    return SimpleToken(SimpleTokenType.hash, offset);
  }

  factory SimpleToken.identifier(int offset, String lexeme) {
    return LexemeSimpleToken(offset, lexeme, lexeme.length, SimpleTokenType.identifier);
  }

  factory SimpleToken.mustacheBegin(int offset) {
    return SimpleToken(SimpleTokenType.mustacheBegin, offset);
  }

  factory SimpleToken.mustacheEnd(int offset) {
    return SimpleToken(SimpleTokenType.mustacheEnd, offset);
  }

  factory SimpleToken.openBanana(int offset) {
    return SimpleToken(SimpleTokenType.openBanana, offset);
  }

  factory SimpleToken.openBracket(int offset) {
    return SimpleToken(SimpleTokenType.openBracket, offset);
  }

  factory SimpleToken.openParen(int offset) {
    return SimpleToken(SimpleTokenType.openParen, offset);
  }

  factory SimpleToken.percent(int offset) {
    return SimpleToken(SimpleTokenType.percent, offset);
  }

  factory SimpleToken.period(int offset) {
    return SimpleToken(SimpleTokenType.period, offset);
  }

  factory SimpleToken.star(int offset) {
    return SimpleToken(SimpleTokenType.star, offset);
  }

  factory SimpleToken.text(int offset, String lexeme) {
    return LexemeSimpleToken(offset, lexeme, lexeme.length, SimpleTokenType.text);
  }

  factory SimpleToken.decodedText(int offset, String lexeme, int originalLength) {
    return LexemeSimpleToken(offset, lexeme, originalLength, SimpleTokenType.text);
  }

  factory SimpleToken.unexpectedChar(int offset, String lexeme) {
    return LexemeSimpleToken(offset, lexeme, lexeme.length, SimpleTokenType.unexpectedChar);
  }

  factory SimpleToken.voidCloseTag(int offset) {
    return SimpleToken(SimpleTokenType.voidCloseTag, offset);
  }

  factory SimpleToken.whitespace(int offset, String lexeme) {
    return LexemeSimpleToken(offset, lexeme, lexeme.length, SimpleTokenType.whitespace);
  }

  const SimpleToken(this.type, this.offset);

  @override
  final int offset;

  @override
  final SimpleTokenType type;

  @override
  bool operator ==(Object o) {
    if (o is SimpleToken) {
      return o.offset == offset && o.type == type;
    }

    return false;
  }

  @override
  int get hashCode {
    return hash2(offset, type);
  }

  @override
  int get end {
    return offset + length;
  }

  @override
  int get length {
    return lexeme.length;
  }

  @override
  String get lexeme {
    return lexemeMap[type]!;
  }

  @override
  String toString() {
    return '#$SimpleToken($type) {$offset:$lexeme}';
  }
}

class SimpleQuoteToken extends LexemeSimpleToken {
  factory SimpleQuoteToken.doubleQuotedText(int offset, String lexeme, bool isClosed) {
    return SimpleQuoteToken(SimpleTokenType.doubleQuote, offset, lexeme, isClosed);
  }

  factory SimpleQuoteToken.singleQuotedText(int offset, String lexeme, bool isClosed) {
    return SimpleQuoteToken(SimpleTokenType.singleQuote, offset, lexeme, isClosed);
  }

  SimpleQuoteToken(SimpleTokenType type, int offset, String lexeme, bool isClosed, {bool isErrorSynthetic = false})
      : contentOffset = offset + 1,
        contentLexeme = lexeme.isEmpty ? lexeme : lexeme.substring(1, isClosed ? lexeme.length - 1 : lexeme.length),
        quoteEndOffset = isClosed ? offset + lexeme.length - 1 : null,
        super(offset, lexeme, lexeme.length, type);

  final int contentOffset;

  final String contentLexeme;

  final int? quoteEndOffset;

  int get contentEnd {
    return contentOffset + contentLength;
  }

  int get contentLength {
    return contentLexeme.length;
  }

  @override
  int get hashCode {
    return hash4(super.hashCode, lexeme, contentOffset, end);
  }

  bool get isClosed {
    return quoteEndOffset != null;
  }

  @override
  bool operator ==(Object? o) {
    if (o is SimpleQuoteToken) {
      return o.offset == offset && o.type == type && o.contentOffset == contentOffset && o.quoteEndOffset == quoteEndOffset;
    }

    return false;
  }

  @override
  String toString() {
    return '#$SimpleQuoteToken($type) {$offset:$lexeme}';
  }
}

class Token implements BaseToken<TokenType> {
  static final Map<TokenType, String> lexemeMap = const <TokenType, String>{
    TokenType.annotationPrefix: '@',
    TokenType.bananaPrefix: '[(',
    TokenType.bananaSuffix: ')]',
    TokenType.beforeElementDecoratorValue: '=',
    TokenType.bindPrefix: 'bind-',
    TokenType.closeElementEnd: '>',
    TokenType.closeElementStart: '</',
    TokenType.commentEnd: '-->',
    TokenType.commentStart: '<!--',
    TokenType.doubleQuote: '"',
    TokenType.eventPrefix: '(',
    TokenType.eventSuffix: ')',
    TokenType.interpolationEnd: '}}',
    TokenType.interpolationStart: '{{',
    TokenType.letPrefix: 'let-',
    TokenType.openElementEnd: '>',
    TokenType.openElementEndVoid: '/>',
    TokenType.openElementStart: '<',
    TokenType.onPrefix: 'on-',
    TokenType.propertyPrefix: '[',
    TokenType.propertySuffix: ']',
    TokenType.referencePrefix: '#',
    TokenType.singleQuote: "'",
    TokenType.templatePrefix: '*',
  };

  factory Token.generateErrorSynthetic(int offset, TokenType type, {String lexeme = ''}) {
    if (type == TokenType.beforeElementDecorator ||
        type == TokenType.elementDecoratorValue ||
        type == TokenType.elementDecorator ||
        type == TokenType.elementIdentifier ||
        type == TokenType.interpolationValue ||
        type == TokenType.text ||
        type == TokenType.whitespace ||
        type == TokenType.commentValue) {
      return LexemeToken(offset, lexeme, type, errorSynthetic: true);
    }

    return Token(type, offset, errorSynthetic: true);
  }

  factory Token.annotationPrefix(int offset) {
    return Token(TokenType.annotationPrefix, offset);
  }

  factory Token.bananaPrefix(int offset) {
    return Token(TokenType.bananaPrefix, offset);
  }

  factory Token.bananaSuffix(int offset) {
    return Token(TokenType.bananaSuffix, offset);
  }

  factory Token.beforeElementDecorator(int offset, String string) {
    return LexemeToken(offset, string, TokenType.beforeElementDecorator);
  }

  factory Token.beforeElementDecoratorValue(int offset) {
    return Token(TokenType.beforeElementDecoratorValue, offset);
  }

  factory Token.bindPrefix(int offset) {
    return Token(TokenType.bindPrefix, offset);
  }

  factory Token.closeElementEnd(int offset) {
    return Token(TokenType.closeElementEnd, offset);
  }

  factory Token.closeElementStart(int offset) {
    return Token(TokenType.closeElementStart, offset);
  }

  factory Token.commentEnd(int offset) {
    return Token(TokenType.commentEnd, offset);
  }

  factory Token.commentStart(int offset) {
    return Token(TokenType.commentStart, offset);
  }

  factory Token.commentValue(int offset, String string) {
    return LexemeToken(offset, string, TokenType.commentValue);
  }

  factory Token.doubleQuote(int offset) {
    return Token(TokenType.doubleQuote, offset);
  }

  factory Token.elementDecorator(int offset, String string) {
    return LexemeToken(offset, string, TokenType.elementDecorator);
  }

  factory Token.elementDecoratorValue(int offset, String string) {
    return LexemeToken(offset, string, TokenType.elementDecoratorValue);
  }

  factory Token.elementIdentifier(int offset, String string) {
    return LexemeToken(offset, string, TokenType.elementIdentifier);
  }

  factory Token.eventPrefix(int offset) {
    return Token(TokenType.eventPrefix, offset);
  }

  factory Token.eventSuffix(int offset) {
    return Token(TokenType.eventSuffix, offset);
  }

  factory Token.interpolationEnd(int offset) {
    return Token(TokenType.interpolationEnd, offset);
  }

  factory Token.interpolationStart(int offset) {
    return Token(TokenType.interpolationStart, offset);
  }

  factory Token.interpolationValue(int offset, String string) {
    return LexemeToken(offset, string, TokenType.interpolationValue);
  }

  factory Token.letPrefix(int offset) {
    return Token(TokenType.letPrefix, offset);
  }

  factory Token.openElementEnd(int offset) {
    return Token(TokenType.openElementEnd, offset);
  }

  factory Token.openElementEndVoid(int offset) {
    return Token(TokenType.openElementEndVoid, offset);
  }

  factory Token.openElementStart(int offset) {
    return Token(TokenType.openElementStart, offset);
  }

  factory Token.onPrefix(int offset) {
    return Token(TokenType.onPrefix, offset);
  }

  factory Token.propertyPrefix(int offset) {
    return Token(TokenType.propertyPrefix, offset);
  }

  factory Token.propertySuffix(int offset) {
    return Token(TokenType.propertySuffix, offset);
  }

  factory Token.referencePrefix(int offset) {
    return Token(TokenType.referencePrefix, offset);
  }

  factory Token.singleQuote(int offset) {
    return Token(TokenType.singleQuote, offset);
  }

  factory Token.templatePrefix(int offset) {
    return Token(TokenType.templatePrefix, offset);
  }

  factory Token.text(int offset, String string) {
    return LexemeToken(offset, string, TokenType.text);
  }

  factory Token.whitespace(int offset, String string) {
    return LexemeToken(offset, string, TokenType.whitespace);
  }

  const Token(this.type, this.offset, {this.errorSynthetic = false});

  @override
  final int offset;

  @override
  final TokenType type;

  final bool errorSynthetic;

  @override
  int get hashCode {
    return hash2(offset, type);
  }

  @override
  int get end {
    return offset + length;
  }

  @override
  int get length {
    return errorSynthetic ? 0 : lexeme.length;
  }

  @override
  String get lexeme {
    return lexemeMap[type]!;
  }

  @override
  bool operator ==(Object o) {
    if (o is Token) {
      if (errorSynthetic || o.errorSynthetic) {
        return o.offset == offset && o.type == type;
      }

      return o.offset == offset && o.type == type && o.lexeme == lexeme;
    }

    return false;
  }

  @override
  String toString() => '#$Token($type) {$offset:$lexeme}';
}

class AttributeValueToken extends Token {
  factory AttributeValueToken.generate(Token leftQuote, Token? innerValue, Token rightQuote) {
    return AttributeValueToken(leftQuote.offset, leftQuote, innerValue, rightQuote);
  }

  const AttributeValueToken(int offset, this.leftQuote, this.innerValue, this.rightQuote) : super(TokenType.elementDecoratorValue, offset);

  final Token? leftQuote;

  final Token? innerValue;

  final Token? rightQuote;

  bool get containsErrorSynthetic {
    return leftQuote!.errorSynthetic || innerValue!.errorSynthetic || rightQuote!.errorSynthetic;
  }

  @override
  bool operator ==(Object o) {
    if (o is AttributeValueToken) {
      return leftQuote == o.leftQuote && rightQuote == o.rightQuote && innerValue == o.innerValue;
    }

    return false;
  }

  @override
  int get end {
    return rightQuote!.end;
  }

  @override
  int get hashCode {
    return hash3(leftQuote, innerValue, rightQuote);
  }

  bool get isDoubleQuote {
    return leftQuote?.type == TokenType.doubleQuote;
  }

  bool get isSingleQuote {
    return leftQuote?.type == TokenType.singleQuote;
  }

  @override
  int get length {
    return leftQuote!.length + innerValue!.length + rightQuote!.length;
  }

  @override
  String get lexeme {
    return leftQuote!.lexeme + innerValue!.lexeme + rightQuote!.lexeme;
  }

  @override
  String toString() {
    return '#$AttributeValueToken($type) {$offset:$lexeme} [\n\t$leftQuote,\n\t$innerValue,\n\t$rightQuote]';
  }
}
