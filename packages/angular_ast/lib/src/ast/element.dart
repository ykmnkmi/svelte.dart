import 'package:collection/collection.dart' show ListEquality;
import 'package:source_span/source_span.dart' show SourceFile;

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

const ListEquality<Object?> listEquals = ListEquality<Object?>();

abstract class Element implements Standalone {
  factory Element(String name, CloseElement? closeComplement,
      {List<Attribute> attributes,
      List<Standalone> childNodes,
      List<Event> events,
      List<Property> properties,
      List<Reference> references,
      List<Banana> bananas,
      List<Star> stars,
      List<Annotation> annotations}) = _SyntheticElement;

  factory Element.from(Node origin, String name, CloseElement? closeComplement,
      {List<Attribute> attributes,
      List<Standalone> childNodes,
      List<Event> events,
      List<Property> properties,
      List<Reference> references,
      List<Banana> bananas,
      List<Star> stars,
      List<Annotation> annotations}) = _SyntheticElement.from;

  factory Element.parsed(SourceFile sourceFile, Token openElementStart, Token nameToken, Token openElementEnd,
      {CloseElement? closeComplement,
      List<Attribute> attributes,
      List<Standalone> childNodes,
      List<Event> events,
      List<Property> properties,
      List<Reference> references,
      List<Banana> bananas,
      List<Star> stars,
      List<Annotation> annotations}) = ParsedElement;

  String get name;

  CloseElement? get closeComplement;

  set closeComplement(CloseElement? closeElementAst);

  List<Attribute> get attributes;

  List<Event> get events;

  List<Property> get properties;

  List<Reference> get references;

  List<Banana> get bananas;

  List<Star> get stars;

  List<Annotation> get annotations;

  bool get isVoidElement;

  @override
  int get hashCode {
    return Object.hashAll(<Object?>[
      name,
      closeComplement,
      listEquals.hash(attributes),
      listEquals.hash(childNodes),
      listEquals.hash(events),
      listEquals.hash(properties),
      listEquals.hash(references),
      listEquals.hash(bananas),
      listEquals.hash(stars),
      listEquals.hash(annotations),
    ]);
  }

  @override
  bool operator ==(Object? other) {
    return other is Element &&
        name == other.name &&
        closeComplement == other.closeComplement &&
        listEquals.equals(attributes, other.attributes) &&
        listEquals.equals(childNodes, other.childNodes) &&
        listEquals.equals(events, other.events) &&
        listEquals.equals(properties, other.properties) &&
        listEquals.equals(references, other.references) &&
        listEquals.equals(bananas, other.bananas) &&
        listEquals.equals(stars, other.stars) &&
        listEquals.equals(annotations, other.annotations);
  }

  @override
  R? accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
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

class ParsedElement extends Node with Element {
  ParsedElement(SourceFile sourceFile, Token openElementStart, this.identifierToken, Token openElementEnd,
      {this.closeComplement,
      this.attributes = const <Attribute>[],
      this.childNodes = const <Standalone>[],
      this.events = const <Event>[],
      this.properties = const <Property>[],
      this.references = const <Reference>[],
      this.bananas = const <Banana>[],
      this.stars = const <Star>[],
      this.annotations = const <Annotation>[]})
      : super.parsed(openElementStart, openElementEnd, sourceFile);

  final Token identifierToken;

  @override
  CloseElement? closeComplement;

  @override
  final List<Attribute> attributes;

  @override
  final List<Standalone> childNodes;

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
  String get name {
    return identifierToken.lexeme;
  }

  @override
  bool get isVoidElement {
    return closeComplement == null;
  }
}

class _SyntheticElement extends Synthetic with Element {
  _SyntheticElement(this.name, this.closeComplement,
      {this.attributes = const <Attribute>[],
      this.childNodes = const <Standalone>[],
      this.events = const <Event>[],
      this.properties = const <Property>[],
      this.references = const <Reference>[],
      this.bananas = const <Banana>[],
      this.stars = const <Star>[],
      this.annotations = const <Annotation>[]});

  _SyntheticElement.from(Node origin, this.name, this.closeComplement,
      {this.attributes = const <Attribute>[],
      this.childNodes = const <Standalone>[],
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
  final List<Standalone> childNodes;

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
