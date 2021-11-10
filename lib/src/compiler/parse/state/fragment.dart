import '../parse.dart';
import 'mustache.dart';
import 'text.dart';

extension FragmentParser on Parser {
  void fragment() {
    if (match('{')) {
      mustache();
    }

    text();
  }
}
