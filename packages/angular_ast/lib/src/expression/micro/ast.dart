import 'package:collection/collection.dart' show ListEquality;
import 'package:meta/meta.dart' show literal;

import '../../ast.dart';

const ListEquality<Object?> listEquals = ListEquality<Object?>();

class MicroAST {
  @literal
  const MicroAST(this.letBindings, this.properties);

  final List<LetBinding> letBindings;

  final List<Property> properties;

  @override
  int get hashCode {
    return Object.hash(listEquals.hash(letBindings), listEquals.hash(properties));
  }

  @override
  bool operator ==(Object? other) {
    return other is MicroAST &&
        listEquals.equals(letBindings, other.letBindings) &&
        listEquals.equals(properties, other.properties);
  }

  @override
  String toString() {
    return '#NgMicroAst <$letBindings $properties>';
  }
}
