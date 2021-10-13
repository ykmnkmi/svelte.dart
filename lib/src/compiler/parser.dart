import 'package:angular_ast/angular_ast.dart' as ast show parse;
import 'package:angular_ast/angular_ast.dart' hide parse;

List<StandaloneTemplateAst> parse(String template, {required String sourceUrl}) {
  return ast.parse(template, sourceUrl: sourceUrl).cast<StandaloneTemplateAst>();
}
