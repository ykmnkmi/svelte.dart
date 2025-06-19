import 'package:logging/logging.dart';
import 'package:source_span/source_span.dart';

final class TransformerContext {
  TransformerContext({
    required this.componentName,
    required String template,
    this.fileName,
    this.uri,
    this.logger,
  }) : sourceFile = SourceFile.fromString(template, url: uri);

  final String componentName;

  final String? fileName;

  final Uri? uri;

  final SourceFile sourceFile;

  final Logger? logger;

  final StringBuffer output = StringBuffer();

  void write(String text) {
    output.write(text);
  }
}
