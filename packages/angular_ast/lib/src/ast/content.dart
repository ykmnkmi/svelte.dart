import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

/// Represents an `<ng-content>` element AST.
///
/// Embedded content is _like_ an `ElementAst`, but only contains children.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class EmbeddedContent implements StandaloneTemplate {
  /// Create a synthetic embedded content AST.
  factory EmbeddedContent([String selector, String ngProjectAs, Reference reference]) =
      _SyntheticEmbeddedContent;

  /// Create a synthetic [EmbeddedContent] that originated from [origin].
  factory EmbeddedContent.from(Template origin, [String selector, String ngProjectAs, Reference reference]) =
      _SyntheticEmbeddedContent.from;

  /// Create a new [EmbeddedContent] parsed from tokens in [sourceFile].
  factory EmbeddedContent.parsed(SourceFile sourceFile, NgToken startElementToken, NgToken elementIdentifierToken,
      NgToken endElementToken, CloseElement closeComplement,
      [Attribute? selectAttribute,
      Attribute? ngProjectAsAttribute,
      Reference? reference]) = ParsedEmbeddedContent;

  /// A CSS selector denoting what elements should be embedded.
  ///
  /// May be null if and only if decorator 'select' is defined,
  /// but no value is assigned.
  /// If 'select' is not defined at all (simple <ng-content>), then the value
  /// will default to '*'.
  String? get selector;

  /// A CSS selector denoting what this embedded content should be projected as.
  ///
  /// May be null if decorator `ngProjectAs` is not defined.
  String? get ngProjectAs;

  /// Reference assignment.
  Reference? get reference;

  /// </ng-content> that is paired to this <ng-content>.
  CloseElement get closeComplement;

  set closeComplement(CloseElement closeComplement);

  @override
  int get hashCode {
    return Object.hash(selector.hashCode, ngProjectAs.hashCode, reference, closeComplement);
  }

  @override
  bool operator ==(Object? other) {
    return other is EmbeddedContent &&
        other.selector == selector &&
        other.ngProjectAs == ngProjectAs &&
        other.reference == reference &&
        other.closeComplement == closeComplement;
  }

  @override
  R accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitEmbeddedContent(this, context);
  }

  @override
  String toString() {
    return 'EmbeddedContentAst {$selector, $ngProjectAs, $reference}';
  }
}

class ParsedEmbeddedContent extends Template with EmbeddedContent {
  ParsedEmbeddedContent(SourceFile sourceFile, NgToken startElementToken, this.identifierToken,
      NgToken endElementToken, this.closeComplement,
      [this.selectAttribute, this.ngProjectAsAttribute, this.reference])
      : super.parsed(startElementToken, endElementToken, sourceFile);

  // Token for 'ng-content'.
  final NgToken identifierToken;

  // Select assignment.
  final Attribute? selectAttribute;

  // NgProjectAs assignment.
  final Attribute? ngProjectAsAttribute;

  // Reference assignment.
  @override
  final Reference? reference;

  @override
  CloseElement closeComplement;

  @override
  // '<ng-content select>' ; no value was defined.
  // Return null to handle later.
  String? get selector {
    if (selectAttribute?.name != null && selectAttribute!.value == null) {
      return null;
    }

    return selectAttribute?.value ?? '*';
  }

  @override
  String? get ngProjectAs {
    return ngProjectAsAttribute?.value;
  }
}

class _SyntheticEmbeddedContent extends SyntheticTemplate with EmbeddedContent {
  _SyntheticEmbeddedContent([this.selector = '*', this.ngProjectAs, this.reference]) {
    closeComplement = CloseElement('ng-content');
  }

  _SyntheticEmbeddedContent.from(Template origin, [this.selector = '*', this.ngProjectAs, this.reference])
      : super.from(origin) {
    closeComplement = CloseElement('ng-content');
  }

  @override
  final String selector;

  @override
  final String? ngProjectAs;

  @override
  final Reference? reference;

  @override
  late CloseElement closeComplement;
}
