import 'package:source_span/source_span.dart';
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

  // 668
  Never attributeDuplicate(int start, [int? end]) {
    // https://svelte.dev/e/attribute_duplicate
    error('attribute_duplicate', 'Attributes need to be unique.', start, end);
  }

  // 677
  Never attributeEmptyShorthand(int position) {
    // https://svelte.dev/e/attribute_empty_shorthand
    error(
      'attribute_empty_shorthand',
      'Attribute shorthand cannot be empty.',
      position,
    );
  }

  // 830
  Never blockInvalidPlacement(String name, String location, int position) {
    // https://svelte.dev/e/block_invalid_placement
    error(
      'block_invalid_placement',
      '{#$name ...} block cannot be $location.',
      position,
    );
  }

  // 839
  Never blockUnclosed(int start, [int? end]) {
    // https://svelte.dev/e/block_unclosed
    error('block_unclosed', 'Block was left open.', start, end);
  }

  // 913
  Never directiveInvalidValue(int position) {
    // https://svelte.dev/e/directive_invalid_value
    error(
      'directive_invalid_value',
      'Directive value must be a Dart expression enclosed in curly braces',
      position,
    );
  }

  // 923
  Never directiveMissingName(String name, int start, [int? end]) {
    // https://svelte.dev/e/directive_missing_name
    error(
      'directive_missing_name',
      "'$name' name cannot be empty.",
      start,
      end,
    );
  }

  // 933
  Never elementInvalidClosingTag(String name, int position) {
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
  Never elementUnclosed(String name, int start, [int? end]) {
    // https://svelte.dev/e/element_unclosed
    error('element_unclosed', "'<$name>' was left open.", start, end);
  }

  // 993
  Never expectedAttributeValue(int position) {
    // https://svelte.dev/e/expected_attribute_value
    error('expected_attribute_value', 'Expected attribute value.', position);
  }

  // 1030
  Never expectedToken(Pattern token, int position) {
    // https://svelte.dev/e/expected_token
    error('expected_token', 'Expected token $token.', position);
  }

  // 1039
  Never expectedSpace(int position) {
    // https://svelte.dev/e/expected_whitespace
    error('expected_whitespace', 'Expected whitespace.', position);
  }

  // 1059
  Never dartParseError(String message, int start, [int? end]) {
    // https://svelte.dev/e/js_parse_error
    error('dart_parse_error', message, start, end);
  }

  // 1124
  Never scriptDuplicate(int position) {
    // https://svelte.dev/e/script_duplicate
    error(
      'script_duplicate',
      "A component can have a single top-level '<script>' element and/or a single top-level '<script module>' element.",
      position,
    );
  }

  // 1143
  Never scriptInvalidContext(int start, [int? end]) {
    // https://svelte.dev/e/script_invalid_context
    error(
      'script_invalid_context',
      "If the context attribute is supplied, its value must be 'module'.",
      start,
      end,
    );
  }

  // 1153
  Never scriptReservedAttribute(String name, int start, [int? end]) {
    // https://svelte.dev/e/script_reserved_attribute
    error(
      'script_reserved_attribute',
      "The '$name' attribute is reserved and cannot be used.",
      start,
      end,
    );
  }

  Never scriptUnknownAttribute(int start, [int? end]) {
    // https://svelte.dev/e/script_unknown_attribute
    error(
      'script_unknown_attribute',
      "Unrecognized attribute — should be one of 'generics' or 'module'.",
      start,
      end,
    );
  }

  // 1273
  Never styleDuplicate(int position) {
    // https://svelte.dev/e/style_duplicate
    error(
      'style_duplicate',
      "A component can have a single top-level '<style>' element",
      position,
    );
  }

  // 1309
  Never svelteComponentInvalidThis(int position) {
    // https://svelte.dev/e/svelte_component_invalid_this
    error(
      'svelte_component_invalid_this',
      "Invalid component definition — must be an '{expression}'.",
      position,
    );
  }

  // 1318
  Never svelteComponentMissingThis(int position) {
    // https://svelte.dev/e/svelte_component_missing_this
    error(
      'svelte_component_missing_this',
      "'<svelte:component>' must have a 'this' attribute.",
      position,
    );
  }

  Never svelteElementInvalidThis(int position) {
    // https://svelte.dev/e/svelte_element_invalid_this
    error(
      'svelte_element_invalid_this',
      "'this' should be an '{expression}'.",
      position,
    );
  }

  // 1327
  Never svelteElementMissingThis(int start, [int? end]) {
    // https://svelte.dev/e/svelte_element_missing_this
    error(
      'svelte_element_missing_this',
      "'<svelte:element>' must have a 'this' attribute with a value.",
      start,
      end,
    );
  }

  // 1134
  Never scriptInvalidAttributeValue(String name, int start, [int? end]) {
    error(
      'script_invalid_attribute_value',
      "If the '$name' attribute is supplied, it must be a boolean attribute",
      start,
      end,
    );
  }

  // 1364
  Never svelteMetaDuplicate(String name, int position) {
    // https://svelte.dev/e/svelte_meta_duplicate
    error(
      'svelte_meta_duplicate',
      "A component can only have one '<$name>' element.",
      position,
    );
  }

  // 1384
  Never svelteMetaInvalidPlacement(String name, int position) {
    // https://svelte.dev/e/svelte_meta_invalid_placement
    error(
      'svelte_meta_invalid_placement',
      "'<$name>' tags cannot be inside elements or blocks.",
      position,
    );
  }

  // 1394
  Never svelteMetaInvalidTag(Iterable<String> names, int start, [int? end]) {
    // https://svelte.dev/e/svelte_meta_invalid_tag
    error(
      'svelte_meta_invalid_tag',
      "Valid '<svelte:...>' tag names are ${names.join(', ')}.",
      start,
      end,
    );
  }

  // 1495
  Never tagInvalidName(int start, [int? end]) {
    // https://svelte.dev/e/tag_invalid_name
    error(
      'tag_invalid_name',
      'Expected a valid element or component name. Components must have a '
          'valid variable name or dot notation expression.',
      start,
      end,
    );
  }

  // 1506
  Never tagInvalidPlacement(String name, String location, int position) {
    // https://svelte.dev/e/tag_invalid_placement
    error(
      'tag_invalid_placement',
      '{@$name ...} tag cannot be $location.',
      position,
    );
  }

  // 1563
  Never unexpectedEOF(int position) {
    // https://svelte.dev/e/unexpected_eof
    error('unexpected_eof', 'Unexpected end of input.', position);
  }

  // 1573
  Never unexpectedReservedWord(String word, int position) {
    // https://svelte.dev/e/unexpected_reserved_word`
    error(
      'unexpected_reserved_word',
      "'$word' is a reserved word in JavaScript and cannot be used here.",
      position,
    );
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
