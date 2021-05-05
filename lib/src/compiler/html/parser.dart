import '../parser.dart';
import 'nodes.dart';
import 'states.dart';

class LastAutoClosedTag {
  LastAutoClosedTag(this.tag, this.reason, this.depth);

  final String tag;

  final String reason;

  final int depth;
}

class FragmentParser extends Parser {
  FragmentParser(String template)
      : stack = <Fragment>[],
        root = Fragment(),
        super(template) {
    stack.add(root);

    while (!isDone) {
      if (match('<')) {
        tag(this);
      } else if (match('{')) {
        mustache(this);
      } else {
        text(this);
      }
    }

    if (stack.length > 1) {
      error(code: 'unexpected-eof', message: 'unexpected end of input');
    }
  }

  final Fragment root;

  final List<Fragment> stack;

  LastAutoClosedTag? lastAutoClosedTag;

  Fragment get current {
    return stack.last;
  }

  bool get isEmpty {
    return stack.isEmpty;
  }

  bool get isNotEmpty {
    return stack.isNotEmpty;
  }

  int get length {
    return stack.length;
  }

  void add(Node node) {
    current.children.add(node);
  }

  Node pop() {
    return stack.removeLast();
  }

  void push(Fragment fragment) {
    stack.add(fragment);
  }
}

Fragment parse(String template) {
  final parser = FragmentParser(template);
  return parser.root;
}
