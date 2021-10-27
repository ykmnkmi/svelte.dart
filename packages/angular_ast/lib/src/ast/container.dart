import 'package:collection/collection.dart' show ListEquality;
import 'package:source_span/source_span.dart' show SourceFile;

import '../ast.dart';
import '../token/tokens.dart';
import '../visitor.dart';

const ListEquality<Object?> listEquals = ListEquality<Object?>();

abstract class Container implements Standalone {
  factory Container({List<Annotation> annotations, List<Standalone> childNodes, List<Star> stars}) =
      _SyntheticContainer;

  factory Container.from(Node origin,
      {List<Annotation> annotations, List<Standalone> childNodes, List<Star> stars}) = _SyntheticContainer.from;

  factory Container.parsed(SourceFile sourceFile, Token beginToken, Token endToken, CloseElement closeComplement,
      {List<Annotation> annotations, List<Standalone> childNodes, List<Star> stars}) = _ParsedContainer;

  List<Annotation> get annotations;

  CloseElement get closeComplement;

  set closeComplement(CloseElement closeComplement);

  @override
  int get hashCode {
    return Object.hashAll([listEquals.hash(childNodes), listEquals.hash(stars), closeComplement]);
  }

  List<Star> get stars;

  @override
  bool operator ==(Object? other) {
    return other is Container &&
        listEquals.equals(childNodes, other.childNodes) &&
        listEquals.equals(stars, other.stars) &&
        other.closeComplement == closeComplement;
  }

  @override
  R? accept<R, C>(Visitor<R, C?> visitor, [C? context]) {
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

class _ParsedContainer extends Node with Container {
  _ParsedContainer(SourceFile sourceFile, Token beginToken, Token endToken, this.closeComplement,
      {this.annotations = const [], this.childNodes = const [], this.stars = const []})
      : super.parsed(beginToken, endToken, sourceFile);

  @override
  CloseElement closeComplement;

  @override
  final List<Annotation> annotations;

  @override
  final List<Standalone> childNodes;

  @override
  final List<Star> stars;
}

class _SyntheticContainer extends Synthetic with Container {
  _SyntheticContainer({this.annotations = const [], this.childNodes = const [], this.stars = const []})
      : closeComplement = CloseElement('ng-container');

  _SyntheticContainer.from(Node origin,
      {this.annotations = const [], this.childNodes = const [], this.stars = const []})
      : closeComplement = CloseElement('ng-container'),
        super.from(origin);

  @override
  CloseElement closeComplement;

  @override
  final List<Annotation> annotations;

  @override
  final List<Standalone> childNodes;

  @override
  final List<Star> stars;
}
