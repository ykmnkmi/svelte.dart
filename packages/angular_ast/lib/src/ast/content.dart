import 'package:source_span/source_span.dart' show SourceFile;

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

abstract class EmbeddedContent implements Standalone {
  factory EmbeddedContent([String selector, String ngProjectAs, Reference reference]) = _SyntheticEmbeddedContent;

  factory EmbeddedContent.from(Node origin, [String selector, String ngProjectAs, Reference reference]) =
      _SyntheticEmbeddedContent.from;

  factory EmbeddedContent.parsed(SourceFile sourceFile, Token startElementToken, Token elementIdentifierToken,
      Token endElementToken, CloseElement closeComplement,
      [Attribute? selectAttribute, Attribute? ngProjectAsAttribute, Reference? reference]) = ParsedEmbeddedContent;

  String? get selector;

  String? get ngProjectAs;

  Reference? get reference;

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
  R accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitEmbeddedContent(this, context);
  }

  @override
  String toString() {
    return 'EmbeddedContentAst {$selector, $ngProjectAs, $reference}';
  }
}

class ParsedEmbeddedContent extends Node with EmbeddedContent {
  ParsedEmbeddedContent(
      SourceFile sourceFile, Token startElementToken, this.identifierToken, Token endElementToken, this.closeComplement,
      [this.selectAttribute, this.ngProjectAsAttribute, this.reference])
      : super.parsed(startElementToken, endElementToken, sourceFile);

  // Token for 'ng-content'.
  final Token identifierToken;

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

class _SyntheticEmbeddedContent extends Synthetic with EmbeddedContent {
  _SyntheticEmbeddedContent([this.selector = '*', this.ngProjectAs, this.reference]) {
    closeComplement = CloseElement('ng-content');
  }

  _SyntheticEmbeddedContent.from(Node origin, [this.selector = '*', this.ngProjectAs, this.reference])
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
