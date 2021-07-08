class Variable {
  const Variable(this.name, {this.prefix});

  final String name;

  final String? prefix;

  String get full {
    if (prefix == null) return name;
    return '$prefix.$name';
  }

  @override
  int get hashCode {
    return 0xAE ^ name.hashCode ^ prefix.hashCode;
  }

  @override
  bool operator ==(Object? other) {
    return identical(this, other) || other is Variable && name == other.name && prefix == other.prefix;
  }

  @override
  String toString() {
    return full;
  }
}
