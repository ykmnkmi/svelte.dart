import 'package:svelte/src/compiler/parser/parser.dart';
import 'package:svelte/src/compiler/parser/state/mustache.dart';
import 'package:svelte/src/compiler/parser/state/tag.dart';
import 'package:svelte/src/compiler/parser/state/text.dart';

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
