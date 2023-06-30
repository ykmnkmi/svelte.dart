import 'package:analyzer/dart/ast/ast.dart'
    show BooleanLiteral, DoubleLiteral, IntegerLiteral, StringLiteral;
import 'package:source_span/source_span.dart' show SourceFile, SourceSpan;
import 'package:svelte_ast/svelte_ast.dart';
import 'package:svelte_compiler/src/compile_options.dart';
import 'package:svelte_compiler/src/component_options.dart';
import 'package:svelte_compiler/src/errors.dart';
import 'package:svelte_compiler/src/utils/namespaces.dart';

class Component {
  Component({
    required this.ast,
    required this.source,
    required this.name,
    required this.compileOptions,
    required this.warnings,
  }) : sourceFile = SourceFile.fromString(source, url: compileOptions.uri);

  final SvelteAst ast;

  final String source;

  final String name;

  final CompileOptions compileOptions;

  final List<String> warnings;

  final SourceFile sourceFile;

  late final ComponentOptions componentOptions = processComponentOptions();

  ComponentOptions processComponentOptions() {
    bool accessors = compileOptions.accessors;
    bool immutable = compileOptions.immutable;
    bool preserveWhitespace = compileOptions.preserveWhitespace;
    String? tag = compileOptions.tag;
    Namespace? namespace = compileOptions.namespace;

    Object? getValue(Attribute attribute, ErrorCode errorCode) {
      if (attribute.value case bool value) {
        return value;
      }

      if (attribute.value case List<Object> values) {
        if (values.length > 1) {
          error(attribute, errorCode);
        }

        Object chunk = values.first;

        if (chunk is Text) {
          return chunk.data;
        }

        if (chunk is MustacheTag) {
          return switch (chunk.expression) {
            BooleanLiteral literal => literal.value,
            IntegerLiteral literal => literal.value,
            DoubleLiteral literal => literal.value,
            StringLiteral literal => literal.stringValue,
            _ => error(attribute, errorCode),
          };
        }
      }

      return null;
    }

    Options? options;

    for (Node node in ast.html.children) {
      if (node is Options) {
        options = node;
        break;
      }
    }

    if (options != null) {
      for (Node attribute in options.attributes) {
        if (attribute is Attribute) {
          ErrorCode errorCode = invalidAttributeValue(attribute.name);

          try {
            switch (attribute.name) {
              case 'accessors':
                accessors = getValue(attribute, errorCode) as bool;
                break;

              case 'immutable':
                immutable = getValue(attribute, errorCode) as bool;
                break;

              case 'preserveWhitespace':
                preserveWhitespace = getValue(attribute, errorCode) as bool;
                break;

              case 'tag':
                tag = getValue(attribute, errorCode) as String;
                break;

              case 'namespace':
                String string = getValue(attribute, errorCode) as String;
                Namespace? foundNamespace;

                for (Namespace namespace in Namespace.values) {
                  if (namespace.name == string || namespace.value == string) {
                    foundNamespace = namespace;
                  }
                }

                if (foundNamespace == null) {
                  error(attribute, invalidOptionsAttributeUnknown);
                }

                namespace = foundNamespace;
                break;

              default:
                error(attribute, invalidOptionsAttributeUnknown);
            }
          } on TypeError {
            error(attribute, errorCode);
          }
        } else {
          error(attribute, invalidOptionsAttribute);
        }
      }
    }

    return ComponentOptions(
      accessors: accessors,
      immutable: immutable,
      preserveWhitespace: preserveWhitespace,
      tag: tag,
      namespace: namespace,
    );
  }

  Never error(Node node, ErrorCode errorCode) {
    SourceSpan span = sourceFile.span(node.start, node.end);
    throw CompileError(errorCode, span);
  }
}

extension on Attribute {}
