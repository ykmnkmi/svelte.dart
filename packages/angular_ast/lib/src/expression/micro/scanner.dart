import 'package:string_scanner/string_scanner.dart' show StringScanner;

import '../../parser_exception.dart';
import 'token.dart';

enum NgMicroScannerState {
  hasError,
  isEndOfFile,
  scanAfterLetIdentifier,
  scanAfterLetKeyword,
  scanAfterBindIdentifier,
  scanBeforeBindExpression,
  scanBindExpression,
  scanEndExpression,
  scanImplicitBind,
  scanInitial,
  scanLetAssignment,
  scanLetIdentifier,
}

class MicroScanner {
  factory MicroScanner(String html, {Object? sourceUrl}) {
    var scanner = StringScanner(html, sourceUrl: sourceUrl);
    scanner.scan(findWhitespace);
    var offset = scanner.position;
    return MicroScanner._(scanner, offset, scanner.string.length - offset);
  }

  MicroScanner._(this.scanner, this.expressionOffset, this.expressionLength) : state = NgMicroScannerState.scanInitial;

  final StringScanner scanner;

  int expressionOffset;

  int expressionLength;

  NgMicroScannerState state;

  MicroToken? scan() {
    switch (state) {
      case NgMicroScannerState.hasError:
        throw StateError('An error occurred');
      case NgMicroScannerState.isEndOfFile:
        return null;
      case NgMicroScannerState.scanAfterBindIdentifier:
        return scanAfterBindIdentifier();
      case NgMicroScannerState.scanAfterLetIdentifier:
        return scanAfterLetIdentifier();
      case NgMicroScannerState.scanAfterLetKeyword:
        return scanAfterLetKeyword();
      case NgMicroScannerState.scanBeforeBindExpression:
        return scanBeforeBindExpression();
      case NgMicroScannerState.scanBindExpression:
        return scanBindExpression();
      case NgMicroScannerState.scanEndExpression:
        return scanEndExpression();
      case NgMicroScannerState.scanImplicitBind:
        return scanImplicitBind();
      case NgMicroScannerState.scanInitial:
        return scanInitial();
      case NgMicroScannerState.scanLetAssignment:
        return scanLetAssignment();
      case NgMicroScannerState.scanLetIdentifier:
        return scanLetIdentifier();
      default:
        throw unexpected();
    }
  }

  String lexeme(int offset) {
    return scanner.substring(offset);
  }

  MicroToken scanAfterBindIdentifier() {
    var offset = scanner.position;

    if (scanner.scan(findBeforeAssignment)) {
      state = NgMicroScannerState.scanBindExpression;
      return MicroToken.bindExpressionBefore(offset, lexeme(offset));
    }

    throw unexpected();
  }

  MicroToken scanAfterLetIdentifier() {
    var offset = scanner.position;

    if (scanner.scan(findEndExpression)) {
      state = NgMicroScannerState.scanInitial;
      return MicroToken.endExpression(offset, lexeme(offset));
    }

    if (scanner.scan(findLetAssignmentBefore)) {
      state = NgMicroScannerState.scanLetAssignment;
      return MicroToken.letAssignmentBefore(offset, lexeme(offset));
    }

    if (scanner.scan(findWhitespace)) {
      state = NgMicroScannerState.scanImplicitBind;
      return MicroToken.endExpression(offset, lexeme(offset));
    }

    throw unexpected();
  }

  MicroToken scanAfterLetKeyword() {
    var offset = scanner.position;

    if (scanner.scan(findWhitespace)) {
      state = NgMicroScannerState.scanLetIdentifier;
      return MicroToken.letKeywordAfter(offset, lexeme(offset));
    }

    throw unexpected();
  }

  MicroToken scanBeforeBindExpression() {
    var offset = scanner.position;

    if (scanner.scan(findWhitespace)) {
      state = NgMicroScannerState.scanBindExpression;
      return MicroToken.bindExpressionBefore(offset, lexeme(offset));
    }

    throw unexpected();
  }

  MicroToken scanBindExpression() {
    var offset = scanner.position;

    if (scanner.scan(findExpression)) {
      state = NgMicroScannerState.scanEndExpression;
      return MicroToken.bindExpression(offset, lexeme(offset));
    }

    throw unexpected();
  }

  MicroToken? scanEndExpression() {
    if (scanner.isDone) {
      state = NgMicroScannerState.isEndOfFile;
      return null;
    }

    var offset = scanner.position;

    if (scanner.scan(findEndExpression)) {
      state = NgMicroScannerState.scanInitial;
      return MicroToken.endExpression(offset, lexeme(offset));
    }

    throw unexpected();
  }

  MicroToken scanImplicitBind() {
    var offset = scanner.position;

    if (scanner.scan(findImplicitBind)) {
      state = NgMicroScannerState.scanBeforeBindExpression;
      return MicroToken.bindIdentifier(offset, lexeme(offset));
    }

    throw unexpected();
  }

  MicroToken scanInitial() {
    var offset = scanner.position;

    if (scanner.scan(findStartExpression)) {
      var lexeme = this.lexeme(offset);

      if (lexeme == 'let') {
        state = NgMicroScannerState.scanAfterLetKeyword;
        return MicroToken.letKeyword(offset, lexeme);
      }

      if (scanner.matches(findBeforeAssignment)) {
        state = NgMicroScannerState.scanAfterBindIdentifier;
        return MicroToken.bindIdentifier(offset, lexeme);
      } else {
        state = NgMicroScannerState.scanEndExpression;
        return MicroToken.bindExpression(offset, lexeme);
      }
    }

    throw unexpected();
  }

  MicroToken scanLetAssignment() {
    var offset = scanner.position;

    if (scanner.scan(findExpression)) {
      state = NgMicroScannerState.scanEndExpression;
      return MicroToken.letAssignment(offset, lexeme(offset));
    }

    throw unexpected();
  }

  MicroToken scanLetIdentifier() {
    var offset = scanner.position;

    if (scanner.scan(findLetIdentifier)) {
      if (scanner.isDone) {
        state = NgMicroScannerState.isEndOfFile;
      } else {
        state = NgMicroScannerState.scanAfterLetIdentifier;
      }

      return MicroToken.letIdentifier(offset, lexeme(offset));
    }

    throw unexpected();
  }

  ParserException unexpected() {
    state = NgMicroScannerState.hasError;
    return ParserException(ParserErrorCode.invalidMicroExpression, expressionOffset, expressionLength);
  }

  static RegExp get findBeforeAssignment {
    return RegExp(r':(\s*)');
  }

  static RegExp get findEndExpression {
    return RegExp(r';\s*');
  }

  static RegExp get findExpression {
    return RegExp(r'[^;]+');
  }

  static RegExp get findImplicitBind {
    return RegExp(r'[^\s]+');
  }

  static RegExp get findLetAssignmentBefore {
    return RegExp(r'\s*=\s*');
  }

  static RegExp get findLetIdentifier {
    return RegExp(r'[^\s=;]+');
  }

  static RegExp get findStartExpression {
    return RegExp(r'[^\s:;]+');
  }

  static RegExp get findWhitespace {
    return RegExp(r'\s+');
  }
}
