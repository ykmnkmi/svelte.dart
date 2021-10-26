import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

/// Represents a comment block of static text.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class Comment implements StandaloneTemplate {
  /// Create a new synthetic [Comment] with a string [value].
  factory Comment(String value) = _SyntheticComment;

  /// Create a new synthetic [Comment] that originated from node [origin].
  factory Comment.from(Template origin, String value) = _SyntheticComment.from;

  /// Create a new [Comment] parsed from tokens in [sourceFile].
  factory Comment.parsed(
      SourceFile sourceFile, NgToken startCommentToken, NgToken valueToken, NgToken endCommentToken) = _ParsedComment;

  @override
  int get hashCode {
    return value.hashCode;
  }

  /// Static text value.
  String get value;

  @override
  bool operator ==(Object? other) {
    return other is Comment && value == other.value;
  }

  @override
  R accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitComment(this, context);
  }

  @override
  String toString() {
    return 'CommentAst {$value}';
  }
}

class _ParsedComment extends Template with Comment {
  _ParsedComment(SourceFile sourceFile, NgToken startCommentToken, this._valueToken, NgToken endCommentToken)
      : super.parsed(startCommentToken, endCommentToken, sourceFile);

  final NgToken _valueToken;

  @override
  String get value => _valueToken.lexeme;
}

class _SyntheticComment extends SyntheticTemplate with Comment {
  _SyntheticComment(this.value);

  _SyntheticComment.from(Template origin, this.value) : super.from(origin);

  @override
  final String value;
}
