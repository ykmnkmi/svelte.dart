import 'package:svelte/src/compiler/interface.dart';
import 'package:svelte/src/compiler/parser/parser.dart';

ParseResult parse(String source, {Object? sourceUrl}) {
  var parser = Parser(source, sourceUrl: sourceUrl);
  return ParseResult(html: parser.html);
}

class ParseResult {
  ParseResult({
    required this.html,
  });

  final Fragment html;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'html': html,
    };
  }
}
