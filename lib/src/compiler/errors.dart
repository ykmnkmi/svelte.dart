class CompileError extends Error {
  CompileError({this.code, this.message, this.source, this.offset});

  final String? code;

  final String? message;

  final String? source;

  final int? offset;

  @override
  String toString() {
    var error = 'CompileError';

    if (code != null) {
      error += '[$code]';
    }

    if (message != null) {
      error += ': $message';
    }

    if (source != null && offset != null) {
      error = '$error, \'$source\'\n${' ' * (error.length + offset! + 3)}^';
    }

    return error;
  }
}
