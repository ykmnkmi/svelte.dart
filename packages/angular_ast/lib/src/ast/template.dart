import 'package:collection/collection.dart';
import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

const _listEquals = ListEquality<dynamic>();

/// Represents an embedded template (i.e. is not directly rendered in DOM).
///
/// It shares many properties with an [Element], but is not one. It may be
/// considered invalid to a `<template>` without any [properties] or
/// [references].
///
/// Clients should not extend, implement, or mix-in this class.
abstract class EmbeddedTemplateAst implements StandaloneTemplate {
  factory EmbeddedTemplateAst(
      {List<Annotation> annotations,
      List<Attribute> attributes,
      List<StandaloneTemplate> childNodes,
      List<Event> events,
      List<Property> properties,
      List<Reference> references,
      List<LetBinding> letBindings}) = _SyntheticEmbeddedTemplate;

  factory EmbeddedTemplateAst.from(Template origin,
      {List<Annotation> annotations,
      List<Attribute> attributes,
      List<StandaloneTemplate> childNodes,
      List<Event> events,
      List<Property> properties,
      List<Reference> references,
      List<LetBinding> letBindings}) = _SyntheticEmbeddedTemplate.from;

  factory EmbeddedTemplateAst.parsed(SourceFile sourceFile, NgToken beginToken, NgToken endToken,
      {CloseElement? closeComplement,
      List<Annotation> annotations,
      List<Attribute> attributes,
      List<StandaloneTemplate> childNodes,
      List<Event> events,
      List<Property> properties,
      List<Reference> references,
      List<LetBinding> letBindings}) = _ParsedEmbeddedTemplate;

  /// </template> that is paired to this <template>.
  CloseElement? get closeComplement;

  set closeComplement(CloseElement? closeComplement);

  /// Annotations.
  List<Annotation> get annotations;

  /// Attributes.
  ///
  /// Within a `<template>` tag, it may be assumed that this is a directive.
  List<Attribute> get attributes;

  /// Events.
  ///
  /// Within a `<template>` tag, it may be assumed that this is a directive.
  List<Event> get events;

  /// Property assignments.
  ///
  /// For an embedded template, it may be assumed that all of this will be one
  /// or more structural directives (i.e. like `ngForOf`), as the template
  /// itself does not have properties.
  List<Property> get properties;

  /// References to the template.
  ///
  /// Unlike a reference to a DOM element, this will be a `TemplateRef`.
  List<Reference> get references;

  /// `let-` binding defined within a template.
  List<LetBinding> get letBindings;

  @override
  int get hashCode {
    return Object.hashAll(<Object?>[
      closeComplement,
      _listEquals.hash(annotations),
      _listEquals.hash(attributes),
      _listEquals.hash(events),
      _listEquals.hash(childNodes),
      _listEquals.hash(properties),
      _listEquals.hash(references),
      _listEquals.hash(letBindings),
    ]);
  }

  @override
  bool operator ==(Object? other) {
    return other is EmbeddedTemplateAst &&
        closeComplement == other.closeComplement &&
        _listEquals.equals(annotations, other.annotations) &&
        _listEquals.equals(attributes, other.attributes) &&
        _listEquals.equals(events, other.events) &&
        _listEquals.equals(properties, other.properties) &&
        _listEquals.equals(childNodes, other.childNodes) &&
        _listEquals.equals(references, other.references) &&
        _listEquals.equals(letBindings, other.letBindings);
  }

  @override
  R? accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
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

class _ParsedEmbeddedTemplate extends Template with EmbeddedTemplateAst {
  _ParsedEmbeddedTemplate(SourceFile sourceFile, NgToken beginToken, NgToken endToken,
      {this.closeComplement,
      this.annotations = const <Annotation>[],
      this.attributes = const <Attribute>[],
      this.childNodes = const <StandaloneTemplate>[],
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
  final List<StandaloneTemplate> childNodes;

  @override
  final List<Event> events;

  @override
  final List<Property> properties;

  @override
  final List<Reference> references;

  @override
  final List<LetBinding> letBindings;
}

class _SyntheticEmbeddedTemplate extends SyntheticTemplate with EmbeddedTemplateAst {
  _SyntheticEmbeddedTemplate(
      {this.annotations = const <Annotation>[],
      this.attributes = const <Attribute>[],
      this.childNodes = const <StandaloneTemplate>[],
      this.events = const <Event>[],
      this.properties = const <Property>[],
      this.references = const <Reference>[],
      this.letBindings = const <LetBinding>[]})
      : closeComplement = CloseElement('template');

  _SyntheticEmbeddedTemplate.from(Template origin,
      {this.annotations = const <Annotation>[],
      this.attributes = const <Attribute>[],
      this.childNodes = const <StandaloneTemplate>[],
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
  final List<StandaloneTemplate> childNodes;

  @override
  final List<Event> events;

  @override
  final List<Property> properties;

  @override
  final List<Reference> references;

  @override
  final List<LetBinding> letBindings;
}
