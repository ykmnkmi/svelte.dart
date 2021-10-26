import 'package:collection/collection.dart';
import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

const ListEquality<Object?> _listEquals = ListEquality<Object?>();

/// Represents a DOM element that was parsed, that could be upgraded.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class Element implements StandaloneTemplate {
  /// Create a synthetic element AST.
  factory Element(String name, CloseElement? closeComplement,
      {List<Attribute> attributes,
      List<StandaloneTemplate> childNodes,
      List<Event> events,
      List<Property> properties,
      List<Reference> references,
      List<Banana> bananas,
      List<Star> stars,
      List<Annotation> annotations}) = _SyntheticElement;

  /// Create a synthetic element AST from an existing AST node.
  factory Element.from(Template origin, String name, CloseElement? closeComplement,
      {List<Attribute> attributes,
      List<StandaloneTemplate> childNodes,
      List<Event> events,
      List<Property> properties,
      List<Reference> references,
      List<Banana> bananas,
      List<Star> stars,
      List<Annotation> annotations}) = _SyntheticElement.from;

  /// Create a new element AST from parsed source.
  factory Element.parsed(SourceFile sourceFile, NgToken openElementStart, NgToken nameToken, NgToken openElementEnd,
      {CloseElement? closeComplement,
      List<Attribute> attributes,
      List<StandaloneTemplate> childNodes,
      List<Event> events,
      List<Property> properties,
      List<Reference> references,
      List<Banana> bananas,
      List<Star> stars,
      List<Annotation> annotations}) = ParsedElement;

  /// Name (tag) of the element.
  String get name;

  /// CloseElement complement
  ///
  /// If [closeComplement] == null, then [isVoidElement] is true.
  CloseElement? get closeComplement;

  set closeComplement(CloseElement? closeElementAst);

  /// Attributes.
  List<Attribute> get attributes;

  /// Event listeners.
  List<Event> get events;

  /// Property assignments.
  List<Property> get properties;

  /// Reference assignments.
  List<Reference> get references;

  /// Bananas assignments.
  List<Banana> get bananas;

  /// Star assignments.
  List<Star> get stars;

  /// Annotation assignments.
  List<Annotation> get annotations;

  /// Determines whether the element tag name is void element.
  bool get isVoidElement;

  @override
  int get hashCode {
    return Object.hashAll(<Object?>[
      name,
      closeComplement,
      _listEquals.hash(attributes),
      _listEquals.hash(childNodes),
      _listEquals.hash(events),
      _listEquals.hash(properties),
      _listEquals.hash(references),
      _listEquals.hash(bananas),
      _listEquals.hash(stars),
      _listEquals.hash(annotations),
    ]);
  }

  @override
  bool operator ==(Object? other) {
    return other is Element &&
        name == other.name &&
        closeComplement == other.closeComplement &&
        _listEquals.equals(attributes, other.attributes) &&
        _listEquals.equals(childNodes, other.childNodes) &&
        _listEquals.equals(events, other.events) &&
        _listEquals.equals(properties, other.properties) &&
        _listEquals.equals(references, other.references) &&
        _listEquals.equals(bananas, other.bananas) &&
        _listEquals.equals(stars, other.stars) &&
        _listEquals.equals(annotations, other.annotations);
  }

  @override
  R? accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitElement(this, context);
  }

  @override
  String toString() {
    var buffer = StringBuffer('ElementAst <$name> { ');

    if (closeComplement != null) {
      buffer
        ..write('closeComplement=')
        ..write(closeComplement)
        ..write(' ');
    }

    if (attributes.isNotEmpty) {
      buffer
        ..write('attributes=')
        ..writeAll(attributes, ', ')
        ..write(' ');
    }

    if (events.isNotEmpty) {
      buffer
        ..write('events=')
        ..writeAll(events, ', ')
        ..write(' ');
    }

    if (properties.isNotEmpty) {
      buffer
        ..write('properties=')
        ..writeAll(properties, ', ')
        ..write(' ');
    }

    if (references.isNotEmpty) {
      buffer
        ..write('references=')
        ..writeAll(references, ', ')
        ..write(' ');
    }

    if (bananas.isNotEmpty) {
      buffer
        ..write('bananas=')
        ..writeAll(bananas, ', ')
        ..write(' ');
    }

    if (stars.isNotEmpty) {
      buffer
        ..write('stars=')
        ..writeAll(stars, ', ')
        ..write(' ');
    }

    if (annotations.isNotEmpty) {
      buffer
        ..write('annotations=')
        ..writeAll(annotations, ', ')
        ..write(' ');
    }

    if (childNodes.isNotEmpty) {
      buffer
        ..write('childNodes=')
        ..writeAll(childNodes, ', ')
        ..write(' ');
    }
    buffer.write('}');
    return buffer.toString();
  }
}

/// Represents a real, non-synthetic DOM element that was parsed,
/// that could be upgraded.
///
/// Clients should not extend, implement, or mix-in this class.
class ParsedElement extends Template with Element {
  ParsedElement(SourceFile sourceFile, NgToken openElementStart, this.identifierToken, NgToken openElementEnd,
      {this.closeComplement,
      this.attributes = const <Attribute>[],
      this.childNodes = const <StandaloneTemplate>[],
      this.events = const <Event>[],
      this.properties = const <Property>[],
      this.references = const <Reference>[],
      this.bananas = const <Banana>[],
      this.stars = const <Star>[],
      this.annotations = const <Annotation>[]})
      : super.parsed(openElementStart, openElementEnd, sourceFile);

  /// [NgToken] that represents the identifier tag in `<tag ...>`.
  final NgToken identifierToken;

  /// CloseElementAst that complements this elementAst.
  @override
  CloseElement? closeComplement;

  /// Attributes
  @override
  final List<Attribute> attributes;

  /// Children nodes.
  @override
  final List<StandaloneTemplate> childNodes;

  /// Event listeners.
  @override
  final List<Event> events;

  /// Property assignments.
  @override
  final List<Property> properties;

  /// Reference assignments.
  @override
  final List<Reference> references;

  /// Banana assignments.
  @override
  final List<Banana> bananas;

  /// Star assignments.
  @override
  final List<Star> stars;

  /// Annotation assignments.
  @override
  final List<Annotation> annotations;

  /// Name (tag) of the element.
  @override
  String get name {
    return identifierToken.lexeme;
  }

  @override
  bool get isVoidElement {
    return closeComplement == null;
  }
}

class _SyntheticElement extends SyntheticTemplate with Element {
  _SyntheticElement(this.name, this.closeComplement,
      {this.attributes = const <Attribute>[],
      this.childNodes = const <StandaloneTemplate>[],
      this.events = const <Event>[],
      this.properties = const <Property>[],
      this.references = const <Reference>[],
      this.bananas = const <Banana>[],
      this.stars = const <Star>[],
      this.annotations = const <Annotation>[]});

  _SyntheticElement.from(Template origin, this.name, this.closeComplement,
      {this.attributes = const <Attribute>[],
      this.childNodes = const <StandaloneTemplate>[],
      this.events = const <Event>[],
      this.properties = const <Property>[],
      this.references = const <Reference>[],
      this.bananas = const <Banana>[],
      this.stars = const <Star>[],
      this.annotations = const <Annotation>[]})
      : super.from(origin);

  @override
  final String name;

  @override
  CloseElement? closeComplement;

  @override
  final List<Attribute> attributes;

  @override
  final List<StandaloneTemplate> childNodes;

  @override
  final List<Event> events;

  @override
  final List<Property> properties;

  @override
  final List<Reference> references;

  @override
  final List<Banana> bananas;

  @override
  final List<Star> stars;

  @override
  final List<Annotation> annotations;

  @override
  bool get isVoidElement {
    return closeComplement == null;
  }
}
