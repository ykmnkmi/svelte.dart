import 'package:collection/collection.dart';
import 'package:source_span/source_span.dart';

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

const ListEquality<Object?> _listEquals = ListEquality<Object?>();

/// Represents an `<ng-container>` element.
///
/// This is a logical container that has no effect on layout in the DOM.
///
/// Clients should not extend, implement, or mix-in this class.
abstract class Container implements StandaloneTemplate {
  factory Container({List<Annotation> annotations, List<StandaloneTemplate> childNodes, List<Star> stars}) =
      _SyntheticContainer;

  factory Container.from(Template origin,
      {List<Annotation> annotations, List<StandaloneTemplate> childNodes, List<Star> stars}) = _SyntheticContainer.from;

  factory Container.parsed(SourceFile sourceFile, NgToken beginToken, NgToken endToken, CloseElement closeComplement,
      {List<Annotation> annotations, List<StandaloneTemplate> childNodes, List<Star> stars}) = _ParsedContainer;

  /// Annotation assignments.
  List<Annotation> get annotations;

  /// CloseElement complement
  CloseElement get closeComplement;

  set closeComplement(CloseElement closeComplement);

  @override
  int get hashCode {
    return Object.hashAll([_listEquals.hash(childNodes), _listEquals.hash(stars), closeComplement]);
  }

  /// Star assignments.
  List<Star> get stars;

  @override
  bool operator ==(Object? other) {
    return other is Container &&
        _listEquals.equals(childNodes, other.childNodes) &&
        _listEquals.equals(stars, other.stars) &&
        other.closeComplement == closeComplement;
  }

  @override
  R? accept<R, C>(TemplateVisitor<R, C?> visitor, [C? context]) {
    return visitor.visitContainer(this, context);
  }

  @override
  String toString() {
    var buffer = StringBuffer('$Container { ');

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

class _ParsedContainer extends Template with Container {
  _ParsedContainer(SourceFile sourceFile, NgToken beginToken, NgToken endToken, this.closeComplement,
      {this.annotations = const [], this.childNodes = const [], this.stars = const []})
      : super.parsed(beginToken, endToken, sourceFile);

  @override
  CloseElement closeComplement;

  @override
  final List<Annotation> annotations;

  @override
  final List<StandaloneTemplate> childNodes;

  @override
  final List<Star> stars;
}

class _SyntheticContainer extends SyntheticTemplate with Container {
  _SyntheticContainer({this.annotations = const [], this.childNodes = const [], this.stars = const []})
      : closeComplement = CloseElement('ng-container');

  _SyntheticContainer.from(Template origin,
      {this.annotations = const [], this.childNodes = const [], this.stars = const []})
      : closeComplement = CloseElement('ng-container'),
        super.from(origin);

  @override
  CloseElement closeComplement;

  @override
  final List<Annotation> annotations;

  @override
  final List<StandaloneTemplate> childNodes;

  @override
  final List<Star> stars;
}
