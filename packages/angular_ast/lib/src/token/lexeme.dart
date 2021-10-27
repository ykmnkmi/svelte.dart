part of angular_ast.src.token.tokens;

class LexemeSimpleToken extends SimpleToken {
  const LexemeSimpleToken(int offset, this.lexeme, this.length, SimpleTokenType type) : super(type, offset);

  @override
  final String lexeme;

  @override
  final int length;

  @override
  int get hashCode {
    return Object.hash(super.hashCode, lexeme);
  }

  @override
  bool operator ==(Object? other) {
    return other is LexemeSimpleToken && super == other && lexeme == other.lexeme;
  }
}

class LexemeToken extends Token {
  const LexemeToken(int offset, this.lexeme, TokenType type, {bool errorSynthetic = false})
      : super(type, offset, errorSynthetic: errorSynthetic);

  @override
  final String lexeme;

  @override
  int get hashCode {
    return Object.hash(super.hashCode, lexeme);
  }

  @override
  bool operator ==(Object? other) {
    return other is LexemeToken && super == other && lexeme == other.lexeme;
  }
}
