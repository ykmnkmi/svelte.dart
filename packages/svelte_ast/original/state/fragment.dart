import '../parser.dart';
import 'mustache.dart';
import 'tag.dart';
import 'text.dart';

extension FragmentParser on Parser {
  void fragment() {
    if (match('<')) {
      tag();
    } else if (match('{')) {
      mustache();
    } else {
      text();
    }
  }
}
