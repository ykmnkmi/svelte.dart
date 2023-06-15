import '../parser.dart';
import 'mustache.dart';
import 'tag.dart';
import 'text.dart';

extension FragmentParser on Parser {
  void fragment() {
    int start = position;

    if (scan('<')) {
      tag(start);
    } else if (scan('{')) {
      mustache(start);
    } else {
      text(start);
    }
  }
}
