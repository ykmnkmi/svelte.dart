import 'package:source_span/source_span.dart';
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/parser.dart';

class ParseError extends Error {
  ParseError(this.code, this.message, this.span);

  final String code;

  final String message;

  final SourceSpan span;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'message': message,
      'line': span.start.line + 1,
      'column': span.start.column,
      'offset': span.start.offset,
    };
  }

  @override
  String toString() {
    return 'ParseError($code): $message';
  }
}

extension ParserError on Parser {
  Never error(String code, String message, [int? position, int? end]) {
    position ??= this.position;
    end ??= position;

    SourceSpan span = sourceFile.span(position, end);
    throw ParseError(code, message, span);
  }

  // 839
  Never blockUnclosed(Node node) {
    // https://svelte.dev/e/block_unclosed
    error('block_unclosed', 'Block was left open', node.start, node.end);
  }

  // 954
  Never elementUnclosed(Node node, String name) {
    // https://svelte.dev/e/element_unclosed
    error('element_unclosed', "'<$name>' was left open", node.start, node.end);
  }

  // 1030
  Never expectedToken(Pattern token, int position) {
    // https://svelte.dev/e/expected_token
    error('expected_token', 'Expected token $token', position);
  }

  // 1039
  Never expectedSpace(int position) {
    // https://svelte.dev/e/expected_whitespace
    error('expected_whitespace', 'Expected whitespace');
  }

  // 1059
  Never dartParseError(String message, int position, int end) {
    // https://svelte.dev/e/js_parse_error
    error('js_parse_error', message, position, end);
  }

  // 1563
  Never unexpectedEOF(int position) {
    // https://svelte.dev/e/unexpected_eof
    error('unexpected_eof', 'Unexpected end of input', position);
  }
}
