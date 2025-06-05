import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/state/element.dart';
import 'package:svelte_ast/src/state/tag.dart';
import 'package:svelte_ast/src/state/text.dart';

extension FragmentParser on Parser {
  void fragment() {
    int start = position;

    if (scan('<')) {
      element(start);
    } else if (scan('{')) {
      tag(start);
    } else {
      text(start);
    }
  }
}
