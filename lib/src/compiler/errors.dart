class CompileError extends Error {
  CompileError([this.message]);

  final String? message;

  @override
  String toString() {
    if (message == null) {
      return 'CompileError';
    }

    return 'CompileError: $message';
  }
}
