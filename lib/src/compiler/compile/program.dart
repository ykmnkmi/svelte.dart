class Program {
  Program(this.name, this.source);

  final String name;

  final String source;

  @override
  String toString() {
    return '# $name\n$source';
  }
}
