class CompileError extends Error {
  CompileError([this.code, this.message]);

  final String? code;

  final String? message;

  @override
  String toString() {
    var error = 'CompileError';

    if (code != null) {
      error += '[$code]';
    }

    if (message != null) {
      error += ': $message';
    }

    return error;
  }
}
