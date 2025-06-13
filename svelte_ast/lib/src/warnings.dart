import 'package:source_span/source_span.dart';
import 'package:svelte_ast/src/parser.dart';

extension ParserError on Parser {
  void warn(String code, String message, [int? start, int? end]) {
    start ??= position;
    end ??= start;

    SourceSpan span = sourceFile.span(start, end);
    logger?.warning('$code: $message\n${span.highlight()}');
  }

  // 777
  void scriptUnknownAttribute(int start, [int? end]) {
    // https://svelte.dev/e/script_unknown_attribute
    warn(
      'script_unknown_attribute',
      "Unrecognized attribute — should be one of 'generics' or 'module'.",
      start,
      end,
    );
  }

  // 801
  void svelteElementInvalidThis(int position) {
    // https://svelte.dev/e/svelte_element_invalid_this
    warn(
      'svelte_element_invalid_this',
      "'this' should be an '{expression}'.",
      position,
    );
  }
}
