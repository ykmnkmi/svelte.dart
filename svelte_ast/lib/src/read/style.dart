import 'package:csslib/parser.dart' hide Parser;
import 'package:csslib/visitor.dart' as css;
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
      Message errorMessage = errors[0];
      SourceSpan span = errorMessage.span!;

      String message = errorMessage.message;
      int offset = span.start.offset;
      int end = span.end.offset;
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
class StyleValidator extends css.Visitor {
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
    SelectorGroup? selectorGroup = node.selectorGroup;
    DeclarationGroup declarationGroup = node.declarationGroup;

    if (selectorGroup != null && declarationGroup.declarations.isEmpty) {
      for (Selector selector in selectorGroup.selectors) {
        for (SimpleSelectorSequence sequence
            in selector.simpleSelectorSequences) {
          SimpleSelector selector = sequence.simpleSelector;

          if (selector is PseudoClassSelector && selector.name == 'global') {
            parser.error(emptyGlobalSelector, offset + node.span.start.offset);
          }
        }
      }
    }

    return super.visitRuleSet(node);
  }

  @override
  dynamic visitSelector(Selector node) {
    List<SimpleSelectorSequence> sequences = node.simpleSelectorSequences;

    for (int i = 0; i < sequences.length - 1; i += 1) {
      SimpleSelector a = sequences[i].simpleSelector;
      SimpleSelector b = sequences[i + 1].simpleSelector;

      if (a.name == 'ref' && b is PseudoClassSelector) {
        parser.error(invalidRefSelector, offset + a.span!.start.offset);
      }
    }

    return super.visitSelector(node);
  }
}
