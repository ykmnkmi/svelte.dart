// generated with `tools/generate_css_to_json.dart`
// ignore_for_file: avoid_renaming_method_parameters, depend_on_referenced_packages

import 'package:csslib/visitor.dart';

Map<String, int> getLocation(TreeNode node) {
  var span = node.span;

  if (span == null) {
    return const <String, int>{};
  }

  return <String, int>{
    'start': span.start.offset,
    'end': span.end.offset,
  };
}

class CssToJsonVisitor implements VisitorBase {
  const CssToJsonVisitor();

  List<Map<String, Object?>> visitAll(List<TreeNode> nodes) {
    return <Map<String, Object?>>[
      for (var node in nodes) node.visit(this) as Map<String, Object?>
    ];
  }

  @override
  Map<String, Object?> visitCalcTerm(CalcTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'CalcTerm',
      'expr': node.expr.visit(this),
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitCssComment(CssComment node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'CssComment',
      'comment': node.comment,
    };
  }

  @override
  Map<String, Object?> visitCommentDefinition(CommentDefinition node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'CommentDefinition',
      // CssComment
      'comment': node.comment,
    };
  }

  @override
  Map<String, Object?> visitStyleSheet(StyleSheet node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'StyleSheet',
      if (node.topLevels.isNotEmpty)
        'topLevels': <Map<String, Object?>>[
          for (var item in node.topLevels)
            item.visit(this) as Map<String, Object?>,
        ],
    };
  }

  @override
  Map<String, Object?> visitNoOp(NoOp node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'NoOp',
    };
  }

  @override
  Map<String, Object?> visitTopLevelProduction(TopLevelProduction node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'TopLevelProduction',
    };
  }

  @override
  Map<String, Object?> visitDirective(Directive node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'Directive',
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitDocumentDirective(DocumentDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'DocumentDirective',
      if (node.functions.isNotEmpty)
        'functions': <Map<String, Object?>>[
          for (var item in node.functions)
            item.visit(this) as Map<String, Object?>,
        ],
      if (node.groupRuleBody.isNotEmpty)
        'groupRuleBody': <Map<String, Object?>>[
          for (var item in node.groupRuleBody)
            item.visit(this) as Map<String, Object?>,
        ],
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitSupportsDirective(SupportsDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SupportsDirective',
      if (node.condition != null) 'condition': node.condition!.visit(this),
      if (node.groupRuleBody.isNotEmpty)
        'groupRuleBody': <Map<String, Object?>>[
          for (var item in node.groupRuleBody)
            item.visit(this) as Map<String, Object?>,
        ],
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitSupportsConditionInParens(
      SupportsConditionInParens node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SupportsConditionInParens',
      if (node.condition != null) 'condition': node.condition!.visit(this),
      // SupportsCondition
    };
  }

  @override
  Map<String, Object?> visitSupportsNegation(SupportsNegation node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SupportsNegation',
      'condition': node.condition.visit(this),
      // SupportsCondition
    };
  }

  @override
  Map<String, Object?> visitSupportsConjunction(SupportsConjunction node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SupportsConjunction',
      if (node.conditions.isNotEmpty)
        'conditions': <Map<String, Object?>>[
          for (var item in node.conditions)
            item.visit(this) as Map<String, Object?>,
        ],
      // SupportsCondition
    };
  }

  @override
  Map<String, Object?> visitSupportsDisjunction(SupportsDisjunction node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SupportsDisjunction',
      if (node.conditions.isNotEmpty)
        'conditions': <Map<String, Object?>>[
          for (var item in node.conditions)
            item.visit(this) as Map<String, Object?>,
        ],
      // SupportsCondition
    };
  }

  @override
  Map<String, Object?> visitViewportDirective(ViewportDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ViewportDirective',
      'name': node.name,
      'declarations': node.declarations.visit(this),
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitMediaExpression(MediaExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'MediaExpression',
      if (node.andOperator) 'andOperator': node.andOperator,
      'exprs': node.exprs.visit(this),
      'mediaFeature': node.mediaFeature,
    };
  }

  @override
  Map<String, Object?> visitMediaQuery(MediaQuery node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'MediaQuery',
      if (node.expressions.isNotEmpty)
        'expressions': <Map<String, Object?>>[
          for (var item in node.expressions)
            item.visit(this) as Map<String, Object?>,
        ],
      if (node.hasMediaType) 'hasMediaType': node.hasMediaType,
      'mediaType': node.mediaType,
      if (node.hasUnary) 'hasUnary': node.hasUnary,
      'unary': node.unary,
    };
  }

  @override
  Map<String, Object?> visitMediaDirective(MediaDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'MediaDirective',
      if (node.mediaQueries.isNotEmpty)
        'mediaQueries': <Map<String, Object?>>[
          for (var item in node.mediaQueries)
            item.visit(this) as Map<String, Object?>,
        ],
      if (node.rules.isNotEmpty)
        'rules': <Map<String, Object?>>[
          for (var item in node.rules) item.visit(this) as Map<String, Object?>,
        ],
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitHostDirective(HostDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'HostDirective',
      if (node.rules.isNotEmpty)
        'rules': <Map<String, Object?>>[
          for (var item in node.rules) item.visit(this) as Map<String, Object?>,
        ],
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitPageDirective(PageDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'PageDirective',
      if (node.hasIdent) 'hasIdent': node.hasIdent,
      if (node.hasPseudoPage) 'hasPseudoPage': node.hasPseudoPage,
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitCharsetDirective(CharsetDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'CharsetDirective',
      'charEncoding': node.charEncoding,
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitImportDirective(ImportDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ImportDirective',
      'import': node.import,
      if (node.mediaQueries.isNotEmpty)
        'mediaQueries': <Map<String, Object?>>[
          for (var item in node.mediaQueries)
            item.visit(this) as Map<String, Object?>,
        ],
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitKeyFrameDirective(KeyFrameDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'KeyFrameDirective',
      if (node.name != null) 'name': node.name!.visit(this),
      if (node.keyFrameName != null) 'keyFrameName': node.keyFrameName!,
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitKeyFrameBlock(KeyFrameBlock node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'KeyFrameBlock',
      // Expression
    };
  }

  @override
  Map<String, Object?> visitFontFaceDirective(FontFaceDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'FontFaceDirective',
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitStyletDirective(StyletDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'StyletDirective',
      'dartClassName': node.dartClassName,
      if (node.rules.isNotEmpty)
        'rules': <Map<String, Object?>>[
          for (var item in node.rules) item.visit(this) as Map<String, Object?>,
        ],
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
      // Directive
    };
  }

  @override
  Map<String, Object?> visitNamespaceDirective(NamespaceDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'NamespaceDirective',
      'prefix': node.prefix,
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitVarDefinitionDirective(
      VarDefinitionDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'VarDefinitionDirective',
      'def': node.def.visit(this),
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitMixinDefinition(MixinDefinition node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'MixinDefinition',
      'name': node.name,
      if (node.definedArgs.isNotEmpty)
        'definedArgs': <Map<String, Object?>>[
          for (var item in node.definedArgs)
            item.visit(this) as Map<String, Object?>,
        ],
      if (node.varArgs) 'varArgs': node.varArgs,
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitMixinRulesetDirective(MixinRulesetDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'MixinRulesetDirective',
      if (node.rulesets.isNotEmpty)
        'rulesets': <Map<String, Object?>>[
          for (var item in node.rulesets)
            item.visit(this) as Map<String, Object?>,
        ],
      // MixinDefinition
      'name': node.name,
      if (node.definedArgs.isNotEmpty)
        'definedArgs': <Map<String, Object?>>[
          for (var item in node.definedArgs)
            item.visit(this) as Map<String, Object?>,
        ],
      if (node.varArgs) 'varArgs': node.varArgs,
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitMixinDeclarationDirective(
      MixinDeclarationDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'MixinDeclarationDirective',
      'declarations': node.declarations.visit(this),
      // MixinDefinition
      'name': node.name,
      if (node.definedArgs.isNotEmpty)
        'definedArgs': <Map<String, Object?>>[
          for (var item in node.definedArgs)
            item.visit(this) as Map<String, Object?>,
        ],
      if (node.varArgs) 'varArgs': node.varArgs,
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitIncludeDirective(IncludeDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'IncludeDirective',
      'name': node.name,
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitContentDirective(ContentDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ContentDirective',
      // Directive
      if (node.isBuiltIn) 'isBuiltIn': node.isBuiltIn,
      if (node.isExtension) 'isExtension': node.isExtension,
    };
  }

  @override
  Map<String, Object?> visitRuleSet(RuleSet node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'RuleSet',
      if (node.selectorGroup != null)
        'selectorGroup': node.selectorGroup!.visit(this),
      'declarationGroup': node.declarationGroup.visit(this),
      // TopLevelProduction
    };
  }

  @override
  Map<String, Object?> visitDeclarationGroup(DeclarationGroup node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'DeclarationGroup',
      if (node.declarations.isNotEmpty)
        'declarations': <Map<String, Object?>>[
          for (var item in node.declarations)
            item.visit(this) as Map<String, Object?>,
        ],
    };
  }

  @override
  Map<String, Object?> visitMarginGroup(MarginGroup node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'MarginGroup',
      // DeclarationGroup
      if (node.declarations.isNotEmpty)
        'declarations': <Map<String, Object?>>[
          for (var item in node.declarations)
            item.visit(this) as Map<String, Object?>,
        ],
    };
  }

  @override
  Map<String, Object?> visitDeclaration(Declaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'Declaration',
      if (node.expression != null) 'expression': node.expression!.visit(this),
      if (node.dartStyle != null) 'dartStyle': node.dartStyle!.visit(this),
      if (node.important) 'important': node.important,
      if (node.isIE7) 'isIE7': node.isIE7,
      'property': node.property,
      if (node.hasDartStyle) 'hasDartStyle': node.hasDartStyle,
    };
  }

  @override
  Map<String, Object?> visitVarDefinition(VarDefinition node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'VarDefinition',
      if (node.badUsage) 'badUsage': node.badUsage,
      'definedName': node.definedName,
      // Declaration
      if (node.expression != null) 'expression': node.expression!.visit(this),
      if (node.dartStyle != null) 'dartStyle': node.dartStyle!.visit(this),
      if (node.important) 'important': node.important,
      if (node.isIE7) 'isIE7': node.isIE7,
      'property': node.property,
      if (node.hasDartStyle) 'hasDartStyle': node.hasDartStyle,
    };
  }

  @override
  Map<String, Object?> visitIncludeMixinAtDeclaration(
      IncludeMixinAtDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'IncludeMixinAtDeclaration',
      'include': node.include.visit(this),
      // Declaration
      if (node.expression != null) 'expression': node.expression!.visit(this),
      if (node.dartStyle != null) 'dartStyle': node.dartStyle!.visit(this),
      if (node.important) 'important': node.important,
      if (node.isIE7) 'isIE7': node.isIE7,
      'property': node.property,
      if (node.hasDartStyle) 'hasDartStyle': node.hasDartStyle,
    };
  }

  @override
  Map<String, Object?> visitExtendDeclaration(ExtendDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ExtendDeclaration',
      if (node.selectors.isNotEmpty)
        'selectors': <Map<String, Object?>>[
          for (var item in node.selectors)
            item.visit(this) as Map<String, Object?>,
        ],
      // Declaration
      if (node.expression != null) 'expression': node.expression!.visit(this),
      if (node.dartStyle != null) 'dartStyle': node.dartStyle!.visit(this),
      if (node.important) 'important': node.important,
      if (node.isIE7) 'isIE7': node.isIE7,
      'property': node.property,
      if (node.hasDartStyle) 'hasDartStyle': node.hasDartStyle,
    };
  }

  @override
  Map<String, Object?> visitSelectorGroup(SelectorGroup node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SelectorGroup',
      if (node.selectors.isNotEmpty)
        'selectors': <Map<String, Object?>>[
          for (var item in node.selectors)
            item.visit(this) as Map<String, Object?>,
        ],
    };
  }

  @override
  Map<String, Object?> visitSelector(Selector node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'Selector',
      if (node.simpleSelectorSequences.isNotEmpty)
        'simpleSelectorSequences': <Map<String, Object?>>[
          for (var item in node.simpleSelectorSequences)
            item.visit(this) as Map<String, Object?>,
        ],
    };
  }

  @override
  Map<String, Object?> visitSimpleSelectorSequence(
      SimpleSelectorSequence node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SimpleSelectorSequence',
      'simpleSelector': node.simpleSelector.visit(this),
      if (node.isCombinatorNone) 'isCombinatorNone': node.isCombinatorNone,
      if (node.isCombinatorPlus) 'isCombinatorPlus': node.isCombinatorPlus,
      if (node.isCombinatorGreater)
        'isCombinatorGreater': node.isCombinatorGreater,
      if (node.isCombinatorTilde) 'isCombinatorTilde': node.isCombinatorTilde,
      if (node.isCombinatorDescendant)
        'isCombinatorDescendant': node.isCombinatorDescendant,
    };
  }

  @override
  Map<String, Object?> visitSimpleSelector(SimpleSelector node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SimpleSelector',
      'name': node.name,
      if (node.isWildcard) 'isWildcard': node.isWildcard,
      if (node.isThis) 'isThis': node.isThis,
    };
  }

  @override
  Map<String, Object?> visitElementSelector(ElementSelector node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ElementSelector',
      // SimpleSelector
      'name': node.name,
      if (node.isWildcard) 'isWildcard': node.isWildcard,
      if (node.isThis) 'isThis': node.isThis,
    };
  }

  @override
  Map<String, Object?> visitNamespaceSelector(NamespaceSelector node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'NamespaceSelector',
      'namespace': node.namespace,
      if (node.isNamespaceWildcard)
        'isNamespaceWildcard': node.isNamespaceWildcard,
      if (node.nameAsSimpleSelector != null)
        'nameAsSimpleSelector': node.nameAsSimpleSelector!.visit(this),
      // SimpleSelector
      'name': node.name,
      if (node.isWildcard) 'isWildcard': node.isWildcard,
      if (node.isThis) 'isThis': node.isThis,
    };
  }

  @override
  Map<String, Object?> visitAttributeSelector(AttributeSelector node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'AttributeSelector',
      // SimpleSelector
      'name': node.name,
      if (node.isWildcard) 'isWildcard': node.isWildcard,
      if (node.isThis) 'isThis': node.isThis,
    };
  }

  @override
  Map<String, Object?> visitIdSelector(IdSelector node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'IdSelector',
      // SimpleSelector
      'name': node.name,
      if (node.isWildcard) 'isWildcard': node.isWildcard,
      if (node.isThis) 'isThis': node.isThis,
    };
  }

  @override
  Map<String, Object?> visitClassSelector(ClassSelector node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ClassSelector',
      // SimpleSelector
      'name': node.name,
      if (node.isWildcard) 'isWildcard': node.isWildcard,
      if (node.isThis) 'isThis': node.isThis,
    };
  }

  @override
  Map<String, Object?> visitPseudoClassSelector(PseudoClassSelector node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'PseudoClassSelector',
      // SimpleSelector
      'name': node.name,
      if (node.isWildcard) 'isWildcard': node.isWildcard,
      if (node.isThis) 'isThis': node.isThis,
    };
  }

  @override
  Map<String, Object?> visitPseudoElementSelector(PseudoElementSelector node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'PseudoElementSelector',
      if (node.isLegacy) 'isLegacy': node.isLegacy,
      // SimpleSelector
      'name': node.name,
      if (node.isWildcard) 'isWildcard': node.isWildcard,
      if (node.isThis) 'isThis': node.isThis,
    };
  }

  @override
  Map<String, Object?> visitPseudoClassFunctionSelector(
      PseudoClassFunctionSelector node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'PseudoClassFunctionSelector',
      'argument': node.argument.visit(this),
      'selector': node.selector.visit(this),
      'expression': node.expression.visit(this),
      // PseudoClassSelector
      // SimpleSelector
      'name': node.name,
      if (node.isWildcard) 'isWildcard': node.isWildcard,
      if (node.isThis) 'isThis': node.isThis,
    };
  }

  @override
  Map<String, Object?> visitPseudoElementFunctionSelector(
      PseudoElementFunctionSelector node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'PseudoElementFunctionSelector',
      'expression': node.expression.visit(this),
      // PseudoElementSelector
      if (node.isLegacy) 'isLegacy': node.isLegacy,
      // SimpleSelector
      'name': node.name,
      if (node.isWildcard) 'isWildcard': node.isWildcard,
      if (node.isThis) 'isThis': node.isThis,
    };
  }

  @override
  Map<String, Object?> visitNegationSelector(NegationSelector node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'NegationSelector',
      if (node.negationArg != null)
        'negationArg': node.negationArg!.visit(this),
      // SimpleSelector
      'name': node.name,
      if (node.isWildcard) 'isWildcard': node.isWildcard,
      if (node.isThis) 'isThis': node.isThis,
    };
  }

  @override
  Map<String, Object?> visitSelectorExpression(SelectorExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SelectorExpression',
      if (node.expressions.isNotEmpty)
        'expressions': <Map<String, Object?>>[
          for (var item in node.expressions)
            item.visit(this) as Map<String, Object?>,
        ],
    };
  }

  @override
  Map<String, Object?> visitUnicodeRangeTerm(UnicodeRangeTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'UnicodeRangeTerm',
      if (node.first != null) 'first': node.first!,
      if (node.second != null) 'second': node.second!,
      if (node.hasSecond) 'hasSecond': node.hasSecond,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitLiteralTerm(LiteralTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'LiteralTerm',
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitHexColorTerm(HexColorTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'HexColorTerm',
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitNumberTerm(NumberTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'NumberTerm',
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitUnitTerm(UnitTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'UnitTerm',
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitLengthTerm(LengthTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'LengthTerm',
      // UnitTerm
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitPercentageTerm(PercentageTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'PercentageTerm',
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitEmTerm(EmTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'EmTerm',
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitExTerm(ExTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ExTerm',
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitAngleTerm(AngleTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'AngleTerm',
      // UnitTerm
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitTimeTerm(TimeTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'TimeTerm',
      // UnitTerm
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitFreqTerm(FreqTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'FreqTerm',
      // UnitTerm
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitFractionTerm(FractionTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'FractionTerm',
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitUriTerm(UriTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'UriTerm',
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitResolutionTerm(ResolutionTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ResolutionTerm',
      // UnitTerm
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitChTerm(ChTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ChTerm',
      // UnitTerm
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitRemTerm(RemTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'RemTerm',
      // UnitTerm
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitViewportTerm(ViewportTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ViewportTerm',
      // UnitTerm
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitFunctionTerm(FunctionTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'FunctionTerm',
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitGroupTerm(GroupTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'GroupTerm',
      // Expression
    };
  }

  @override
  Map<String, Object?> visitItemTerm(ItemTerm node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ItemTerm',
      // NumberTerm
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitIE8Term(IE8Term node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'IE8Term',
      // LiteralTerm
      'text': node.text,
      // Expression
    };
  }

  @override
  Map<String, Object?> visitOperatorSlash(OperatorSlash node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'OperatorSlash',
      // Expression
    };
  }

  @override
  Map<String, Object?> visitOperatorComma(OperatorComma node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'OperatorComma',
      // Expression
    };
  }

  @override
  Map<String, Object?> visitOperatorPlus(OperatorPlus node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'OperatorPlus',
      // Expression
    };
  }

  @override
  Map<String, Object?> visitOperatorMinus(OperatorMinus node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'OperatorMinus',
      // Expression
    };
  }

  @override
  Map<String, Object?> visitVarUsage(VarUsage node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'VarUsage',
      'name': node.name,
      if (node.defaultValues.isNotEmpty)
        'defaultValues': <Map<String, Object?>>[
          for (var item in node.defaultValues)
            item.visit(this) as Map<String, Object?>,
        ],
      // Expression
    };
  }

  @override
  Map<String, Object?> visitExpressions(Expressions node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'Expressions',
      if (node.expressions.isNotEmpty)
        'expressions': <Map<String, Object?>>[
          for (var item in node.expressions)
            item.visit(this) as Map<String, Object?>,
        ],
      // Expression
    };
  }

  @override
  Map<String, Object?> visitBinaryExpression(BinaryExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'BinaryExpression',
      'x': node.x.visit(this),
      'y': node.y.visit(this),
      // Expression
    };
  }

  @override
  Map<String, Object?> visitUnaryExpression(UnaryExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'UnaryExpression',
      'self': node.self.visit(this),
      // Expression
    };
  }

  @override
  Map<String, Object?> visitIdentifier(Identifier node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'Identifier',
      'name': node.name,
    };
  }

  @override
  Map<String, Object?> visitWildcard(Wildcard node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'Wildcard',
      'name': node.name,
    };
  }

  @override
  Map<String, Object?> visitThisOperator(ThisOperator node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ThisOperator',
      'name': node.name,
    };
  }

  @override
  Map<String, Object?> visitNegation(Negation node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'Negation',
      'name': node.name,
    };
  }

  @override
  Map<String, Object?> visitDartStyleExpression(DartStyleExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'DartStyleExpression',
      if (node.isUnknown) 'isUnknown': node.isUnknown,
      if (node.isFont) 'isFont': node.isFont,
      if (node.isMargin) 'isMargin': node.isMargin,
      if (node.isBorder) 'isBorder': node.isBorder,
      if (node.isPadding) 'isPadding': node.isPadding,
      if (node.isHeight) 'isHeight': node.isHeight,
      if (node.isWidth) 'isWidth': node.isWidth,
      if (node.isBoxExpression) 'isBoxExpression': node.isBoxExpression,
    };
  }

  @override
  Map<String, Object?> visitFontExpression(FontExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'FontExpression',
      // DartStyleExpression
      if (node.isUnknown) 'isUnknown': node.isUnknown,
      if (node.isFont) 'isFont': node.isFont,
      if (node.isMargin) 'isMargin': node.isMargin,
      if (node.isBorder) 'isBorder': node.isBorder,
      if (node.isPadding) 'isPadding': node.isPadding,
      if (node.isHeight) 'isHeight': node.isHeight,
      if (node.isWidth) 'isWidth': node.isWidth,
      if (node.isBoxExpression) 'isBoxExpression': node.isBoxExpression,
    };
  }

  @override
  Map<String, Object?> visitBoxExpression(BoxExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'BoxExpression',
      'formattedBoxEdge': node.formattedBoxEdge,
      // DartStyleExpression
      if (node.isUnknown) 'isUnknown': node.isUnknown,
      if (node.isFont) 'isFont': node.isFont,
      if (node.isMargin) 'isMargin': node.isMargin,
      if (node.isBorder) 'isBorder': node.isBorder,
      if (node.isPadding) 'isPadding': node.isPadding,
      if (node.isHeight) 'isHeight': node.isHeight,
      if (node.isWidth) 'isWidth': node.isWidth,
      if (node.isBoxExpression) 'isBoxExpression': node.isBoxExpression,
    };
  }

  @override
  Map<String, Object?> visitMarginExpression(MarginExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'MarginExpression',
      // BoxExpression
      'formattedBoxEdge': node.formattedBoxEdge,
      // DartStyleExpression
      if (node.isUnknown) 'isUnknown': node.isUnknown,
      if (node.isFont) 'isFont': node.isFont,
      if (node.isMargin) 'isMargin': node.isMargin,
      if (node.isBorder) 'isBorder': node.isBorder,
      if (node.isPadding) 'isPadding': node.isPadding,
      if (node.isHeight) 'isHeight': node.isHeight,
      if (node.isWidth) 'isWidth': node.isWidth,
      if (node.isBoxExpression) 'isBoxExpression': node.isBoxExpression,
    };
  }

  @override
  Map<String, Object?> visitBorderExpression(BorderExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'BorderExpression',
      // BoxExpression
      'formattedBoxEdge': node.formattedBoxEdge,
      // DartStyleExpression
      if (node.isUnknown) 'isUnknown': node.isUnknown,
      if (node.isFont) 'isFont': node.isFont,
      if (node.isMargin) 'isMargin': node.isMargin,
      if (node.isBorder) 'isBorder': node.isBorder,
      if (node.isPadding) 'isPadding': node.isPadding,
      if (node.isHeight) 'isHeight': node.isHeight,
      if (node.isWidth) 'isWidth': node.isWidth,
      if (node.isBoxExpression) 'isBoxExpression': node.isBoxExpression,
    };
  }

  @override
  Map<String, Object?> visitHeightExpression(HeightExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'HeightExpression',
      // DartStyleExpression
      if (node.isUnknown) 'isUnknown': node.isUnknown,
      if (node.isFont) 'isFont': node.isFont,
      if (node.isMargin) 'isMargin': node.isMargin,
      if (node.isBorder) 'isBorder': node.isBorder,
      if (node.isPadding) 'isPadding': node.isPadding,
      if (node.isHeight) 'isHeight': node.isHeight,
      if (node.isWidth) 'isWidth': node.isWidth,
      if (node.isBoxExpression) 'isBoxExpression': node.isBoxExpression,
    };
  }

  @override
  Map<String, Object?> visitPaddingExpression(PaddingExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'PaddingExpression',
      // BoxExpression
      'formattedBoxEdge': node.formattedBoxEdge,
      // DartStyleExpression
      if (node.isUnknown) 'isUnknown': node.isUnknown,
      if (node.isFont) 'isFont': node.isFont,
      if (node.isMargin) 'isMargin': node.isMargin,
      if (node.isBorder) 'isBorder': node.isBorder,
      if (node.isPadding) 'isPadding': node.isPadding,
      if (node.isHeight) 'isHeight': node.isHeight,
      if (node.isWidth) 'isWidth': node.isWidth,
      if (node.isBoxExpression) 'isBoxExpression': node.isBoxExpression,
    };
  }

  @override
  Map<String, Object?> visitWidthExpression(WidthExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'WidthExpression',
      // DartStyleExpression
      if (node.isUnknown) 'isUnknown': node.isUnknown,
      if (node.isFont) 'isFont': node.isFont,
      if (node.isMargin) 'isMargin': node.isMargin,
      if (node.isBorder) 'isBorder': node.isBorder,
      if (node.isPadding) 'isPadding': node.isPadding,
      if (node.isHeight) 'isHeight': node.isHeight,
      if (node.isWidth) 'isWidth': node.isWidth,
      if (node.isBoxExpression) 'isBoxExpression': node.isBoxExpression,
    };
  }
}
