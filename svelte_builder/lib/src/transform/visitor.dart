import 'package:analyzer/dart/ast/ast.dart';
import 'package:svelte_ast/svelte_ast.dart';

const String _webPackageUri = 'package:web/web.dart';

final class TransformVisitor extends ThrowingVisitor<StringBuffer, void> {
  const TransformVisitor({required this.componentName, required this.template});

  final String componentName;

  final String template;

  void writeArgument(
    StringBuffer context,
    TopLevelVariableDeclaration argument,
  ) {
    VariableDeclarationList variables = argument.variables;
    String prefix = '';

    if (variables.type case var type?) {
      prefix = '$type ';
    }

    bool firstAgrument = true;

    for (VariableDeclaration variable in variables.variables) {
      if (firstAgrument) {
        firstAgrument = false;
      } else {
        context.write(', ');
      }

      String substring = template.substring(variable.offset, variable.end);
      context.write('$prefix$substring');
    }
  }

  void writeWebImport(StringBuffer context, bool isSingleQuoted) {
    String quote = isSingleQuoted ? "'" : '"';
    context.write('import $quote$_webPackageUri$quote;');
  }

  @override
  void visitRoot(Root node, StringBuffer context) {
    List<ImportDirective> imports = <ImportDirective>[];
    List<ExportDirective> exports = <ExportDirective>[];
    List<CompilationUnitMember> declarations = <CompilationUnitMember>[];

    if (node.module case var module?) {
      AstNode unit = module.unit;

      if (unit is! CompilationUnit) {
        // TODO(builder): replace error with function.
        throw Exception('unit is not CompilationUnit.');
      }

      for (Directive directive in unit.directives) {
        if (directive is ImportDirective) {
          imports.add(directive);
        } else if (directive is ExportDirective) {
          exports.add(directive);
        } else {
          throw TypeError();
        }
      }

      declarations.addAll(unit.declarations);
    }

    String? typeArguments;
    List<TopLevelVariableDeclaration> arguments =
        <TopLevelVariableDeclaration>[];
    List<Statement> body = <Statement>[];

    if (node.instance case var instance?) {
      for (AttributeNode attribute in instance.attributes) {
        if (attribute is Attribute && attribute.name == 'generics') {
          Object value = attribute.value;

          if (value == true) {
          } else if (value is ExpressionTag) {
          } else if (value is List<Node>) {
            Node first = value.first;

            if (first is! Text) {
              throw StateError('Text node expected.');
            }

            typeArguments = first.data;
          } else {
            throw TypeError();
          }
        }
      }

      for (AstNode child in instance.body) {
        if (child is ImportDirective) {
          // TODO(builder): check for duplicates.
          imports.add(child);
        } else if (child is TopLevelVariableDeclaration) {
          arguments.add(child);
        } else if (child is Statement) {
          body.add(child);
        } else {
          throw TypeError();
        }
      }
    }

    context.write('library;\n\n');

    String? webPrefix;
    ImportDirective? lastWebDirective;

    bool webNodeIsHidden = true;

    for (ImportDirective directive in imports) {
      String substring = template.substring(directive.offset, directive.end);
      context.write('$substring\n');

      if (directive.uri.stringValue == _webPackageUri) {
        lastWebDirective = directive;

        for (Combinator combinator in directive.combinators) {
          switch (combinator) {
            case ShowCombinator(shownNames: var names):
              if (names.isEmpty || names.any((name) => name.name == 'Node')) {
                if (directive.prefix case var prefix?) {
                  webPrefix = '${prefix.name}.';
                }

                webNodeIsHidden = false;
              }

              break;

            case HideCombinator(hiddenNames: var names):
              if (names.isEmpty || names.any((name) => name.name == 'Node')) {
                webNodeIsHidden = true;
              }

              break;
          }
        }
      } else if (lastWebDirective != null && webNodeIsHidden) {
        SimpleStringLiteral uri = lastWebDirective.uri as SimpleStringLiteral;
        writeWebImport(context, uri.isSingleQuoted);
      }
    }

    if (lastWebDirective == null && webNodeIsHidden) {
      writeWebImport(context, true);
    }

    webPrefix ??= '';

    if (exports.isNotEmpty) {
      context.writeln();

      for (ExportDirective directive in exports) {
        String substring = template.substring(directive.offset, directive.end);
        context.write('$substring\n');
      }
    }

    for (CompilationUnitMember declaration in declarations) {
      String substring = template.substring(
        declaration.offset,
        declaration.end,
      );

      context.write('\n\n$substring');
    }

    context.write('\n\n${webPrefix}Node $componentName');

    if (typeArguments != null) {
      context.write('<$typeArguments>');
    }

    context.write('(');

    if (arguments.isNotEmpty) {
      context.write('{');

      writeArgument(context, arguments.first);

      for (TopLevelVariableDeclaration argument in arguments.skip(1)) {
        writeArgument(context, argument);
      }

      context.write('}');
    }

    context.write(') {\n');

    if (body.isNotEmpty) {
      context.write(template.substring(body.first.offset, body.last.end));
    }

    context.write('}');
  }
}
