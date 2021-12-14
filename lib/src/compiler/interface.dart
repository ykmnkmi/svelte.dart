class Node {
  Node({required this.type, this.name, this.start, this.end, this.data, List<Node>? children})
      : children = children ?? <Node>[];

  String type;

  String? name;

  int? start;

  int? end;

  Object? data;

  List<Node> children;

  void add(Node node) {
    children.add(node);
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'type': type,
      if (name != null) 'name': name,
      if (start != null) 'start': start,
      if (end != null) 'end': end,
      if (data != null) 'data': data,
      if (children.isNotEmpty) 'children': List<Object?>.generate(children.length, (index) => children[index].toJson()),
    };
  }

  @override
  String toString() {
    var buffer = StringBuffer(type);

    if (name != null) {
      buffer.write('.$name');
    }

    if (start != null || end != null) {
      buffer.write('[$start:$end]');
    }

    if (data != null) {
      buffer.write(' ($data)');
    }

    if (children.isNotEmpty) {
      buffer
        ..write(' { ')
        ..writeAll(children, ', ')
        ..write(' }');
    }

    return buffer.toString();
  }
}

abstract class Visitor {
  void enter(Node node) {}

  void leave(Node node) {}
}
