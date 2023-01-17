import 'package:svelte/src/compiler/interface.dart';
import 'package:svelte/src/compiler/parser/parser.dart';

Ast parse(String source, {Object? sourceUrl}) {
  var parser = Parser(source, sourceUrl: sourceUrl);
  return Ast(html: parser.html);
}

class Ast {
  Ast({
    required this.html,
  });

  final Fragment html;

  Json toJson() {
    return <String, Object?>{
      'html': html.toJson(),
    };
  }
}
