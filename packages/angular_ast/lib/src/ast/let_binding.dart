import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

/// Represents a 'let-' binding attribute within a <template> AST.
/// This AST cannot exist anywhere else except as part of the attribute
/// for a [EmbeddedTemplateAst].
///
/// Clients should not extend, implement, or mix-in this class.
abstract class LetBinding implements Template {
  /// Create a new synthetic [LetBinding] listening to [name].
  /// [value] is an optional parameter, which indicates that the variable is
  /// bound to a the value '$implicit'.
  factory LetBinding(String name, [String value]) = _SyntheticLetBinding;

  /// Create a new synthetic [LetBinding] that originated from [origin].
  factory LetBinding.from(Template? origin, String name, [String value]) = _SyntheticLetBinding.from;

  /// Create a new [LetBinding] parsed from tokens in [sourceFile].
  /// The [prefixToken] is the 'let-' component, the [elementDecoratorToken]
  /// is the variable name, and [valueToken] is the value bound to the
  /// variable.
  factory LetBinding.parsed(SourceFile sourceFile, NgToken prefixToken, NgToken elementDecoratorToken,
      [NgAttributeValueToken? valueToken, NgToken? equalSignToken]) = ParsedLetBinding;

  /// Name of the variable.
  String get name;

  /// Name of the value assigned to the variable.
  String? get value;

  @override
  int get hashCode {
    return Object.hash(name, value);
  }

  @override
  bool operator ==(Object? other) {
    return other is LetBinding && name == other.name && value == other.value;
  }

  @override
  R accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitLetBinding(this, context);
  }

  @override
  String toString() {
    if (value == null) {
      return 'LetBindingAst {let-$name}';
    }

    return 'LetBindingAst {let-$name="$value"}';
  }
}

/// Represents a real, non-synthetic `let-` binding: `let-var="value"`.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedLetBinding extends Template with LetBinding implements ParsedDecorator, TagOffsetInfo {
  ParsedLetBinding(SourceFile sourceFile, this.prefixToken, this.nameToken, [this.valueToken, this.equalSignToken])
      : super.parsed(prefixToken, valueToken == null ? nameToken : valueToken.rightQuote, sourceFile);

  @override
  final NgToken prefixToken;

  @override
  final NgToken nameToken;

  /// [NgAttributeValueToken] that represents the value bound to the
  /// let- variable; may be `null` to have no value implying $implicit.
  @override
  final NgAttributeValueToken? valueToken;

  /// [NgToken] that represents the equal sign; may be `null` to have no
  /// value.
  final NgToken? equalSignToken;

  /// Offset of `let` prefix in `let-someVariable`.
  @override
  int get prefixOffset {
    return prefixToken.offset;
  }

  /// Name of the variable following `let-`.
  @override
  String get name {
    return nameToken.lexeme;
  }

  /// Offset of the variable following `let-`.
  @override
  int get nameOffset {
    return nameToken.offset;
  }

  /// Offset of equal sign; may be `null` if no value.
  @override
  int? get equalSignOffset {
    return equalSignToken?.offset;
  }

  @override
  String? get value {
    return valueToken?.innerValue?.lexeme;
  }

  @override
  int? get valueOffset {
    return valueToken?.innerValue?.offset;
  }

  /// Offset of value starting at left quote; may be `null` to have no value.
  @override
  int? get quotedValueOffset {
    return valueToken?.leftQuote?.offset;
  }

  /// [suffixToken] will always be null for this AST.
  @override
  NgToken? get suffixToken {
    return null;
  }

  /// There is no suffix token, always returns null.
  @override
  int? get suffixOffset {
    return null;
  }
}

class _SyntheticLetBinding extends SyntheticTemplate with LetBinding {
  _SyntheticLetBinding(this.name, [this.value]);

  _SyntheticLetBinding.from(Template? origin, this.name, [this.value]) : super.from(origin);

  @override
  final String name;

  @override
  final String? value;
}
