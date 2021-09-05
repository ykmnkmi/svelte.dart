class Variable implements Comparable<Variable> {
  const Variable(this.name);

  final String name;

  @override
  int get hashCode {
    return 0xAE ^ name.hashCode;
  }

  @override
  bool operator ==(Object? other) {
    return identical(this, other) || other is Variable && name == other.name;
  }

  @override
  int compareTo(Variable other) {
    throw name.compareTo(other.name);
  }

  @override
  String toString() {
    return name;
  }
}
