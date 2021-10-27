class MicroToken {
  factory MicroToken.bindExpressionBefore(int offset, String lexeme) {
    return MicroToken(MicroTokenType.bindExpressionBefore, lexeme, offset);
  }

  factory MicroToken.bindExpression(int offset, String lexeme) {
    return MicroToken(MicroTokenType.bindExpression, lexeme, offset);
  }

  factory MicroToken.bindIdentifier(int offset, String lexeme) {
    return MicroToken(MicroTokenType.bindIdentifier, lexeme, offset);
  }

  factory MicroToken.endExpression(int offset, String lexeme) {
    return MicroToken(MicroTokenType.endExpression, lexeme, offset);
  }

  factory MicroToken.letAssignment(int offset, String lexeme) {
    return MicroToken(MicroTokenType.letAssignment, lexeme, offset);
  }

  factory MicroToken.letAssignmentBefore(int offset, String lexeme) {
    return MicroToken(MicroTokenType.letAssignmentBefore, lexeme, offset);
  }

  factory MicroToken.letIdentifier(int offset, String lexeme) {
    return MicroToken(MicroTokenType.letIdentifier, lexeme, offset);
  }

  factory MicroToken.letKeyword(int offset, String lexeme) {
    return MicroToken(MicroTokenType.letKeyword, lexeme, offset);
  }

  factory MicroToken.letKeywordAfter(int offset, String lexeme) {
    return MicroToken(MicroTokenType.letKeywordAfter, lexeme, offset);
  }

  const MicroToken(this.type, this.lexeme, this.offset);

  final String lexeme;

  final int offset;

  final MicroTokenType type;

  int get end {
    return offset + length;
  }

  int get length {
    return lexeme.length;
  }

  @override
  int get hashCode {
    return Object.hash(offset, lexeme, type);
  }

  @override
  bool operator ==(Object? other) {
    return other is MicroToken && other.offset == offset && other.type == type;
  }

  @override
  String toString() {
    return '#NgMicroToken(${type.name}) {$offset:$lexeme}';
  }
}

class MicroTokenType {
  static const MicroTokenType endExpression = MicroTokenType('endExpression');

  static const MicroTokenType bindExpression = MicroTokenType('bindExpression');

  static const MicroTokenType bindExpressionBefore = MicroTokenType('bindExpressionBefore');

  static const MicroTokenType bindIdentifier = MicroTokenType('bindIdentifier');

  static const MicroTokenType letAssignment = MicroTokenType('letAssignment');

  static const MicroTokenType letAssignmentBefore = MicroTokenType('letAssignmentBefore');

  static const MicroTokenType letIdentifier = MicroTokenType('letIdentifier');

  static const MicroTokenType letKeyword = MicroTokenType('letKeyword');

  static const MicroTokenType letKeywordAfter = MicroTokenType('letKeywordAfter');

  const MicroTokenType(this.name);

  final String name;
}
