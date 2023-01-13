import 'package:nutty/src/compiler/parser/parser.dart';
import 'package:nutty/src/compiler/parser/state/mustache.dart';
import 'package:nutty/src/compiler/parser/state/tag.dart';
import 'package:nutty/src/compiler/parser/state/text.dart';

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
