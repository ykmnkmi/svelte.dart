import 'package:source_span/source_span.dart' show SourceFile;

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

abstract class Comment implements Standalone {
  factory Comment(String value) = _SyntheticComment;

  factory Comment.from(Node origin, String value) = _SyntheticComment.from;

  factory Comment.parsed(SourceFile sourceFile, Token startCommentToken, Token valueToken, Token endCommentToken) =
      _ParsedComment;

  @override
  int get hashCode {
    return value.hashCode;
  }

  String get value;

  @override
  bool operator ==(Object? other) {
    return other is Comment && value == other.value;
  }

  @override
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitComment(this, context);
  }

  @override
  String toString() {
    return 'CommentAst {$value}';
  }
}

class _ParsedComment extends Node with Comment {
  _ParsedComment(SourceFile sourceFile, Token startCommentToken, this._valueToken, Token endCommentToken)
      : super.parsed(startCommentToken, endCommentToken, sourceFile);

  final Token _valueToken;

  @override
  String get value => _valueToken.lexeme;
}

class _SyntheticComment extends Synthetic with Comment {
  _SyntheticComment(this.value);

  _SyntheticComment.from(Node origin, this.value) : super.from(origin);

  @override
  final String value;
}
