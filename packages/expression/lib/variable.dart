class Variable {
  const Variable({required this.name, this.prefix});

  final String name;

  final String? prefix;

  String get value {
    return prefix == null ? name : '$prefix.$name';
  }

  @override
  String toString() {
    return value;
  }
}
