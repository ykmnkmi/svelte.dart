class Variable {
  const Variable({required this.name, this.prefix, this.string = false});

  final String name;

  final String? prefix;

  final bool string;

  String get value {
    return prefix == null ? name : '$prefix.$name';
  }

  @override
  String toString() {
    return value;
  }
}
