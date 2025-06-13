import 'package:analyzer/dart/ast/ast.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:svelte_ast/svelte_ast.dart';
import 'package:svelte_builder/src/recase.dart';

const String _webPackageUri = 'package:web/web.dart';

class Transformer implements Builder {
  const Transformer();

  @override
  Map<String, List<String>> get buildExtensions {
    return const <String, List<String>>{
      '{{dir}}/{{file}}.svelte': <String>['{{dir}}/{{file}}.svelte.dart'],
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    AssetId inputAsset = buildStep.inputId;
    AssetId outputAsset = inputAsset.changeExtension('.svelte.dart');

    StringBuffer outputBuffer = StringBuffer();

    String fileName = path.basename(inputAsset.path);
    String componentName = camelCase(path.basenameWithoutExtension(fileName));
    String template = await buildStep.readAsString(inputAsset);

    Root root = parse(template, fileName: fileName, uri: inputAsset.uri);

    SvelteTransformer transformer = SvelteTransformer(
      componentName: componentName,
      template: template,
    );

    root.accept(transformer, outputBuffer);

    String componentCode = DartFormatter(
      languageVersion: Version(3, 8, 0),
    ).format(outputBuffer.toString(), uri: inputAsset.uri);

    await buildStep.writeAsString(outputAsset, componentCode);
  }
}

final class SvelteTransformer extends ThrowingVisitor<StringBuffer, void> {
  const SvelteTransformer({
    required this.componentName,
    required this.template,
  });

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
          // TODO(builder): replace error with function.
          throw Exception('unsupported directive: $directive.');
        }
      }

      declarations.addAll(unit.declarations);
    }

    List<TopLevelVariableDeclaration> arguments =
        <TopLevelVariableDeclaration>[];
    List<Statement> body = <Statement>[];

    if (node.instance case var instance?) {
      for (AstNode child in instance.body) {
        if (child is ImportDirective) {
          // TODO(builder): check for duplicates.
          imports.add(child);
        } else if (child is TopLevelVariableDeclaration) {
          arguments.add(child);
        } else if (child is Statement) {
          body.add(child);
        } else {
          // TODO(builder): replace error with function.
          throw Exception('unsupported child: $child.');
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

    context.write('\n\n${webPrefix}Node $componentName(');

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
