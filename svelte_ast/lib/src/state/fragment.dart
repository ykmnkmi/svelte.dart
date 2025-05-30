import 'package:svelte_ast/src/parser.dart';
import 'package:svelte_ast/src/state/element.dart';
import 'package:svelte_ast/src/state/tag.dart';
import 'package:svelte_ast/src/state/text.dart';

extension FragmentParser on Parser {
  void fragment() {
    if (match('<')) {
      element();
    } else if (match('{')) {
      tag();
    } else {
      text();
    }
  }
}
