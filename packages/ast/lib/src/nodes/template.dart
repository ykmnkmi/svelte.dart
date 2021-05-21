import 'package:collection/collection.dart';

import '../hash.dart';
import '../nodes.dart';
import '../token/tokens.dart';
import '../visitor.dart';

const ListEquality<Object?> listEquals = ListEquality<Object?>();

class Embedded extends Node {
  Embedded(
    Token beginToken,
    Token endToken, {
    this.closeComplement,
    this.annotations = const <Annotation>[],
    this.attributes = const <Attribute>[],
    this.childNodes = const <Node>[],
    this.events = const <Event>[],
    this.properties = const <Property>[],
    this.references = const <Reference>[],
    this.letBindings = const <LetBinding>[],
  }) : super(beginToken, endToken);

  final List<Annotation> annotations;

  final List<Attribute> attributes;

  final List<Event> events;

  final List<Property> properties;

  final List<Reference> references;

  final List<LetBinding> letBindings;

  @override
  final List<Node> childNodes;

  CloseElement? closeComplement;

  @override
  int get hashCode {
    return hashObjects(<Object?>[
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
    if (other is Embedded) {
      return closeComplement == other.closeComplement &&
          listEquals.equals(annotations, other.annotations) &&
          listEquals.equals(attributes, other.attributes) &&
          listEquals.equals(events, other.events) &&
          listEquals.equals(properties, other.properties) &&
          listEquals.equals(childNodes, other.childNodes) &&
          listEquals.equals(references, other.references) &&
          listEquals.equals(letBindings, other.letBindings);
    }
    return false;
  }

  @override
  R? accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
    return visitor.visitEmbedded(this, context);
  }

  @override
  String toString() {
    final buffer = StringBuffer('$Embedded{ ');

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
      buffer..write('closeComplement=')..write(closeComplement)..write(' ');
    }

    buffer.write('}');
    return buffer.toString();
  }
}
