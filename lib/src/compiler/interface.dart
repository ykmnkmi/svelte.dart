class Node {
  Node({
    this.start,
    this.end,
    required this.type,
    this.name,
    this.text,
    this.raw,
    this.modifiers,
    this.expression,
    this.values,
    this.tag,
    this.attributes,
    List<Node>? children,
  }) : children = <Node>[...?children];

  // base
  int? start;
  int? end;
  final String type;
  String? name;

  // text
  String? text;
  String? raw;

  // attribute & directive
  List<String>? modifiers;
  Object? expression;
  List<Node>? values;

  // trainsition
  bool? intro;
  bool? outro;

  // element
  String? tag;
  List<Node>? attributes;
  List<Node> children;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      // base
      'start': start,
      'end': end,
      'type': type,
      if (name != null) 'name': name,

      // text
      if (text != null) 'text': text,
      if (raw != null) 'raw': raw,

      // attribute & directive
      if (modifiers != null) 'modifiers': modifiers,
      if (expression != null) 'expression': expression,
      if (values != null) 'values': values,

      // trainsition
      if (intro != null) 'intro': intro,
      if (outro != null) 'outro': outro,

      // element
      if (tag != null) 'tag': tag,
      if (attributes != null) 'attributes': attributes,
      if (children.isNotEmpty) 'children': children,
    };
  }
}
