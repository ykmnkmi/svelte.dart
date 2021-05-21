part of 'tokens.dart';

class LexemeSimpleToken extends SimpleToken {
  const LexemeSimpleToken(int offset, this.lexeme, this.length, SimpleTokenType type) : super(type, offset);

  @override
  final String lexeme;

  @override
  final int length;

  @override
  int get hashCode => hash2(super.hashCode, lexeme);

  @override
  bool operator ==(Object? o) {
    if (o is LexemeSimpleToken) {
      return super == o && lexeme == o.lexeme;
    }
    return false;
  }
}

class LexemeToken extends Token {
  const LexemeToken(int offset, this.lexeme, TokenType type, {bool errorSynthetic = false}) : super(type, offset, errorSynthetic: errorSynthetic);

  @override
  final String lexeme;

  @override
  int get hashCode {
    return hash2(super.hashCode, lexeme);
  }

  @override
  bool operator ==(Object? o) {
    if (o is LexemeToken) {
      return super == o && lexeme == o.lexeme;
    }
    return false;
  }
}
