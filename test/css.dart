// ignore_for_file: avoid_print

import 'package:csslib/parser.dart';
import 'package:csslib/visitor.dart';

const String input = '''
div {
  color: red;
}
''';

void main() {
  var errors = <Message>[];
  var sheet = parse(input, errors: errors);

  for (var message in errors) {
    print(message);
  }

  sheet.visit(SheetToJson());
}

class SheetToJson extends Visitor {
  @override
  void visitRuleSet(RuleSet node) {
    print(node.selectorGroup?.selectors.first.simpleSelectorSequences.first.simpleSelector.name); // div
  }
}
