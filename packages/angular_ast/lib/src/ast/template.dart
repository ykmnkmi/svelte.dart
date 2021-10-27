import 'package:collection/collection.dart' show ListEquality;
import 'package:source_span/source_span.dart' show SourceFile;

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

const ListEquality<Object?> listEquals = ListEquality<Object?>();

abstract class EmbeddedNode implements Standalone {
  factory EmbeddedNode(
      {List<Annotation> annotations,
      List<Attribute> attributes,
      List<Standalone> childNodes,
      List<Event> events,
      List<Property> properties,
      List<Reference> references,
      List<LetBinding> letBindings}) = _SyntheticEmbeddedTemplate;

  factory EmbeddedNode.from(Node origin,
      {List<Annotation> annotations,
      List<Attribute> attributes,
      List<Standalone> childNodes,
      List<Event> events,
      List<Property> properties,
      List<Reference> references,
      List<LetBinding> letBindings}) = _SyntheticEmbeddedTemplate.from;

  factory EmbeddedNode.parsed(SourceFile sourceFile, Token beginToken, Token endToken,
      {CloseElement? closeComplement,
      List<Annotation> annotations,
      List<Attribute> attributes,
      List<Standalone> childNodes,
      List<Event> events,
      List<Property> properties,
      List<Reference> references,
      List<LetBinding> letBindings}) = _ParsedEmbeddedTemplate;

  CloseElement? get closeComplement;

  set closeComplement(CloseElement? closeComplement);

  List<Annotation> get annotations;

  List<Attribute> get attributes;

  List<Event> get events;

  List<Property> get properties;

  List<Reference> get references;

  List<LetBinding> get letBindings;

  @override
  int get hashCode {
    return Object.hashAll(<Object?>[
      closeComplement,
      listEquals.hash(annotations),
      listEquals.hash(attributes),
      listEquals.hash(events),
      listEquals.hash(childNodes),
      listEquals.hash(properties),
      listEquals.hash(references),
      listEquals.hash(letBindings),
    ]);
  }

  @override
  bool operator ==(Object? other) {
    return other is EmbeddedNode &&
        closeComplement == other.closeComplement &&
        listEquals.equals(annotations, other.annotations) &&
        listEquals.equals(attributes, other.attributes) &&
        listEquals.equals(events, other.events) &&
        listEquals.equals(properties, other.properties) &&
        listEquals.equals(childNodes, other.childNodes) &&
        listEquals.equals(references, other.references) &&
        listEquals.equals(letBindings, other.letBindings);
  }

  @override
  R? accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitEmbeddedTemplate(this, context);
  }

  @override
  String toString() {
    var buffer = StringBuffer('EmbeddedTemplateAst{ ');

    if (annotations.isNotEmpty) {
      buffer
        ..write('annotations=')
        ..writeAll(attributes, ', ')
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

    if (letBindings.isNotEmpty) {
      buffer
        ..write('letBindings=')
        ..writeAll(letBindings, ', ')
        ..write(' ');
    }

    if (childNodes.isNotEmpty) {
      buffer
        ..write('childNodes=')
        ..writeAll(childNodes, ', ')
        ..write(' ');
    }

    if (closeComplement != null) {
      buffer
        ..write('closeComplement=')
        ..write(closeComplement)
        ..write(' ');
    }

    return (buffer..write('}')).toString();
  }
}

class _ParsedEmbeddedTemplate extends Node with EmbeddedNode {
  _ParsedEmbeddedTemplate(SourceFile sourceFile, Token beginToken, Token endToken,
      {this.closeComplement,
      this.annotations = const <Annotation>[],
      this.attributes = const <Attribute>[],
      this.childNodes = const <Standalone>[],
      this.events = const <Event>[],
      this.properties = const <Property>[],
      this.references = const <Reference>[],
      this.letBindings = const <LetBinding>[]})
      : super.parsed(beginToken, endToken, sourceFile);

  @override
  CloseElement? closeComplement;

  @override
  final List<Annotation> annotations;

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
  final List<LetBinding> letBindings;
}

class _SyntheticEmbeddedTemplate extends Synthetic with EmbeddedNode {
  _SyntheticEmbeddedTemplate(
      {this.annotations = const <Annotation>[],
      this.attributes = const <Attribute>[],
      this.childNodes = const <Standalone>[],
      this.events = const <Event>[],
      this.properties = const <Property>[],
      this.references = const <Reference>[],
      this.letBindings = const <LetBinding>[]})
      : closeComplement = CloseElement('template');

  _SyntheticEmbeddedTemplate.from(Node origin,
      {this.annotations = const <Annotation>[],
      this.attributes = const <Attribute>[],
      this.childNodes = const <Standalone>[],
      this.events = const <Event>[],
      this.properties = const <Property>[],
      this.references = const <Reference>[],
      this.letBindings = const <LetBinding>[]})
      : closeComplement = CloseElement('template'),
        super.from(origin);

  @override
  CloseElement? closeComplement;

  @override
  final List<Annotation> annotations;

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
  final List<LetBinding> letBindings;
}
