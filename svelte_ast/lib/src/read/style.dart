import 'package:csslib/parser.dart' show Message, PreprocessorOptions, parse;
import 'package:csslib/visitor.dart' as csslib show Visitor;
import 'package:csslib/visitor.dart'
    show
        Declaration,
        DeclarationGroup,
        ElementSelector,
        Expressions,
        PseudoClassSelector,
        RuleSet,
        Selector,
        SelectorGroup,
        SimpleSelectorSequence,
        StyleSheet,
        TreeNode;
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

// TODO(read:style): complete StyleValidator
class StyleValidator extends Object with csslib.Visitor {
  StyleValidator(this.parser, this.offset);

  final Parser parser;

  final int offset;

  @override
  dynamic visitDeclaration(Declaration node) {
    if (node.expression case Expressions expressions?
        when expressions.expressions.isEmpty) {
      parser.error(invalidDeclaration, offset + expressions.span!.start.offset);
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
            ]
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
          SimpleSelectorSequence(simpleSelector: ElementSelector a),
          SimpleSelectorSequence(simpleSelector: PseudoClassSelector()),
        ] when a.name == 'ref') {
      parser.error(invalidRefSelector, offset + a.span!.start.offset);
    }

    return super.visitSelector(node);
  }
}
