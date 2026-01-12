// ignore_for_file: implementation_imports

import 'dart:typed_data';

import 'package:_fe_analyzer_shared/src/scanner/scanner.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/dart/analysis/experiments.dart';
import 'package:analyzer/src/dart/scanner/translate_error_token.dart';
import 'package:analyzer/src/error/codes.dart';
import 'package:analyzer/src/generated/parser.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:svelte_ast/src/read/dart/scanner.dart';

final Version currentLanguageVersion = Version(3, 10, 0);

final FeatureSet currentFeatureSet = FeatureSet.fromEnableFlags2(
  sdkLanguageVersion: currentLanguageVersion,
  flags: const <Never>[],
);

final class ThrowingErrorListener extends DiagnosticListener {
  @override
  void onDiagnostic(Diagnostic diahnostic) {
    throw diahnostic;
  }
}

T parseString<T>({
  required int offset,
  int? end,
  required String string,
  required Pattern closingPattern,
  String? fileName,
  Uri? uri,
  bool preserveComments = true,
  bool reportScannerErrors = true,
  required T Function(Token token, Parser parser) parse,
}) {
  DiagnosticListener errorListener = ThrowingErrorListener();
  StringSource source = StringSource(string, fileName, uri: uri);

  Version version = currentLanguageVersion;
  FeatureSet featureSet = currentFeatureSet;

  void languageVersionChanged(
    Scanner scanner,
    LanguageVersionToken versionToken,
  ) {
    int overrideMajor = versionToken.major;
    int overrideMinor = versionToken.minor;

    if (overrideMajor < 0 || overrideMinor < 0) {
      return;
    }

    version = Version(overrideMajor, overrideMinor, 0);

    Version latestVersion = ExperimentStatus.currentVersion;

    if (version > latestVersion) {
      errorListener.onDiagnostic(
        Diagnostic.tmp(
          source: source,
          offset: versionToken.offset,
          length: versionToken.length,
          diagnosticCode: WarningCode.invalidLanguageVersionOverrideGreater,
          arguments: [latestVersion.major, latestVersion.minor],
        ),
      );

      version = latestVersion;
    } else {
      featureSet = featureSet.restrictToVersion(version);

      scanner.configuration = ScannerConfiguration(
        forAugmentationLibrary: featureSet.isEnabled(Feature.macros),
        enableTripleShift: featureSet.isEnabled(Feature.triple_shift),
      );
    }
  }

  // Scan...

  ScannerConfiguration configuration = ScannerConfiguration(
    forAugmentationLibrary: featureSet.isEnabled(Feature.macros),
    enableTripleShift: featureSet.isEnabled(Feature.triple_shift),
  );

  DartScanner scanner = DartScanner(
    string,
    offset: offset,
    end: end,
    closingPattern: closingPattern,
    configuration: configuration,
    includeComments: preserveComments,
    languageVersionChanged: languageVersionChanged,
  );

  Token token = scanner.tokenize();

  if (scanner.hasErrors) {
    int? offset = scanner.getOffsetForCurlyBracketRecoveryStart();

    if (offset != null) {
      throw UnsupportedError(
        'If there was a single missing `}` and the scanner can identify a good '
        'candidate for better recovery, create a new scanner and instruct it '
        'to do that recovery.',
      );
    }
  }

  List<int> lineStarts;

  if (scanner.lineStarts.last > 65535) {
    lineStarts = Uint32List(scanner.lineStarts.length - 1);
    lineStarts.setRange(0, scanner.lineStarts.length - 1, scanner.lineStarts);
  } else {
    lineStarts = Uint16List(scanner.lineStarts.length - 1);
    lineStarts.setRange(0, scanner.lineStarts.length - 1, scanner.lineStarts);
  }

  // The fasta parser handles error tokens produced by the scanner
  // but the old parser used by angular does not
  // and expects that scanner errors to be reported here
  if (reportScannerErrors) {
    // The default recovery strategy used by scanString
    // places all error tokens at the head of the stream.
    while (token is ErrorToken) {
      translateErrorToken(token, (
        DiagnosticCode diagnosticCode,
        int offset,
        List<Object>? arguments,
      ) {
        errorListener.onDiagnostic(
          Diagnostic.tmp(
            source: source,
            offset: offset,
            length: 1,
            diagnosticCode: diagnosticCode,
            arguments: arguments ?? const <Never>[],
          ),
        );
      });

      token = token.next!;
    }
  }

  // Parse...

  LibraryLanguageVersion libraryLanguageVersion = LibraryLanguageVersion(
    package: version,
    override: null,
  );

  LineInfo lineInfo = LineInfo(lineStarts);

  Parser parser = Parser(
    source,
    errorListener,
    featureSet: featureSet,
    languageVersion: libraryLanguageVersion,
    lineInfo: lineInfo,
  );

  return parse(token, parser);
}
