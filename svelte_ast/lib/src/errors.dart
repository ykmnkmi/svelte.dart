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
  Never error(String code, String message, [int? start, int? end]) {
    start ??= index;
    end ??= start;

    SourceSpan span = sourceFile.span(start, end);
    throw ParseError(code, message, span);
  }

  // 839
  Never blockUnclosed(Node node) {
    // https://svelte.dev/e/block_unclosed
    error('block_unclosed', 'Block was left open.', node.start, node.end);
  }

  // 933
  Never elementInvalidClosingTag(int position, String name) {
    // https://svelte.dev/e/element_invalid_closing_tag
    error(
      'element_invalid_closing_tag',
      "'</$name>' attempted to close an element that was not open.",
      position,
    );
  }

  // 944
  Never elementInvalidClosingTagAutoClosed(
    int position,
    String name,
    String reason,
  ) {
    // https://svelte.dev/e/element_invalid_closing_tag_autoclosed
    error(
      'element_invalid_closing_tag_autoclosed',
      "'</$name>' attempted to close element that was already automatically "
          "closed by '<$reason>' (cannot nest '<$reason>' inside '<$name>').",
      position,
    );
  }

  // 954
  Never elementUnclosed(Node node, String name) {
    // https://svelte.dev/e/element_unclosed
    error('element_unclosed', "'<$name>' was left open.", node.start, node.end);
  }

  // 1030
  Never expectedToken(int position, Pattern token) {
    // https://svelte.dev/e/expected_token
    error('expected_token', 'Expected token $token.', position);
  }

  // 1039
  Never expectedSpace(int position) {
    // https://svelte.dev/e/expected_whitespace
    error('expected_whitespace', 'Expected whitespace.', position);
  }

  // 1059
  Never dartParseError(int start, int end, String message) {
    // https://svelte.dev/e/js_parse_error
    error('js_parse_error', message, start, end);
  }

  // 1364
  Never svelteMetaDuplicate(int position, String name) {
    // https://svelte.dev/e/svelte_meta_duplicate
    error(
      'svelte_meta_duplicate',
      "A component can only have one '<$name>' element.",
      position,
    );
  }

  // 1384
  Never svelteMetaInvalidPlacement(int position, String name) {
    // https://svelte.dev/e/svelte_meta_invalid_placement
    error(
      'svelte_meta_invalid_placement',
      "'<$name>' tags cannot be inside elements or blocks",
      position,
    );
  }

  // 1394
  Never svelteMetaInvalidTag(int start, int end, Iterable<String> names) {
    // https://svelte.dev/e/svelte_meta_invalid_tag
    error(
      'svelte_meta_invalid_tag',
      "Valid '<svelte:...>' tag names are ${names.join(', ')}.",
      start,
      end,
    );
  }

  // 1495
  Never tagInvalidName(int start, int end) {
    // https://svelte.dev/e/tag_invalid_name
    error(
      'tag_invalid_name',
      'Expected a valid element or component name. Components must have a '
          'valid variable name or dot notation expression.',
    );
  }

  // 1563
  Never unexpectedEOF(int position) {
    // https://svelte.dev/e/unexpected_eof
    error('unexpected_eof', 'Unexpected end of input.', position);
  }

  // 1582
  Never voidElementInvalidContent(int position) {
    // https://svelte.dev/e/void_element_invalid_content
    error(
      'void_element_invalid_content',
      'Void elements cannot have children or closing tags.',
      position,
    );
  }
}
