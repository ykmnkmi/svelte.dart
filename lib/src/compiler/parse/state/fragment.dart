import '../parse.dart';
import 'mustache.dart';
import 'tag.dart';
import 'text.dart';

extension FragmentParser on Parser {
  void fragment() {
    if (match('<')) {
      tag();
      return;
    }

    if (match('{')) {
      mustache();
      return;
    }

    text();
  }
}
