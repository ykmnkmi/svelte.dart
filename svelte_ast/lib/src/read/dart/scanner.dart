// ignore_for_file: implementation_imports

import 'package:_fe_analyzer_shared/src/scanner/abstract_scanner.dart';
import 'package:_fe_analyzer_shared/src/scanner/characters.dart';
import 'package:_fe_analyzer_shared/src/scanner/internal_utils.dart';
import 'package:_fe_analyzer_shared/src/scanner/scanner.dart';
import 'package:_fe_analyzer_shared/src/scanner/string_canonicalizer.dart';
import 'package:_fe_analyzer_shared/src/scanner/token.dart';
import 'package:_fe_analyzer_shared/src/scanner/token_constants.dart';
import 'package:_fe_analyzer_shared/src/scanner/token_impl.dart'
    show
        CommentTokenImpl,
        DartDocToken,
        LanguageVersionTokenImpl,
        StringTokenImpl;

// TODO(ast): make it lazy, adapt DartX parser & scanner.
class DartScanner extends AbstractScanner {
  DartScanner(
    this.string, {
    int offset = 0,
    int? end,
    required this.closingPattern,
    ScannerConfiguration? configuration,
    bool includeComments = false,
    LanguageVersionChanged? languageVersionChanged,
  }) : scanOffset = offset - 1,
       end = (end ?? string.length) - 1,
       super(
         configuration,
         includeComments,
         languageVersionChanged,
         numberOfBytesHint: string.length,
       );

  DartScanner.recoveryOptionScanner(
    DartScanner super.copyFrom,
    this.closingPattern,
  ) : string = copyFrom.string,
      scanOffset = copyFrom.scanOffset,
      end = copyFrom.end,
      super.recoveryOptionScanner();

  final String string;

  @override
  int scanOffset;

  final int end;

  final Pattern closingPattern;

  @override
  int get stringOffset => scanOffset;

  // Check if it is the end of a expression.
  bool get isClosing =>
      groupingStack.isEmpty && string.startsWith(closingPattern, scanOffset);

  @override
  DartScanner createRecoveryOptionScanner() {
    return DartScanner.recoveryOptionScanner(this, closingPattern);
  }

  @override
  bool atEndOfFile() {
    return scanOffset > end || isClosing;
  }

  @override
  int advance() {
    ++scanOffset;

    if (scanOffset > end || isClosing) {
      return $EOF;
    }

    return string.codeUnitAt(scanOffset);
  }

  @override
  int current() {
    if (scanOffset > end || isClosing) {
      return $EOF;
    }

    return string.codeUnitAt(scanOffset);
  }

  @override
  int passIdentifierCharAllowDollar() {
    while (true) {
      int next = advance();

      if (!isIdentifierChar(next, true)) {
        return next;
      }
    }
  }

  @override
  bool scanUntilLineEnd() {
    bool asciiOnly = true;
    int next = advance();

    while (true) {
      if (next > 127) {
        asciiOnly = false;
      }

      if ($LF == next || $CR == next || $EOF == next) {
        return asciiOnly;
      }

      next = advance();
    }
  }

  @override
  int skipSpaces() {
    int next = advance();

    while (next == $SPACE) {
      next = advance();
    }

    return next;
  }

  @override
  int peek() {
    int next = scanOffset + 1;

    if (next > end ||
        groupingStack.isEmpty && string.startsWith(closingPattern, next)) {
      return $EOF;
    }

    return string.codeUnitAt(next);
  }

  @override
  int currentAsUnicode(int next) {
    return next;
  }

  @override
  void handleUnicode(int startScanOffset) {}

  @override
  LanguageVersionToken createLanguageVersionToken(
    int start,
    int major,
    int minor,
  ) {
    return LanguageVersionTokenImpl.fromSubstring(
      string,
      start,
      scanOffset,
      tokenStart,
      major,
      minor,
      canonicalize: true,
    );
  }

  @override
  DartDocToken createDartDocToken(
    TokenType type,
    int start,
    bool asciiOnly, [
    int extraOffset = 0,
  ]) {
    return DartDocToken.fromSubstring(
      type,
      string,
      start,
      scanOffset + extraOffset,
      tokenStart,
      canonicalize: true,
    );
  }

  @override
  CommentToken createCommentToken(
    TokenType type,
    int start,
    bool asciiOnly, [
    int extraOffset = 0,
  ]) {
    return CommentTokenImpl.fromSubstring(
      type,
      string,
      start,
      scanOffset + extraOffset,
      tokenStart,
      canonicalize: true,
    );
  }

  @override
  StringToken createSyntheticSubstringToken(
    TokenType type,
    int start,
    bool asciiOnly,
    String syntheticChars,
  ) {
    String value = syntheticChars.isEmpty
        ? canonicalizeSubString(string, start, scanOffset)
        : canonicalizeString(
            string.substring(start, scanOffset) + syntheticChars,
          );

    return SyntheticStringToken(
      type,
      value,
      tokenStart,
      value.length - syntheticChars.length,
    );
  }

  @override
  StringToken createSubstringToken(
    TokenType type,
    int start,
    bool asciiOnly,
    int extraOffset,
    bool allowLazy,
  ) {
    return StringTokenImpl.fromSubstring(
      type,
      string,
      start,
      scanOffset + extraOffset,
      tokenStart,
      canonicalize: true,
      precedingComments: comments,
      allowLazy: allowLazy,
    );
  }

  @override
  Token tokenize() {
    while (!atEndOfFile()) {
      int next = advance();

      // Scan the header looking for a language version
      if (next != $EOF) {
        Token oldTail = tail;
        next = bigHeaderSwitch(next);

        if (next != $EOF && tail.kind == SCRIPT_TOKEN) {
          oldTail = tail;
          next = bigHeaderSwitch(next);
        }

        while (next != $EOF && tail == oldTail) {
          next = bigHeaderSwitch(next);
        }

        next = next;
      }

      while (next != $EOF) {
        next = bigSwitch(next);
      }

      if (atEndOfFile()) {
        appendEofToken();
      } else {
        unexpected(next);
      }
    }

    // Always pretend that there's a line at the end of the file.
    lineStarts.add(stringOffset + 1);
    return firstToken();
  }
}
