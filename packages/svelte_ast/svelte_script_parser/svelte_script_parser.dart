// ignore_for_file: depend_on_referenced_packages

import 'package:_fe_analyzer_shared/src/parser/parser_impl.dart' as fe
    show Parser;
import 'package:analyzer/dart/ast/token.dart' show Keyword, Token;
import 'package:analyzer/error/error.dart' show AnalysisError;
import 'package:analyzer/error/listener.dart' show AnalysisErrorListener;
import 'package:analyzer/src/fasta/ast_builder.dart' show AstBuilder;

final class ThrowingErrorListener extends AnalysisErrorListener {
  @override
  void onError(AnalysisError error) {
    throw error;
  }
}

final class SvelteScriptParser extends fe.Parser {
  SvelteScriptParser(this.astBuilder, {super.allowPatterns})
      : super(astBuilder) {
    astBuilder.parser = this;
  }

  final AstBuilder astBuilder;

  Object? parse(Token token) {
    token = syntheticPreviousToken(token);

    Token next = token.next!;

    while (!next.isEof) {
      if (next case Token(type: Keyword.IMPORT)) {
        next = parseMetadataStar(next);
        next = parseImport(next);
        next = next.next!;
      } else if (next case Token(type: Keyword.EXTERNAL)) {
        next = parseMetadataStar(next);
        next = parseTopLevelMember(next);
      } else {
        next = parseStatement(next.previous!);
        next = next.next!;
      }
    }

    return (
      imports: astBuilder.directives.toList(growable: false),
      externals: astBuilder.declarations.toList(growable: false),
      statements: astBuilder.stack.values.skip(1).toList(growable: false),
    );
  }
}
