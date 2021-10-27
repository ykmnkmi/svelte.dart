import 'src/ast.dart';
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
        EmbeddedNode,
        Event,
        Interpolation,
        LetBinding,
        ParsedAnnotation,
        ParsedAttribute,
        ParsedBanana,
        ParsedCloseElement,
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
        Standalone,
        Star,
        Synthetic,
        TagOffsetInfo,
        Node,
        Text;
export 'src/lexer.dart' show Lexer;
export 'src/parser.dart' show Parser;
export 'src/parser_exception.dart' show ParserException;
export 'src/token/tokens.dart' show Token, TokenType, AttributeValueToken;
export 'src/visitor.dart'
    show
        HumanizingTemplateAstVisitor,
        IdentityVisitor,
        MinimizeWhitespaceVisitor,
        Visitor,
        DesugarVisitor,
        RecursiveTemplateAstVisitor;

List<Node> parse(String template, {required String sourceUrl, bool desugar = true}) {
  return const Parser().parse(template, sourceUrl: sourceUrl, desugar: desugar);
}
