import '../ast.dart';
import 'micro/ast.dart';
import 'micro/parser.dart';

export 'micro/ast.dart' show MicroAST;

bool isMicroExpression(String? expression) {
  return expression != null && (expression.startsWith('let') || expression.startsWith(RegExp(r'\S+[:;]')));
}

MicroAST parseMicroExpression(String directive, String? expression, int? expressionOffset,
    {required String sourceUrl, Node? origin}) {
  return const MicroParser().parse(directive, expression, expressionOffset, sourceUrl: sourceUrl, origin: origin);
}
