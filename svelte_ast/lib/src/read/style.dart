import 'package:csslib/parser.dart' hide Parser;
import 'package:csslib/visitor.dart' as csslib;
import 'package:csslib/visitor.dart' hide Visitor;
import 'package:source_span/source_span.dart';
import 'package:svelte_ast/src/ast.dart';
import 'package:svelte_ast/src/errors.dart';
import 'package:svelte_ast/src/parser.dart';

final RegExp _styleCloseTag = RegExp('<\\/style\\s*>');

extension StyleParser on Parser {
  void readStyle(int start, List<Node> attributes) {
    expect('>');

    int dataStart = position;
    String data = readUntil(_styleCloseTag, unclosedStyle);

    if (isDone) {
      error(unclosedStyle);
    }

    int dataEnd = position;

    if (skipStyle) {
      read(_styleCloseTag);
      return;
    }

    expect(_styleCloseTag);

    List<Message> errors = <Message>[];

    StyleSheet ast = parse(
      data,
      errors: errors,
      options: PreprocessorOptions(),
    );

    if (errors.isNotEmpty) {
      var Message(
        message: message,
        span: SourceSpan(
          start: SourceLocation(offset: offset),
          end: SourceLocation(offset: end),
        )!,
      ) = errors.first;

      error(cssSyntaxError(message), dataStart + offset, dataStart + end);
    }

    ast.visit(StyleValidator(this, dataStart));

    styles.add(Style(
      start: start,
      end: position,
      attributes: attributes,
      topLevels: ast.topLevels,
      content: (
        start: dataStart,
        end: dataEnd,
        data: data,
      ),
    ));
  }
}

// TODO(read:style): Complete StyleValidator
class StyleValidator extends Object with csslib.Visitor {
  StyleValidator(this.parser, this.offset);

  final Parser parser;

  final int offset;

  @override
  dynamic visitDeclaration(Declaration node) {
    Expression? expression = node.expression;

    if (expression is Expressions && expression.expressions.isEmpty) {
      parser.error(invalidDeclaration, offset + expression.span!.start.offset);
    }

    return super.visitDeclaration(node);
  }

  @override
  dynamic visitRuleSet(RuleSet node) {
    if (node
        case RuleSet(
          selectorGroup: SelectorGroup(
            selectors: <Selector>[
              Selector(
                simpleSelectorSequences: <SimpleSelectorSequence>[
                  SimpleSelectorSequence(
                    simpleSelector: PseudoClassSelector(
                      name: 'global',
                    ),
                  ),
                ],
              ),
            ],
          ),
          declarationGroup: DeclarationGroup(
            declarations: <TreeNode>[],
          ),
        )) {
      parser.error(emptyGlobalSelector, offset + node.span.start.offset);
    }

    return super.visitRuleSet(node);
  }

  @override
  dynamic visitSelector(Selector node) {
    if (node.simpleSelectorSequences
        case <SimpleSelectorSequence>[
          SimpleSelectorSequence(simpleSelector: var a),
          SimpleSelectorSequence(simpleSelector: PseudoClassSelector()),
        ] when a.name == 'ref') {
      parser.error(invalidRefSelector, offset + a.span!.start.offset);
    }

    return super.visitSelector(node);
  }
}
