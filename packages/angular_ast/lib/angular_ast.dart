import 'src/ast.dart';
import 'src/exception_handler/exception_handler.dart';
import 'src/parser.dart';

export 'src/ast.dart'
    show
        Annotation,
        Attribute,
        Banana,
        CloseElement,
        Comment,
        Container,
        Element,
        EmbeddedContent,
        EmbeddedTemplateAst,
        Event,
        Interpolation,
        LetBinding,
        ParsedAnnotation,
        ParsedAttribute,
        ParsedBanana,
        ParsedCloseElementAst,
        ParsedDecorator,
        ParsedEmbeddedContent,
        ParsedEvent,
        ParsedInterpolation,
        ParsedElement,
        ParsedLetBinding,
        ParsedProperty,
        ParsedReference,
        ParsedStar,
        Property,
        Reference,
        StandaloneTemplate,
        Star,
        SyntheticTemplate,
        TagOffsetInfo,
        Template,
        Text;
export 'src/exception_handler/exception_handler.dart'
    show ExceptionHandler, RecoveringExceptionHandler, ThrowingExceptionHandler;
export 'src/exception_handler/exception_handler.dart';
export 'src/lexer.dart' show NgLexer;
export 'src/parser.dart' show NgParser;
export 'src/recovery_protocol/recovery_protocol.dart';
export 'src/token/tokens.dart' show NgToken, NgTokenType, NgAttributeValueToken;
export 'src/visitor.dart'
    show
        HumanizingTemplateAstVisitor,
        IdentityTemplateAstVisitor,
        MinimizeWhitespaceVisitor,
        TemplateVisitor,
        DesugarVisitor,
        RecursiveTemplateAstVisitor;

/// Returns [template] parsed as an abstract syntax tree.
///
/// If [desugar] is set, parsing will transform `*directive` and `[(banana)]`
/// notations into their explicit forms using `<template>` and `[value]="..."
/// (valueChanged)="..."` respectively.
List<Template> parse(String template,
    {required String sourceUrl,
    bool desugar = true,
    ExceptionHandler exceptionHandler = const ThrowingExceptionHandler()}) {
  return const NgParser().parse(template, sourceUrl: sourceUrl, exceptionHandler: exceptionHandler, desugar: desugar);
}
