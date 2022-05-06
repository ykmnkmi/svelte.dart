import 'package:piko/src/compiler/parse/parse.dart';
import 'package:piko/src/compiler/parse/state/mustache.dart';
import 'package:piko/src/compiler/parse/state/tag.dart';
import 'package:piko/src/compiler/parse/state/text.dart';

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
