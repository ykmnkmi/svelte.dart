import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/state/mustache.dart';
import 'package:svelte_ast/src/state/tag.dart';
import 'package:svelte_ast/src/state/text.dart';

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
