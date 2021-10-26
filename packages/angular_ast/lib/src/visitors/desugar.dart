import '../ast.dart';
import '../exception_handler/exception_handler.dart';
import '../expression/micro.dart';
import '../visitor.dart';

/// Desugars complex nodes such as `[(banana)]` into simpler forms.
///
/// Ignores non-desugrable nodes. This visitor mutates and returns the AST where
/// the original node can be accessed by [SyntheticTemplate.origin].
class DesugarVisitor extends IdentityTemplateAstVisitor<void> implements TemplateVisitor<Template, void> {
  /// Create a new visitor.
  DesugarVisitor({ExceptionHandler? exceptionHandler})
      : exceptionHandler = exceptionHandler ?? const ThrowingExceptionHandler();

  final ExceptionHandler exceptionHandler;

  @override
  Template visitContainer(Container astNode, [void _]) {
    _visitChildren(astNode);

    if (astNode.stars.isNotEmpty) {
      return _desugarStar(astNode, astNode.stars);
    }

    return astNode;
  }

  @override
  Template visitElement(Element astNode, [void _]) {
    _visitChildren(astNode);

    if (astNode.bananas.isNotEmpty) {
      _desugarBananas(astNode);
    }

    if (astNode.stars.isNotEmpty) {
      return _desugarStar(astNode, astNode.stars);
    }

    return astNode;
  }

  void _visitChildren(Template astNode) {
    if (astNode.childNodes.isEmpty) {
      return;
    }

    var newChildren = <StandaloneTemplate>[];

    for (var child in astNode.childNodes) {
      newChildren.add(child.accept(this) as StandaloneTemplate);
    }

    astNode.childNodes.clear();
    astNode.childNodes.addAll(newChildren);
  }

  @override
  Template visitEmbeddedContent(EmbeddedContent astNode, [void _]) {
    return astNode;
  }

  @override
  Template visitEmbeddedTemplate(EmbeddedTemplateAst astNode, [void _]) {
    _visitChildren(astNode);
    return astNode;
  }

  /// Rewrites each banana on [astNode] as an event, property binding pair.
  ///
  /// For example, the banana binding
  ///
  ///     [(foo)]="bar"
  ///
  /// is rewritten as the property binding
  ///
  ///     [foo]="bar"
  ///
  /// and the event binding
  ///
  ///     (fooChange)="bar = $event"
  ///
  /// This clears any banana bindings from [astNode].
  void _desugarBananas(Element astNode) {
    for (var banana in astNode.bananas) {
      if (banana.value == null) {
        continue;
      }

      astNode
        ..events.add(Event.from(banana, '${banana.name}Change', '${banana.value} = \$event'))
        ..properties.add(Property.from(banana, banana.name, banana.value!));
    }

    astNode.bananas.clear();
  }

  Template _desugarStar(StandaloneTemplate astNode, List<Star> stars) {
    var starAst = stars[0];
    var origin = starAst;
    var starExpression = starAst.value?.trim();
    var expressionOffset = (starAst as ParsedStar).valueToken?.innerValue?.offset;
    var directiveName = starAst.name;
    EmbeddedTemplateAst newAst;
    var attributesToAdd = <Attribute>[];
    var propertiesToAdd = <Property>[];
    var letBindingsToAdd = <LetBinding>[];

    if (isMicroExpression(starExpression)) {
      NgMicroAst micro;

      try {
        micro = parseMicroExpression(directiveName, starExpression, expressionOffset,
            sourceUrl: astNode.sourceUrl!, origin: origin);
      } on AngularParserException catch (e) {
        exceptionHandler.handle(e);
        return astNode;
      }

      propertiesToAdd.addAll(micro.properties);
      letBindingsToAdd.addAll(micro.letBindings);

      // If the micro-syntax did not produce a binding to the left-hand side
      // property, add it as an attribute in case a directive selector
      // depends on it.
      if (!propertiesToAdd.any((p) => p.name == directiveName)) {
        attributesToAdd.add(Attribute.from(origin, directiveName));
      }

      newAst = EmbeddedTemplateAst.from(origin,
          childNodes: <StandaloneTemplate>[astNode],
          attributes: attributesToAdd,
          properties: propertiesToAdd,
          letBindings: letBindingsToAdd);
    } else {
      if (starExpression == null) {
        // In the rare case the *-binding has no RHS expression, add the LHS
        // as an attribute rather than a property. This allows matching a
        // directive with an attribute selector, but no input of the same
        // name.
        attributesToAdd.add(Attribute.from(origin, directiveName));
      } else {
        propertiesToAdd.add(Property.from(origin, directiveName, starExpression));
      }

      newAst = EmbeddedTemplateAst.from(origin,
          childNodes: <StandaloneTemplate>[astNode], attributes: attributesToAdd, properties: propertiesToAdd);
    }

    stars.clear();
    return newAst;
  }
}
