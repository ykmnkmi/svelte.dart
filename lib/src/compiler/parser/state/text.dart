import 'package:svelte/src/compiler/interface.dart';
import 'package:svelte/src/compiler/parser/html.dart';
import 'package:svelte/src/compiler/parser/parser.dart';

final RegExp textEndRe = RegExp('[<{]');

extension TextScanner on Parser {
  void text() {
    var found = template.indexOf(textEndRe, position);

    if (found == -1) {
      if (isDone) {
        return;
      }

      found = template.length;
    }

    var raw = template.substring(position, found);
    var data = decodeCharacterReferences(raw);

    current.children!.add(TemplateNode(
      start: position,
      end: found,
      type: 'Text',
      raw: raw,
      data: data,
    ));

    position = found;
  }
}
