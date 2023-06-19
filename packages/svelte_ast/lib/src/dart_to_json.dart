// generated with `tools/generate_dart_to_json.dart`

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

Map<String, Object?> getToken(Token token) {
  return <String, Object?>{
    'start': token.offset,
    'end': token.end,
    'type': token.type.name,
    'lexeme': token.lexeme,
  };
}

Map<String, Object?> getLocation(AstNode node) {
  return <String, Object?>{
    'start': node.offset,
    'end': node.end,
  };
}

class DartToJsonVisitor implements AstVisitor<Map<String, Object?>> {
  const DartToJsonVisitor();

  List<Map<String, Object?>?> visitAll(List<AstNode> nodes) {
    return <Map<String, Object?>?>[for (var node in nodes) node.accept(this)];
  }

  @override
  Map<String, Object?>? visitAdjacentStrings(AdjacentStrings node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'AdjacentStrings',
      if (node.strings.isNotEmpty)
        'strings': <Map<String, Object?>?>[
          for (var item in node.strings) item.accept(this),
        ],
      // AdjacentStrings - StringLiteral
      if (node.stringValue case var stringValue?) 'stringValue': stringValue,
      // StringLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitAnnotation(Annotation node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'Annotation',
      if (node.arguments case var arguments?)
        'arguments': arguments.accept(this),
      // 'atSign': InvalidType
      if (node.constructorName case var constructorName?)
        'constructorName': constructorName.accept(this),
      // 'element': InvalidType
      // 'elementAnnotation': InvalidType
      'name': node.name.accept(this),
      // 'period': InvalidType
      if (node.typeArguments case var typeArguments?)
        'typeArguments': typeArguments.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitArgumentList(ArgumentList node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ArgumentList',
      if (node.arguments.isNotEmpty)
        'arguments': <Map<String, Object?>?>[
          for (var item in node.arguments) item.accept(this),
        ],
      // 'leftParenthesis': InvalidType
      // 'rightParenthesis': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitAsExpression(AsExpression node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'AsExpression', // 'asOperator': InvalidType
      'expression': node.expression.accept(this),
      // AsExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitAssertInitializer(AssertInitializer node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'AssertInitializer', // AssertInitializer - Assertion
      // 'assertKeyword': InvalidType
      // 'comma': InvalidType
      'condition': node.condition.accept(this),
      // 'leftParenthesis': InvalidType
      if (node.message case var message?) 'message': message.accept(this),
      // 'rightParenthesis': InvalidType
      // AssertInitializer - ConstructorInitializer
    };
  }

  @override
  Map<String, Object?>? visitAssertStatement(AssertStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'AssertStatement', // 'semicolon': InvalidType
      // AssertStatement - Assertion
      // 'assertKeyword': InvalidType
      // 'comma': InvalidType
      'condition': node.condition.accept(this),
      // 'leftParenthesis': InvalidType
      if (node.message case var message?) 'message': message.accept(this),
      // 'rightParenthesis': InvalidType
      // AssertStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitAssignedVariablePattern(
      AssignedVariablePattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'AssignedVariablePattern', // 'element': InvalidType
      // AssignedVariablePattern - VariablePattern
      // 'name': InvalidType
      // VariablePattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitAssignmentExpression(AssignmentExpression node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'AssignmentExpression',
      'leftHandSide': node.leftHandSide.accept(this),
      // 'operator': InvalidType
      'rightHandSide': node.rightHandSide.accept(this),
      // AssignmentExpression - NullShortableExpression
      // NullShortableExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // AssignmentExpression - MethodReferenceExpression
      // 'staticElement': InvalidType
      // MethodReferenceExpression - Expression
      // Expression - CollectionElement
      // AssignmentExpression - CompoundAssignmentExpression
      // 'readElement': InvalidType
      // 'readType': InvalidType
      // 'writeElement': InvalidType
      // 'writeType': InvalidType
      // CompoundAssignmentExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitAugmentationImportDirective(
      AugmentationImportDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'AugmentationImportDirective', // 'augmentKeyword': InvalidType
      // 'element': InvalidType
      // 'importKeyword': InvalidType
      // 'semicolon': InvalidType
      // AugmentationImportDirective - UriBasedDirective
      'uri': node.uri.accept(this),
      // UriBasedDirective - Directive
      // Directive - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitAwaitExpression(AwaitExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'AwaitExpression', // 'awaitKeyword': InvalidType
      'expression': node.expression.accept(this),
      // AwaitExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitBinaryExpression(BinaryExpression node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'BinaryExpression',
      'leftOperand': node.leftOperand.accept(this),
      // 'operator': InvalidType
      'rightOperand': node.rightOperand.accept(this),
      // 'staticInvokeType': InvalidType
      // BinaryExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // BinaryExpression - MethodReferenceExpression
      // 'staticElement': InvalidType
      // MethodReferenceExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitBlock(Block node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'Block', // 'leftBracket': InvalidType
      // 'rightBracket': InvalidType
      if (node.statements.isNotEmpty)
        'statements': <Map<String, Object?>?>[
          for (var item in node.statements) item.accept(this),
        ],
      // Block - Statement
    };
  }

  @override
  Map<String, Object?>? visitBlockFunctionBody(BlockFunctionBody node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'BlockFunctionBody',
      'block': node.block.accept(this),
      // BlockFunctionBody - FunctionBody
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
      // 'keyword': InvalidType
      // 'star': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitBooleanLiteral(BooleanLiteral node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'BooleanLiteral', // 'literal': InvalidType
      if (node.value) 'value': node.value,
      // BooleanLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitBreakStatement(BreakStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'BreakStatement', // 'breakKeyword': InvalidType
      if (node.label case var label?) 'label': label.accept(this),
      // 'semicolon': InvalidType
      if (node.target case var target?) 'target': target.accept(this),
      // BreakStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitCascadeExpression(CascadeExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'CascadeExpression',
      if (node.cascadeSections.isNotEmpty)
        'cascadeSections': <Map<String, Object?>?>[
          for (var item in node.cascadeSections) item.accept(this),
        ],
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      'target': node.target.accept(this),
      // CascadeExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // CascadeExpression - NullShortableExpression
      // NullShortableExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitCaseClause(CaseClause node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'CaseClause', // 'caseKeyword': InvalidType
      'guardedPattern': node.guardedPattern.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitCastPattern(CastPattern node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'CastPattern', // 'asToken': InvalidType
      'pattern': node.pattern.accept(this),
      // CastPattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitCatchClause(CatchClause node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'CatchClause',
      'body': node.body.accept(this),
      // 'catchKeyword': InvalidType
      // 'comma': InvalidType
      if (node.exceptionParameter case var exceptionParameter?)
        'exceptionParameter': exceptionParameter.accept(this),
      if (node.exceptionType case var exceptionType?)
        'exceptionType': exceptionType.accept(this),
      // 'leftParenthesis': InvalidType
      // 'onKeyword': InvalidType
      // 'rightParenthesis': InvalidType
      if (node.stackTraceParameter case var stackTraceParameter?)
        'stackTraceParameter': stackTraceParameter.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitCatchClauseParameter(CatchClauseParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'CatchClauseParameter', // 'declaredElement': InvalidType
      // 'name': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitClassDeclaration(ClassDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ClassDeclaration', // 'declaredElement': InvalidType
      if (node.implementsClause case var implementsClause?)
        'implementsClause': implementsClause.accept(this),
      // 'inlineKeyword': InvalidType
      // 'leftBracket': InvalidType
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      if (node.nativeClause case var nativeClause?)
        'nativeClause': nativeClause.accept(this),
      // 'rightBracket': InvalidType
      if (node.typeParameters case var typeParameters?)
        'typeParameters': typeParameters.accept(this),
      // ClassDeclaration - ClassOrAugmentationDeclaration
      // 'abstractKeyword': InvalidType
      // 'baseKeyword': InvalidType
      // 'classKeyword': InvalidType
      if (node.extendsClause case var extendsClause?)
        'extendsClause': extendsClause.accept(this),
      // 'finalKeyword': InvalidType
      // 'interfaceKeyword': InvalidType
      // 'mixinKeyword': InvalidType
      // 'sealedKeyword': InvalidType
      if (node.withClause case var withClause?)
        'withClause': withClause.accept(this),
      // ClassOrAugmentationDeclaration - NamedCompilationUnitMember
      // 'name': InvalidType
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitClassTypeAlias(ClassTypeAlias node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ClassTypeAlias', // 'abstractKeyword': InvalidType
      // 'baseKeyword': InvalidType
      // 'declaredElement': InvalidType
      // 'equals': InvalidType
      // 'finalKeyword': InvalidType
      if (node.implementsClause case var implementsClause?)
        'implementsClause': implementsClause.accept(this),
      // 'interfaceKeyword': InvalidType
      // 'mixinKeyword': InvalidType
      // 'sealedKeyword': InvalidType
      'superclass': node.superclass.accept(this),
      if (node.typeParameters case var typeParameters?)
        'typeParameters': typeParameters.accept(this),
      'withClause': node.withClause.accept(this),
      // ClassTypeAlias - TypeAlias
      // 'semicolon': InvalidType
      // 'typedefKeyword': InvalidType
      // TypeAlias - NamedCompilationUnitMember
      // 'name': InvalidType
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitComment(Comment node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'Comment',
      if (node.isBlock) 'isBlock': node.isBlock,
      if (node.isDocumentation) 'isDocumentation': node.isDocumentation,
      if (node.isEndOfLine) 'isEndOfLine': node.isEndOfLine,
      if (node.references.isNotEmpty)
        'references': <Map<String, Object?>?>[
          for (var item in node.references) item.accept(this),
        ],
      // 'tokens': List<InvalidType>
    };
  }

  @override
  Map<String, Object?>? visitCommentReference(CommentReference node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'CommentReference',
      'expression': node.expression.accept(this),
      // 'newKeyword': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitCompilationUnit(CompilationUnit node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'CompilationUnit',
      if (node.declarations.isNotEmpty)
        'declarations': <Map<String, Object?>?>[
          for (var item in node.declarations) item.accept(this),
        ],
      // 'declaredElement': InvalidType
      if (node.directives.isNotEmpty)
        'directives': <Map<String, Object?>?>[
          for (var item in node.directives) item.accept(this),
        ],
      // 'featureSet': InvalidType
      // 'languageVersionToken': InvalidType
      // 'lineInfo': InvalidType
      if (node.scriptTag case var scriptTag?)
        'scriptTag': scriptTag.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitConditionalExpression(ConditionalExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ConditionalExpression', // 'colon': InvalidType
      'condition': node.condition.accept(this),
      'elseExpression': node.elseExpression.accept(this),
      // 'question': InvalidType
      'thenExpression': node.thenExpression.accept(this),
      // ConditionalExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitConfiguration(Configuration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'Configuration', // 'equalToken': InvalidType
      // 'ifKeyword': InvalidType
      // 'leftParenthesis': InvalidType
      'name': node.name.accept(this),
      // 'resolvedUri': InvalidType
      // 'rightParenthesis': InvalidType
      'uri': node.uri.accept(this),
      if (node.value case var value?) 'value': value.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitConstantPattern(ConstantPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ConstantPattern', // 'constKeyword': InvalidType
      'expression': node.expression.accept(this),
      // ConstantPattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitConstructorDeclaration(
      ConstructorDeclaration node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ConstructorDeclaration',
      'body': node.body.accept(this),
      // 'constKeyword': InvalidType
      // 'declaredElement': InvalidType
      // 'externalKeyword': InvalidType
      // 'factoryKeyword': InvalidType
      if (node.initializers.isNotEmpty)
        'initializers': <Map<String, Object?>?>[
          for (var item in node.initializers) item.accept(this),
        ],
      // 'name': InvalidType
      'parameters': node.parameters.accept(this),
      // 'period': InvalidType
      if (node.redirectedConstructor case var redirectedConstructor?)
        'redirectedConstructor': redirectedConstructor.accept(this),
      'returnType': node.returnType.accept(this),
      // 'separator': InvalidType
      // ConstructorDeclaration - ClassMember
      // ClassMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitConstructorFieldInitializer(
      ConstructorFieldInitializer node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ConstructorFieldInitializer', // 'equals': InvalidType
      'expression': node.expression.accept(this),
      'fieldName': node.fieldName.accept(this),
      // 'period': InvalidType
      // 'thisKeyword': InvalidType
      // ConstructorFieldInitializer - ConstructorInitializer
    };
  }

  @override
  Map<String, Object?>? visitConstructorName(ConstructorName node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ConstructorName',
      if (node.name case var name?) 'name': name.accept(this),
      // 'period': InvalidType
      // ConstructorName - ConstructorReferenceNode
      // 'staticElement': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitConstructorReference(ConstructorReference node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ConstructorReference',
      'constructorName': node.constructorName.accept(this),
      // ConstructorReference - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // ConstructorReference - CommentReferableExpression
      // CommentReferableExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitConstructorSelector(ConstructorSelector node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ConstructorSelector',
      'name': node.name.accept(this),
      // 'period': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitContinueStatement(ContinueStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ContinueStatement', // 'continueKeyword': InvalidType
      if (node.label case var label?) 'label': label.accept(this),
      // 'semicolon': InvalidType
      if (node.target case var target?) 'target': target.accept(this),
      // ContinueStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitDeclaredIdentifier(DeclaredIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'DeclaredIdentifier', // 'declaredElement': InvalidType
      if (node.isConst) 'isConst': node.isConst,
      if (node.isFinal) 'isFinal': node.isFinal,
      // 'keyword': InvalidType
      // 'name': InvalidType
      // DeclaredIdentifier - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitDeclaredVariablePattern(
      DeclaredVariablePattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'DeclaredVariablePattern', // 'declaredElement': InvalidType
      // 'keyword': InvalidType
      // DeclaredVariablePattern - VariablePattern
      // 'name': InvalidType
      // VariablePattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitDefaultFormalParameter(
      DefaultFormalParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'DefaultFormalParameter',
      if (node.defaultValue case var defaultValue?)
        'defaultValue': defaultValue.accept(this),
      'parameter': node.parameter.accept(this),
      // 'separator': InvalidType
      // DefaultFormalParameter - FormalParameter
      // 'covariantKeyword': InvalidType
      // 'declaredElement': InvalidType
      if (node.isConst) 'isConst': node.isConst,
      if (node.isExplicitlyTyped) 'isExplicitlyTyped': node.isExplicitlyTyped,
      if (node.isFinal) 'isFinal': node.isFinal,
      if (node.isNamed) 'isNamed': node.isNamed,
      if (node.isOptional) 'isOptional': node.isOptional,
      if (node.isOptionalNamed) 'isOptionalNamed': node.isOptionalNamed,
      if (node.isOptionalPositional)
        'isOptionalPositional': node.isOptionalPositional,
      if (node.isPositional) 'isPositional': node.isPositional,
      if (node.isRequired) 'isRequired': node.isRequired,
      if (node.isRequiredNamed) 'isRequiredNamed': node.isRequiredNamed,
      if (node.isRequiredPositional)
        'isRequiredPositional': node.isRequiredPositional,
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      // 'name': InvalidType
      // 'requiredKeyword': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitDoStatement(DoStatement node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'DoStatement',
      'body': node.body.accept(this),
      'condition': node.condition.accept(this),
      // 'doKeyword': InvalidType
      // 'leftParenthesis': InvalidType
      // 'rightParenthesis': InvalidType
      // 'semicolon': InvalidType
      // 'whileKeyword': InvalidType
      // DoStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitDottedName(DottedName node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'DottedName',
      if (node.components.isNotEmpty)
        'components': <Map<String, Object?>?>[
          for (var item in node.components) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitDoubleLiteral(DoubleLiteral node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'DoubleLiteral', // 'literal': InvalidType
      'value': node.value,
      // DoubleLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitEmptyFunctionBody(EmptyFunctionBody node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'EmptyFunctionBody', // 'semicolon': InvalidType
      // EmptyFunctionBody - FunctionBody
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
      // 'keyword': InvalidType
      // 'star': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitEmptyStatement(EmptyStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'EmptyStatement', // 'semicolon': InvalidType
      // EmptyStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitEnumConstantArguments(EnumConstantArguments node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'EnumConstantArguments',
      'argumentList': node.argumentList.accept(this),
      if (node.constructorSelector case var constructorSelector?)
        'constructorSelector': constructorSelector.accept(this),
      if (node.typeArguments case var typeArguments?)
        'typeArguments': typeArguments.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitEnumConstantDeclaration(
      EnumConstantDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'EnumConstantDeclaration',
      if (node.arguments case var arguments?)
        'arguments': arguments.accept(this),
      // 'constructorElement': InvalidType
      // 'declaredElement': InvalidType
      // 'name': InvalidType
      // EnumConstantDeclaration - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitEnumDeclaration(EnumDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'EnumDeclaration',
      if (node.constants.isNotEmpty)
        'constants': <Map<String, Object?>?>[
          for (var item in node.constants) item.accept(this),
        ],
      // 'declaredElement': InvalidType
      // 'enumKeyword': InvalidType
      if (node.implementsClause case var implementsClause?)
        'implementsClause': implementsClause.accept(this),
      // 'leftBracket': InvalidType
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      // 'rightBracket': InvalidType
      // 'semicolon': InvalidType
      if (node.typeParameters case var typeParameters?)
        'typeParameters': typeParameters.accept(this),
      if (node.withClause case var withClause?)
        'withClause': withClause.accept(this),
      // EnumDeclaration - NamedCompilationUnitMember
      // 'name': InvalidType
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitExportDirective(ExportDirective node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ExportDirective', // 'element': InvalidType
      // 'exportKeyword': InvalidType
      // ExportDirective - NamespaceDirective
      if (node.combinators.isNotEmpty)
        'combinators': <Map<String, Object?>?>[
          for (var item in node.combinators) item.accept(this),
        ],
      if (node.configurations.isNotEmpty)
        'configurations': <Map<String, Object?>?>[
          for (var item in node.configurations) item.accept(this),
        ],
      // 'semicolon': InvalidType
      // NamespaceDirective - UriBasedDirective
      'uri': node.uri.accept(this),
      // UriBasedDirective - Directive
      // Directive - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitExpressionFunctionBody(
      ExpressionFunctionBody node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ExpressionFunctionBody',
      'expression': node.expression.accept(this),
      // 'functionDefinition': InvalidType
      // 'semicolon': InvalidType
      // ExpressionFunctionBody - FunctionBody
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
      // 'keyword': InvalidType
      // 'star': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitExpressionStatement(ExpressionStatement node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ExpressionStatement',
      'expression': node.expression.accept(this),
      // 'semicolon': InvalidType
      // ExpressionStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitExtendsClause(ExtendsClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ExtendsClause', // 'extendsKeyword': InvalidType
      'superclass': node.superclass.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitExtensionDeclaration(ExtensionDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ExtensionDeclaration', // 'declaredElement': InvalidType
      'extendedType': node.extendedType.accept(this),
      // 'extensionKeyword': InvalidType
      // 'leftBracket': InvalidType
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      // 'name': InvalidType
      // 'onKeyword': InvalidType
      // 'rightBracket': InvalidType
      // 'typeKeyword': InvalidType
      if (node.typeParameters case var typeParameters?)
        'typeParameters': typeParameters.accept(this),
      // ExtensionDeclaration - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitExtensionOverride(ExtensionOverride node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ExtensionOverride',
      'argumentList': node.argumentList.accept(this),
      // 'element': InvalidType
      // 'extendedType': InvalidType
      if (node.importPrefix case var importPrefix?)
        'importPrefix': importPrefix.accept(this),
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      // 'name': InvalidType
      if (node.typeArguments case var typeArguments?)
        'typeArguments': typeArguments.accept(this),
      // 'typeArgumentTypes': List<InvalidType>?
      // ExtensionOverride - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitFieldDeclaration(FieldDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'FieldDeclaration', // 'abstractKeyword': InvalidType
      // 'covariantKeyword': InvalidType
      // 'externalKeyword': InvalidType
      'fields': node.fields.accept(this),
      if (node.isStatic) 'isStatic': node.isStatic,
      // 'semicolon': InvalidType
      // 'staticKeyword': InvalidType
      // FieldDeclaration - ClassMember
      // ClassMember - Declaration
      // 'declaredElement': InvalidType
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitFieldFormalParameter(FieldFormalParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'FieldFormalParameter', // 'keyword': InvalidType
      // 'name': InvalidType
      if (node.parameters case var parameters?)
        'parameters': parameters.accept(this),
      // 'period': InvalidType
      // 'question': InvalidType
      // 'thisKeyword': InvalidType
      if (node.typeParameters case var typeParameters?)
        'typeParameters': typeParameters.accept(this),
      // FieldFormalParameter - NormalFormalParameter
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
      // NormalFormalParameter - FormalParameter
      // 'covariantKeyword': InvalidType
      // 'declaredElement': InvalidType
      if (node.isConst) 'isConst': node.isConst,
      if (node.isExplicitlyTyped) 'isExplicitlyTyped': node.isExplicitlyTyped,
      if (node.isFinal) 'isFinal': node.isFinal,
      if (node.isNamed) 'isNamed': node.isNamed,
      if (node.isOptional) 'isOptional': node.isOptional,
      if (node.isOptionalNamed) 'isOptionalNamed': node.isOptionalNamed,
      if (node.isOptionalPositional)
        'isOptionalPositional': node.isOptionalPositional,
      if (node.isPositional) 'isPositional': node.isPositional,
      if (node.isRequired) 'isRequired': node.isRequired,
      if (node.isRequiredNamed) 'isRequiredNamed': node.isRequiredNamed,
      if (node.isRequiredPositional)
        'isRequiredPositional': node.isRequiredPositional,
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      // 'requiredKeyword': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitForEachPartsWithDeclaration(
      ForEachPartsWithDeclaration node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ForEachPartsWithDeclaration',
      'loopVariable': node.loopVariable.accept(this),
      // ForEachPartsWithDeclaration - ForEachParts
      // 'inKeyword': InvalidType
      'iterable': node.iterable.accept(this),
      // ForEachParts - ForLoopParts
    };
  }

  @override
  Map<String, Object?>? visitForEachPartsWithIdentifier(
      ForEachPartsWithIdentifier node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ForEachPartsWithIdentifier',
      'identifier': node.identifier.accept(this),
      // ForEachPartsWithIdentifier - ForEachParts
      // 'inKeyword': InvalidType
      'iterable': node.iterable.accept(this),
      // ForEachParts - ForLoopParts
    };
  }

  @override
  Map<String, Object?>? visitForEachPartsWithPattern(
      ForEachPartsWithPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ForEachPartsWithPattern', // 'keyword': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      'pattern': node.pattern.accept(this),
      // ForEachPartsWithPattern - ForEachParts
      // 'inKeyword': InvalidType
      'iterable': node.iterable.accept(this),
      // ForEachParts - ForLoopParts
    };
  }

  @override
  Map<String, Object?>? visitForElement(ForElement node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ForElement', // 'awaitKeyword': InvalidType
      'body': node.body.accept(this),
      // 'forKeyword': InvalidType
      'forLoopParts': node.forLoopParts.accept(this),
      // 'leftParenthesis': InvalidType
      // 'rightParenthesis': InvalidType
      // ForElement - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitFormalParameterList(FormalParameterList node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'FormalParameterList', // 'leftDelimiter': InvalidType
      // 'leftParenthesis': InvalidType
      // 'parameterElements': List<InvalidType>
      if (node.parameters.isNotEmpty)
        'parameters': <Map<String, Object?>?>[
          for (var item in node.parameters) item.accept(this),
        ],
      // 'rightDelimiter': InvalidType
      // 'rightParenthesis': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitForPartsWithDeclarations(
      ForPartsWithDeclarations node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ForPartsWithDeclarations',
      'variables': node.variables.accept(this),
      // ForPartsWithDeclarations - ForParts
      if (node.condition case var condition?)
        'condition': condition.accept(this),
      // 'leftSeparator': InvalidType
      // 'rightSeparator': InvalidType
      if (node.updaters.isNotEmpty)
        'updaters': <Map<String, Object?>?>[
          for (var item in node.updaters) item.accept(this),
        ],
      // ForParts - ForLoopParts
    };
  }

  @override
  Map<String, Object?>? visitForPartsWithExpression(
      ForPartsWithExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ForPartsWithExpression',
      if (node.initialization case var initialization?)
        'initialization': initialization.accept(this),
      // ForPartsWithExpression - ForParts
      if (node.condition case var condition?)
        'condition': condition.accept(this),
      // 'leftSeparator': InvalidType
      // 'rightSeparator': InvalidType
      if (node.updaters.isNotEmpty)
        'updaters': <Map<String, Object?>?>[
          for (var item in node.updaters) item.accept(this),
        ],
      // ForParts - ForLoopParts
    };
  }

  @override
  Map<String, Object?>? visitForPartsWithPattern(ForPartsWithPattern node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ForPartsWithPattern',
      'variables': node.variables.accept(this),
      // ForPartsWithPattern - ForParts
      if (node.condition case var condition?)
        'condition': condition.accept(this),
      // 'leftSeparator': InvalidType
      // 'rightSeparator': InvalidType
      if (node.updaters.isNotEmpty)
        'updaters': <Map<String, Object?>?>[
          for (var item in node.updaters) item.accept(this),
        ],
      // ForParts - ForLoopParts
    };
  }

  @override
  Map<String, Object?>? visitForStatement(ForStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ForStatement', // 'awaitKeyword': InvalidType
      'body': node.body.accept(this),
      // 'forKeyword': InvalidType
      'forLoopParts': node.forLoopParts.accept(this),
      // 'leftParenthesis': InvalidType
      // 'rightParenthesis': InvalidType
      // ForStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitFunctionDeclaration(FunctionDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'FunctionDeclaration', // 'declaredElement': InvalidType
      // 'externalKeyword': InvalidType
      'functionExpression': node.functionExpression.accept(this),
      if (node.isGetter) 'isGetter': node.isGetter,
      if (node.isSetter) 'isSetter': node.isSetter,
      // 'propertyKeyword': InvalidType
      if (node.returnType case var returnType?)
        'returnType': returnType.accept(this),
      // FunctionDeclaration - NamedCompilationUnitMember
      // 'name': InvalidType
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitFunctionDeclarationStatement(
      FunctionDeclarationStatement node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'FunctionDeclarationStatement',
      'functionDeclaration': node.functionDeclaration.accept(this),
      // FunctionDeclarationStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitFunctionExpression(FunctionExpression node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'FunctionExpression',
      'body': node.body.accept(this),
      // 'declaredElement': InvalidType
      if (node.parameters case var parameters?)
        'parameters': parameters.accept(this),
      if (node.typeParameters case var typeParameters?)
        'typeParameters': typeParameters.accept(this),
      // FunctionExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitFunctionExpressionInvocation(
      FunctionExpressionInvocation node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'FunctionExpressionInvocation',
      'function': node.function.accept(this),
      // 'staticElement': InvalidType
      // FunctionExpressionInvocation - NullShortableExpression
      // NullShortableExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // FunctionExpressionInvocation - InvocationExpression
      'argumentList': node.argumentList.accept(this),
      // 'staticInvokeType': InvalidType
      if (node.typeArguments case var typeArguments?)
        'typeArguments': typeArguments.accept(this),
      // 'typeArgumentTypes': List<InvalidType>?
      // InvocationExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitFunctionReference(FunctionReference node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'FunctionReference',
      'function': node.function.accept(this),
      if (node.typeArguments case var typeArguments?)
        'typeArguments': typeArguments.accept(this),
      // 'typeArgumentTypes': List<InvalidType>?
      // FunctionReference - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // FunctionReference - CommentReferableExpression
      // CommentReferableExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitFunctionTypeAlias(FunctionTypeAlias node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'FunctionTypeAlias', // 'declaredElement': InvalidType
      'parameters': node.parameters.accept(this),
      if (node.returnType case var returnType?)
        'returnType': returnType.accept(this),
      if (node.typeParameters case var typeParameters?)
        'typeParameters': typeParameters.accept(this),
      // FunctionTypeAlias - TypeAlias
      // 'semicolon': InvalidType
      // 'typedefKeyword': InvalidType
      // TypeAlias - NamedCompilationUnitMember
      // 'name': InvalidType
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitFunctionTypedFormalParameter(
      FunctionTypedFormalParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'FunctionTypedFormalParameter', // 'name': InvalidType
      'parameters': node.parameters.accept(this),
      // 'question': InvalidType
      if (node.returnType case var returnType?)
        'returnType': returnType.accept(this),
      if (node.typeParameters case var typeParameters?)
        'typeParameters': typeParameters.accept(this),
      // FunctionTypedFormalParameter - NormalFormalParameter
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
      // NormalFormalParameter - FormalParameter
      // 'covariantKeyword': InvalidType
      // 'declaredElement': InvalidType
      if (node.isConst) 'isConst': node.isConst,
      if (node.isExplicitlyTyped) 'isExplicitlyTyped': node.isExplicitlyTyped,
      if (node.isFinal) 'isFinal': node.isFinal,
      if (node.isNamed) 'isNamed': node.isNamed,
      if (node.isOptional) 'isOptional': node.isOptional,
      if (node.isOptionalNamed) 'isOptionalNamed': node.isOptionalNamed,
      if (node.isOptionalPositional)
        'isOptionalPositional': node.isOptionalPositional,
      if (node.isPositional) 'isPositional': node.isPositional,
      if (node.isRequired) 'isRequired': node.isRequired,
      if (node.isRequiredNamed) 'isRequiredNamed': node.isRequiredNamed,
      if (node.isRequiredPositional)
        'isRequiredPositional': node.isRequiredPositional,
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      // 'requiredKeyword': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitGenericFunctionType(GenericFunctionType node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'GenericFunctionType', // 'functionKeyword': InvalidType
      'parameters': node.parameters.accept(this),
      if (node.returnType case var returnType?)
        'returnType': returnType.accept(this),
      if (node.typeParameters case var typeParameters?)
        'typeParameters': typeParameters.accept(this),
      // GenericFunctionType - TypeAnnotation
      // 'question': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitGenericTypeAlias(GenericTypeAlias node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'GenericTypeAlias', // 'equals': InvalidType
      if (node.functionType case var functionType?)
        'functionType': functionType.accept(this),
      if (node.typeParameters case var typeParameters?)
        'typeParameters': typeParameters.accept(this),
      // GenericTypeAlias - TypeAlias
      // 'semicolon': InvalidType
      // 'typedefKeyword': InvalidType
      // TypeAlias - NamedCompilationUnitMember
      // 'name': InvalidType
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // 'declaredElement': InvalidType
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitGuardedPattern(GuardedPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'GuardedPattern',
      'pattern': node.pattern.accept(this),
      if (node.whenClause case var whenClause?)
        'whenClause': whenClause.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitHideCombinator(HideCombinator node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'HideCombinator',
      if (node.hiddenNames.isNotEmpty)
        'hiddenNames': <Map<String, Object?>?>[
          for (var item in node.hiddenNames) item.accept(this),
        ],
      // HideCombinator - Combinator
      // 'keyword': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitIfElement(IfElement node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'IfElement',
      if (node.caseClause case var caseClause?)
        'caseClause': caseClause.accept(this),
      if (node.elseElement case var elseElement?)
        'elseElement': elseElement.accept(this),
      // 'elseKeyword': InvalidType
      'expression': node.expression.accept(this),
      // 'ifKeyword': InvalidType
      // 'leftParenthesis': InvalidType
      // 'rightParenthesis': InvalidType
      'thenElement': node.thenElement.accept(this),
      // IfElement - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitIfStatement(IfStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'IfStatement',
      if (node.caseClause case var caseClause?)
        'caseClause': caseClause.accept(this),
      // 'elseKeyword': InvalidType
      if (node.elseStatement case var elseStatement?)
        'elseStatement': elseStatement.accept(this),
      'expression': node.expression.accept(this),
      // 'ifKeyword': InvalidType
      // 'leftParenthesis': InvalidType
      // 'rightParenthesis': InvalidType
      'thenStatement': node.thenStatement.accept(this),
      // IfStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitImplementsClause(ImplementsClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ImplementsClause', // 'implementsKeyword': InvalidType
      if (node.interfaces.isNotEmpty)
        'interfaces': <Map<String, Object?>?>[
          for (var item in node.interfaces) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitImplicitCallReference(ImplicitCallReference node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ImplicitCallReference',
      'expression': node.expression.accept(this),
      // 'staticElement': InvalidType
      if (node.typeArguments case var typeArguments?)
        'typeArguments': typeArguments.accept(this),
      // 'typeArgumentTypes': List<InvalidType>
      // ImplicitCallReference - MethodReferenceExpression
      // MethodReferenceExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitImportDirective(ImportDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ImportDirective', // 'asKeyword': InvalidType
      // 'deferredKeyword': InvalidType
      // 'element': InvalidType
      // 'importKeyword': InvalidType
      if (node.prefix case var prefix?) 'prefix': prefix.accept(this),
      // ImportDirective - NamespaceDirective
      if (node.combinators.isNotEmpty)
        'combinators': <Map<String, Object?>?>[
          for (var item in node.combinators) item.accept(this),
        ],
      if (node.configurations.isNotEmpty)
        'configurations': <Map<String, Object?>?>[
          for (var item in node.configurations) item.accept(this),
        ],
      // 'semicolon': InvalidType
      // NamespaceDirective - UriBasedDirective
      'uri': node.uri.accept(this),
      // UriBasedDirective - Directive
      // Directive - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitImportPrefixReference(ImportPrefixReference node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ImportPrefixReference', // 'element': InvalidType
      // 'name': InvalidType
      // 'period': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitIndexExpression(IndexExpression node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'IndexExpression',
      'index': node.index.accept(this),
      if (node.isCascaded) 'isCascaded': node.isCascaded,
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      // 'leftBracket': InvalidType
      // 'period': InvalidType
      // 'question': InvalidType
      'realTarget': node.realTarget.accept(this),
      // 'rightBracket': InvalidType
      if (node.target case var target?) 'target': target.accept(this),
      // IndexExpression - NullShortableExpression
      // NullShortableExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // IndexExpression - MethodReferenceExpression
      // 'staticElement': InvalidType
      // MethodReferenceExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitInstanceCreationExpression(
      InstanceCreationExpression node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'InstanceCreationExpression',
      'argumentList': node.argumentList.accept(this),
      'constructorName': node.constructorName.accept(this),
      if (node.isConst) 'isConst': node.isConst,
      // 'keyword': InvalidType
      // InstanceCreationExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitIntegerLiteral(IntegerLiteral node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'IntegerLiteral', // 'literal': InvalidType
      if (node.value case var value?) 'value': value,
      // IntegerLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitInterpolationExpression(
      InterpolationExpression node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'InterpolationExpression',
      'expression': node.expression.accept(this),
      // 'leftBracket': InvalidType
      // 'rightBracket': InvalidType
      // InterpolationExpression - InterpolationElement
    };
  }

  @override
  Map<String, Object?>? visitInterpolationString(InterpolationString node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'InterpolationString', // 'contents': InvalidType
      'contentsEnd': node.contentsEnd,
      'contentsOffset': node.contentsOffset,
      'value': node.value,
      // InterpolationString - InterpolationElement
    };
  }

  @override
  Map<String, Object?>? visitIsExpression(IsExpression node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'IsExpression',
      'expression': node.expression.accept(this),
      // 'isOperator': InvalidType
      // 'notOperator': InvalidType
      // IsExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitLabel(Label node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'Label', // 'colon': InvalidType
      'label': node.label.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitLabeledStatement(LabeledStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'LabeledStatement',
      if (node.labels.isNotEmpty)
        'labels': <Map<String, Object?>?>[
          for (var item in node.labels) item.accept(this),
        ],
      'statement': node.statement.accept(this),
      // LabeledStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitLibraryAugmentationDirective(
      LibraryAugmentationDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'LibraryAugmentationDirective', // 'augmentKeyword': InvalidType
      // 'libraryKeyword': InvalidType
      // 'semicolon': InvalidType
      // LibraryAugmentationDirective - UriBasedDirective
      'uri': node.uri.accept(this),
      // UriBasedDirective - Directive
      // 'element': InvalidType
      // Directive - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitLibraryDirective(LibraryDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'LibraryDirective', // 'libraryKeyword': InvalidType
      if (node.name2 case var name2?) 'name2': name2.accept(this),
      // 'semicolon': InvalidType
      // LibraryDirective - Directive
      // 'element': InvalidType
      // Directive - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitLibraryIdentifier(LibraryIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'LibraryIdentifier',
      if (node.components.isNotEmpty)
        'components': <Map<String, Object?>?>[
          for (var item in node.components) item.accept(this),
        ],
      // LibraryIdentifier - Identifier
      'name': node.name,
      // 'staticElement': InvalidType
      // Identifier - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // Identifier - CommentReferableExpression
      // CommentReferableExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitListLiteral(ListLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ListLiteral',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      // 'leftBracket': InvalidType
      // 'rightBracket': InvalidType
      // ListLiteral - TypedLiteral
      // 'constKeyword': InvalidType
      if (node.isConst) 'isConst': node.isConst,
      if (node.typeArguments case var typeArguments?)
        'typeArguments': typeArguments.accept(this),
      // TypedLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitListPattern(ListPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ListPattern',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      // 'leftBracket': InvalidType
      // 'requiredType': InvalidType
      // 'rightBracket': InvalidType
      if (node.typeArguments case var typeArguments?)
        'typeArguments': typeArguments.accept(this),
      // ListPattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitLogicalAndPattern(LogicalAndPattern node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'LogicalAndPattern',
      'leftOperand': node.leftOperand.accept(this),
      // 'operator': InvalidType
      'rightOperand': node.rightOperand.accept(this),
      // LogicalAndPattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitLogicalOrPattern(LogicalOrPattern node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'LogicalOrPattern',
      'leftOperand': node.leftOperand.accept(this),
      // 'operator': InvalidType
      'rightOperand': node.rightOperand.accept(this),
      // LogicalOrPattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitMapLiteralEntry(MapLiteralEntry node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'MapLiteralEntry',
      'key': node.key.accept(this),
      // 'separator': InvalidType
      'value': node.value.accept(this),
      // MapLiteralEntry - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitMapPattern(MapPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'MapPattern',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      // 'leftBracket': InvalidType
      // 'requiredType': InvalidType
      // 'rightBracket': InvalidType
      if (node.typeArguments case var typeArguments?)
        'typeArguments': typeArguments.accept(this),
      // MapPattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitMapPatternEntry(MapPatternEntry node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'MapPatternEntry',
      'key': node.key.accept(this),
      // 'separator': InvalidType
      'value': node.value.accept(this),
      // MapPatternEntry - MapPatternElement
    };
  }

  @override
  Map<String, Object?>? visitMethodDeclaration(MethodDeclaration node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'MethodDeclaration',
      'body': node.body.accept(this),
      // 'declaredElement': InvalidType
      // 'externalKeyword': InvalidType
      if (node.isAbstract) 'isAbstract': node.isAbstract,
      if (node.isGetter) 'isGetter': node.isGetter,
      if (node.isOperator) 'isOperator': node.isOperator,
      if (node.isSetter) 'isSetter': node.isSetter,
      if (node.isStatic) 'isStatic': node.isStatic,
      // 'modifierKeyword': InvalidType
      // 'name': InvalidType
      // 'operatorKeyword': InvalidType
      if (node.parameters case var parameters?)
        'parameters': parameters.accept(this),
      // 'propertyKeyword': InvalidType
      if (node.returnType case var returnType?)
        'returnType': returnType.accept(this),
      if (node.typeParameters case var typeParameters?)
        'typeParameters': typeParameters.accept(this),
      // MethodDeclaration - ClassMember
      // ClassMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitMethodInvocation(MethodInvocation node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'MethodInvocation',
      if (node.isCascaded) 'isCascaded': node.isCascaded,
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      'methodName': node.methodName.accept(this),
      // 'operator': InvalidType
      if (node.realTarget case var realTarget?)
        'realTarget': realTarget.accept(this),
      if (node.target case var target?) 'target': target.accept(this),
      // MethodInvocation - NullShortableExpression
      // NullShortableExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // MethodInvocation - InvocationExpression
      'argumentList': node.argumentList.accept(this),
      'function': node.function.accept(this),
      // 'staticInvokeType': InvalidType
      if (node.typeArguments case var typeArguments?)
        'typeArguments': typeArguments.accept(this),
      // 'typeArgumentTypes': List<InvalidType>?
      // InvocationExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitMixinDeclaration(MixinDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'MixinDeclaration', // 'declaredElement': InvalidType
      if (node.implementsClause case var implementsClause?)
        'implementsClause': implementsClause.accept(this),
      // 'leftBracket': InvalidType
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      // 'rightBracket': InvalidType
      if (node.typeParameters case var typeParameters?)
        'typeParameters': typeParameters.accept(this),
      // MixinDeclaration - MixinOrAugmentationDeclaration
      // 'baseKeyword': InvalidType
      // 'mixinKeyword': InvalidType
      if (node.onClause case var onClause?) 'onClause': onClause.accept(this),
      // MixinOrAugmentationDeclaration - NamedCompilationUnitMember
      // 'name': InvalidType
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitNamedExpression(NamedExpression node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'NamedExpression', // 'element': InvalidType
      'expression': node.expression.accept(this),
      'name': node.name.accept(this),
      // NamedExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitNamedType(NamedType node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'NamedType', // 'element': InvalidType
      if (node.importPrefix case var importPrefix?)
        'importPrefix': importPrefix.accept(this),
      if (node.isDeferred) 'isDeferred': node.isDeferred,
      // 'name2': InvalidType
      if (node.typeArguments case var typeArguments?)
        'typeArguments': typeArguments.accept(this),
      // NamedType - TypeAnnotation
      // 'question': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitNativeClause(NativeClause node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'NativeClause',
      if (node.name case var name?) 'name': name.accept(this),
      // 'nativeKeyword': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitNativeFunctionBody(NativeFunctionBody node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'NativeFunctionBody', // 'nativeKeyword': InvalidType
      // 'semicolon': InvalidType
      if (node.stringLiteral case var stringLiteral?)
        'stringLiteral': stringLiteral.accept(this),
      // NativeFunctionBody - FunctionBody
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
      // 'keyword': InvalidType
      // 'star': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitNullAssertPattern(NullAssertPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'NullAssertPattern', // 'operator': InvalidType
      'pattern': node.pattern.accept(this),
      // NullAssertPattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitNullCheckPattern(NullCheckPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'NullCheckPattern', // 'operator': InvalidType
      'pattern': node.pattern.accept(this),
      // NullCheckPattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitNullLiteral(NullLiteral node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'NullLiteral', // 'literal': InvalidType
      // NullLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitObjectPattern(ObjectPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ObjectPattern',
      if (node.fields.isNotEmpty)
        'fields': <Map<String, Object?>?>[
          for (var item in node.fields) item.accept(this),
        ],
      // 'leftParenthesis': InvalidType
      // 'rightParenthesis': InvalidType
      // ObjectPattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitOnClause(OnClause node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'OnClause', // 'onKeyword': InvalidType
      if (node.superclassConstraints.isNotEmpty)
        'superclassConstraints': <Map<String, Object?>?>[
          for (var item in node.superclassConstraints) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitParenthesizedExpression(
      ParenthesizedExpression node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ParenthesizedExpression',
      'expression': node.expression.accept(this),
      // 'leftParenthesis': InvalidType
      // 'rightParenthesis': InvalidType
      // ParenthesizedExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitParenthesizedPattern(ParenthesizedPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ParenthesizedPattern', // 'leftParenthesis': InvalidType
      'pattern': node.pattern.accept(this),
      // 'rightParenthesis': InvalidType
      // ParenthesizedPattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitPartDirective(PartDirective node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'PartDirective', // 'element': InvalidType
      // 'partKeyword': InvalidType
      // 'semicolon': InvalidType
      // PartDirective - UriBasedDirective
      'uri': node.uri.accept(this),
      // UriBasedDirective - Directive
      // Directive - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitPartOfDirective(PartOfDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'PartOfDirective',
      if (node.libraryName case var libraryName?)
        'libraryName': libraryName.accept(this),
      // 'ofKeyword': InvalidType
      // 'partKeyword': InvalidType
      // 'semicolon': InvalidType
      if (node.uri case var uri?) 'uri': uri.accept(this),
      // PartOfDirective - Directive
      // 'element': InvalidType
      // Directive - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitPatternAssignment(PatternAssignment node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'PatternAssignment', // 'equals': InvalidType
      'expression': node.expression.accept(this),
      'pattern': node.pattern.accept(this),
      // PatternAssignment - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitPatternField(PatternField node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'PatternField',
      if (node.effectiveName case var effectiveName?)
        'effectiveName': effectiveName,
      // 'element': InvalidType
      if (node.name case var name?) 'name': name.accept(this),
      'pattern': node.pattern.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitPatternFieldName(PatternFieldName node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'PatternFieldName', // 'colon': InvalidType
      // 'name': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitPatternVariableDeclaration(
      PatternVariableDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'PatternVariableDeclaration', // 'equals': InvalidType
      'expression': node.expression.accept(this),
      // 'keyword': InvalidType
      'pattern': node.pattern.accept(this),
      // PatternVariableDeclaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitPatternVariableDeclarationStatement(
      PatternVariableDeclarationStatement node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'PatternVariableDeclarationStatement',
      'declaration': node.declaration.accept(this),
      // 'semicolon': InvalidType
      // PatternVariableDeclarationStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitPostfixExpression(PostfixExpression node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'PostfixExpression',
      'operand': node.operand.accept(this),
      // 'operator': InvalidType
      // PostfixExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // PostfixExpression - NullShortableExpression
      // NullShortableExpression - Expression
      // Expression - CollectionElement
      // PostfixExpression - MethodReferenceExpression
      // 'staticElement': InvalidType
      // MethodReferenceExpression - Expression
      // Expression - CollectionElement
      // PostfixExpression - CompoundAssignmentExpression
      // 'readElement': InvalidType
      // 'readType': InvalidType
      // 'writeElement': InvalidType
      // 'writeType': InvalidType
      // CompoundAssignmentExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitPrefixedIdentifier(PrefixedIdentifier node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'PrefixedIdentifier',
      'identifier': node.identifier.accept(this),
      if (node.isDeferred) 'isDeferred': node.isDeferred,
      // 'period': InvalidType
      'prefix': node.prefix.accept(this),
      // PrefixedIdentifier - Identifier
      'name': node.name,
      // 'staticElement': InvalidType
      // Identifier - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // Identifier - CommentReferableExpression
      // CommentReferableExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitPrefixExpression(PrefixExpression node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'PrefixExpression',
      'operand': node.operand.accept(this),
      // 'operator': InvalidType
      // PrefixExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // PrefixExpression - NullShortableExpression
      // NullShortableExpression - Expression
      // Expression - CollectionElement
      // PrefixExpression - MethodReferenceExpression
      // 'staticElement': InvalidType
      // MethodReferenceExpression - Expression
      // Expression - CollectionElement
      // PrefixExpression - CompoundAssignmentExpression
      // 'readElement': InvalidType
      // 'readType': InvalidType
      // 'writeElement': InvalidType
      // 'writeType': InvalidType
      // CompoundAssignmentExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitPropertyAccess(PropertyAccess node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'PropertyAccess',
      if (node.isCascaded) 'isCascaded': node.isCascaded,
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      // 'operator': InvalidType
      'propertyName': node.propertyName.accept(this),
      'realTarget': node.realTarget.accept(this),
      if (node.target case var target?) 'target': target.accept(this),
      // PropertyAccess - NullShortableExpression
      // NullShortableExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // PropertyAccess - CommentReferableExpression
      // CommentReferableExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitRecordLiteral(RecordLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'RecordLiteral', // 'constKeyword': InvalidType
      if (node.fields.isNotEmpty)
        'fields': <Map<String, Object?>?>[
          for (var item in node.fields) item.accept(this),
        ],
      if (node.isConst) 'isConst': node.isConst,
      // 'leftParenthesis': InvalidType
      // 'rightParenthesis': InvalidType
      // RecordLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitRecordPattern(RecordPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'RecordPattern',
      if (node.fields.isNotEmpty)
        'fields': <Map<String, Object?>?>[
          for (var item in node.fields) item.accept(this),
        ],
      // 'leftParenthesis': InvalidType
      // 'rightParenthesis': InvalidType
      // RecordPattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitRecordTypeAnnotation(RecordTypeAnnotation node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'RecordTypeAnnotation', // 'leftParenthesis': InvalidType
      if (node.namedFields case var namedFields?)
        'namedFields': namedFields.accept(this),
      if (node.positionalFields.isNotEmpty)
        'positionalFields': <Map<String, Object?>?>[
          for (var item in node.positionalFields) item.accept(this),
        ],
      // 'rightParenthesis': InvalidType
      // RecordTypeAnnotation - TypeAnnotation
      // 'question': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitRecordTypeAnnotationNamedField(
      RecordTypeAnnotationNamedField node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'RecordTypeAnnotationNamedField', // 'name': InvalidType
      // RecordTypeAnnotationNamedField - RecordTypeAnnotationField
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitRecordTypeAnnotationNamedFields(
      RecordTypeAnnotationNamedFields node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'RecordTypeAnnotationNamedFields',
      if (node.fields.isNotEmpty)
        'fields': <Map<String, Object?>?>[
          for (var item in node.fields) item.accept(this),
        ],
      // 'leftBracket': InvalidType
      // 'rightBracket': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitRecordTypeAnnotationPositionalField(
      RecordTypeAnnotationPositionalField node) {
    return <String, Object?>{
      ...getLocation(node),
      'type':
          'RecordTypeAnnotationPositionalField', // RecordTypeAnnotationPositionalField - RecordTypeAnnotationField
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      // 'name': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitRedirectingConstructorInvocation(
      RedirectingConstructorInvocation node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'RedirectingConstructorInvocation',
      'argumentList': node.argumentList.accept(this),
      if (node.constructorName case var constructorName?)
        'constructorName': constructorName.accept(this),
      // 'period': InvalidType
      // 'thisKeyword': InvalidType
      // RedirectingConstructorInvocation - ConstructorInitializer
      // RedirectingConstructorInvocation - ConstructorReferenceNode
      // 'staticElement': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitRelationalPattern(RelationalPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'RelationalPattern', // 'element': InvalidType
      'operand': node.operand.accept(this),
      // 'operator': InvalidType
      // RelationalPattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitRestPatternElement(RestPatternElement node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'RestPatternElement', // 'operator': InvalidType
      if (node.pattern case var pattern?) 'pattern': pattern.accept(this),
      // RestPatternElement - ListPatternElement
      // RestPatternElement - MapPatternElement
    };
  }

  @override
  Map<String, Object?>? visitRethrowExpression(RethrowExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'RethrowExpression', // 'rethrowKeyword': InvalidType
      // RethrowExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitReturnStatement(ReturnStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ReturnStatement',
      if (node.expression case var expression?)
        'expression': expression.accept(this),
      // 'returnKeyword': InvalidType
      // 'semicolon': InvalidType
      // ReturnStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitScriptTag(ScriptTag node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ScriptTag', // 'scriptTag': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitSetOrMapLiteral(SetOrMapLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SetOrMapLiteral',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      if (node.isMap) 'isMap': node.isMap,
      if (node.isSet) 'isSet': node.isSet,
      // 'leftBracket': InvalidType
      // 'rightBracket': InvalidType
      // SetOrMapLiteral - TypedLiteral
      // 'constKeyword': InvalidType
      if (node.isConst) 'isConst': node.isConst,
      if (node.typeArguments case var typeArguments?)
        'typeArguments': typeArguments.accept(this),
      // TypedLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitShowCombinator(ShowCombinator node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ShowCombinator',
      if (node.shownNames.isNotEmpty)
        'shownNames': <Map<String, Object?>?>[
          for (var item in node.shownNames) item.accept(this),
        ],
      // ShowCombinator - Combinator
      // 'keyword': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitSimpleFormalParameter(SimpleFormalParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SimpleFormalParameter', // 'keyword': InvalidType
      // SimpleFormalParameter - NormalFormalParameter
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
      // NormalFormalParameter - FormalParameter
      // 'covariantKeyword': InvalidType
      // 'declaredElement': InvalidType
      if (node.isConst) 'isConst': node.isConst,
      if (node.isExplicitlyTyped) 'isExplicitlyTyped': node.isExplicitlyTyped,
      if (node.isFinal) 'isFinal': node.isFinal,
      if (node.isNamed) 'isNamed': node.isNamed,
      if (node.isOptional) 'isOptional': node.isOptional,
      if (node.isOptionalNamed) 'isOptionalNamed': node.isOptionalNamed,
      if (node.isOptionalPositional)
        'isOptionalPositional': node.isOptionalPositional,
      if (node.isPositional) 'isPositional': node.isPositional,
      if (node.isRequired) 'isRequired': node.isRequired,
      if (node.isRequiredNamed) 'isRequiredNamed': node.isRequiredNamed,
      if (node.isRequiredPositional)
        'isRequiredPositional': node.isRequiredPositional,
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      // 'name': InvalidType
      // 'requiredKeyword': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitSimpleIdentifier(SimpleIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      'type':
          'SimpleIdentifier', // 'tearOffTypeArgumentTypes': List<InvalidType>?
      // 'token': InvalidType
      // SimpleIdentifier - Identifier
      'name': node.name,
      // 'staticElement': InvalidType
      // Identifier - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // Identifier - CommentReferableExpression
      // CommentReferableExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitSimpleStringLiteral(SimpleStringLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SimpleStringLiteral', // 'literal': InvalidType
      'value': node.value,
      // SimpleStringLiteral - SingleStringLiteral
      'contentsEnd': node.contentsEnd,
      'contentsOffset': node.contentsOffset,
      if (node.isMultiline) 'isMultiline': node.isMultiline,
      if (node.isRaw) 'isRaw': node.isRaw,
      if (node.isSingleQuoted) 'isSingleQuoted': node.isSingleQuoted,
      // SingleStringLiteral - StringLiteral
      if (node.stringValue case var stringValue?) 'stringValue': stringValue,
      // StringLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitSpreadElement(SpreadElement node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'SpreadElement',
      'expression': node.expression.accept(this),
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      // 'spreadOperator': InvalidType
      // SpreadElement - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitStringInterpolation(StringInterpolation node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'StringInterpolation',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      'firstString': node.firstString.accept(this),
      'lastString': node.lastString.accept(this),
      // StringInterpolation - SingleStringLiteral
      'contentsEnd': node.contentsEnd,
      'contentsOffset': node.contentsOffset,
      if (node.isMultiline) 'isMultiline': node.isMultiline,
      if (node.isRaw) 'isRaw': node.isRaw,
      if (node.isSingleQuoted) 'isSingleQuoted': node.isSingleQuoted,
      // SingleStringLiteral - StringLiteral
      if (node.stringValue case var stringValue?) 'stringValue': stringValue,
      // StringLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitSuperConstructorInvocation(
      SuperConstructorInvocation node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'SuperConstructorInvocation',
      'argumentList': node.argumentList.accept(this),
      if (node.constructorName case var constructorName?)
        'constructorName': constructorName.accept(this),
      // 'period': InvalidType
      // 'superKeyword': InvalidType
      // SuperConstructorInvocation - ConstructorInitializer
      // SuperConstructorInvocation - ConstructorReferenceNode
      // 'staticElement': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitSuperExpression(SuperExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SuperExpression', // 'superKeyword': InvalidType
      // SuperExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitSuperFormalParameter(SuperFormalParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SuperFormalParameter', // 'keyword': InvalidType
      // 'name': InvalidType
      if (node.parameters case var parameters?)
        'parameters': parameters.accept(this),
      // 'period': InvalidType
      // 'question': InvalidType
      // 'superKeyword': InvalidType
      if (node.typeParameters case var typeParameters?)
        'typeParameters': typeParameters.accept(this),
      // SuperFormalParameter - NormalFormalParameter
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
      // NormalFormalParameter - FormalParameter
      // 'covariantKeyword': InvalidType
      // 'declaredElement': InvalidType
      if (node.isConst) 'isConst': node.isConst,
      if (node.isExplicitlyTyped) 'isExplicitlyTyped': node.isExplicitlyTyped,
      if (node.isFinal) 'isFinal': node.isFinal,
      if (node.isNamed) 'isNamed': node.isNamed,
      if (node.isOptional) 'isOptional': node.isOptional,
      if (node.isOptionalNamed) 'isOptionalNamed': node.isOptionalNamed,
      if (node.isOptionalPositional)
        'isOptionalPositional': node.isOptionalPositional,
      if (node.isPositional) 'isPositional': node.isPositional,
      if (node.isRequired) 'isRequired': node.isRequired,
      if (node.isRequiredNamed) 'isRequiredNamed': node.isRequiredNamed,
      if (node.isRequiredPositional)
        'isRequiredPositional': node.isRequiredPositional,
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      // 'requiredKeyword': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitSwitchCase(SwitchCase node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'SwitchCase',
      'expression': node.expression.accept(this),
      // SwitchCase - SwitchMember
      // 'colon': InvalidType
      // 'keyword': InvalidType
      if (node.labels.isNotEmpty)
        'labels': <Map<String, Object?>?>[
          for (var item in node.labels) item.accept(this),
        ],
      if (node.statements.isNotEmpty)
        'statements': <Map<String, Object?>?>[
          for (var item in node.statements) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitSwitchDefault(SwitchDefault node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SwitchDefault', // SwitchDefault - SwitchMember
      // 'colon': InvalidType
      // 'keyword': InvalidType
      if (node.labels.isNotEmpty)
        'labels': <Map<String, Object?>?>[
          for (var item in node.labels) item.accept(this),
        ],
      if (node.statements.isNotEmpty)
        'statements': <Map<String, Object?>?>[
          for (var item in node.statements) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitSwitchExpression(SwitchExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SwitchExpression',
      if (node.cases.isNotEmpty)
        'cases': <Map<String, Object?>?>[
          for (var item in node.cases) item.accept(this),
        ],
      'expression': node.expression.accept(this),
      // 'leftBracket': InvalidType
      // 'leftParenthesis': InvalidType
      // 'rightBracket': InvalidType
      // 'rightParenthesis': InvalidType
      // 'switchKeyword': InvalidType
      // SwitchExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitSwitchExpressionCase(SwitchExpressionCase node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SwitchExpressionCase', // 'arrow': InvalidType
      'expression': node.expression.accept(this),
      'guardedPattern': node.guardedPattern.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitSwitchPatternCase(SwitchPatternCase node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'SwitchPatternCase',
      'guardedPattern': node.guardedPattern.accept(this),
      // SwitchPatternCase - SwitchMember
      // 'colon': InvalidType
      // 'keyword': InvalidType
      if (node.labels.isNotEmpty)
        'labels': <Map<String, Object?>?>[
          for (var item in node.labels) item.accept(this),
        ],
      if (node.statements.isNotEmpty)
        'statements': <Map<String, Object?>?>[
          for (var item in node.statements) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitSwitchStatement(SwitchStatement node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'SwitchStatement',
      'expression': node.expression.accept(this),
      // 'leftBracket': InvalidType
      // 'leftParenthesis': InvalidType
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      // 'rightBracket': InvalidType
      // 'rightParenthesis': InvalidType
      // 'switchKeyword': InvalidType
      // SwitchStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitSymbolLiteral(SymbolLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'SymbolLiteral', // 'components': List<InvalidType>
      // 'poundSign': InvalidType
      // SymbolLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitThisExpression(ThisExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'ThisExpression', // 'thisKeyword': InvalidType
      // ThisExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitThrowExpression(ThrowExpression node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'ThrowExpression',
      'expression': node.expression.accept(this),
      // 'throwKeyword': InvalidType
      // ThrowExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitTopLevelVariableDeclaration(
      TopLevelVariableDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'TopLevelVariableDeclaration', // 'externalKeyword': InvalidType
      // 'semicolon': InvalidType
      'variables': node.variables.accept(this),
      // TopLevelVariableDeclaration - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // 'declaredElement': InvalidType
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitTryStatement(TryStatement node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'TryStatement',
      'body': node.body.accept(this),
      if (node.catchClauses.isNotEmpty)
        'catchClauses': <Map<String, Object?>?>[
          for (var item in node.catchClauses) item.accept(this),
        ],
      if (node.finallyBlock case var finallyBlock?)
        'finallyBlock': finallyBlock.accept(this),
      // 'finallyKeyword': InvalidType
      // 'tryKeyword': InvalidType
      // TryStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitTypeArgumentList(TypeArgumentList node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'TypeArgumentList',
      if (node.arguments.isNotEmpty)
        'arguments': <Map<String, Object?>?>[
          for (var item in node.arguments) item.accept(this),
        ],
      // 'leftBracket': InvalidType
      // 'rightBracket': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitTypeLiteral(TypeLiteral node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'TypeLiteral', // TypeLiteral - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': InvalidType
      // 'staticParameterElement': InvalidType
      // 'staticType': InvalidType
      // Expression - CollectionElement
      // TypeLiteral - CommentReferableExpression
      // CommentReferableExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitTypeParameter(TypeParameter node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'TypeParameter',
      if (node.bound case var bound?) 'bound': bound.accept(this),
      // 'declaredElement': InvalidType
      // 'extendsKeyword': InvalidType
      // 'name': InvalidType
      // TypeParameter - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitTypeParameterList(TypeParameterList node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'TypeParameterList', // 'leftBracket': InvalidType
      // 'rightBracket': InvalidType
      if (node.typeParameters.isNotEmpty)
        'typeParameters': <Map<String, Object?>?>[
          for (var item in node.typeParameters) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitVariableDeclaration(VariableDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'VariableDeclaration', // 'declaredElement': InvalidType
      // 'equals': InvalidType
      if (node.initializer case var initializer?)
        'initializer': initializer.accept(this),
      if (node.isConst) 'isConst': node.isConst,
      if (node.isFinal) 'isFinal': node.isFinal,
      if (node.isLate) 'isLate': node.isLate,
      // 'name': InvalidType
      // VariableDeclaration - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitVariableDeclarationList(
      VariableDeclarationList node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'VariableDeclarationList',
      if (node.isConst) 'isConst': node.isConst,
      if (node.isFinal) 'isFinal': node.isFinal,
      if (node.isLate) 'isLate': node.isLate,
      // 'keyword': InvalidType
      // 'lateKeyword': InvalidType
      if (node.variables.isNotEmpty)
        'variables': <Map<String, Object?>?>[
          for (var item in node.variables) item.accept(this),
        ],
      // VariableDeclarationList - AnnotatedNode
      if (node.documentationComment case var documentationComment?)
        'documentationComment': documentationComment.accept(this),
      // 'firstTokenAfterCommentAndMetadata': InvalidType
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitVariableDeclarationStatement(
      VariableDeclarationStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'VariableDeclarationStatement', // 'semicolon': InvalidType
      'variables': node.variables.accept(this),
      // VariableDeclarationStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitWhenClause(WhenClause node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'WhenClause',
      'expression': node.expression.accept(this),
      // 'whenKeyword': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitWhileStatement(WhileStatement node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'WhileStatement',
      'body': node.body.accept(this),
      'condition': node.condition.accept(this),
      // 'leftParenthesis': InvalidType
      // 'rightParenthesis': InvalidType
      // 'whileKeyword': InvalidType
      // WhileStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitWildcardPattern(WildcardPattern node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'WildcardPattern', // 'keyword': InvalidType
      // 'name': InvalidType
      // WildcardPattern - DartPattern
      // 'matchedValueType': InvalidType
      // 'precedence': InvalidType
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitWithClause(WithClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'type': 'WithClause',
      if (node.mixinTypes.isNotEmpty)
        'mixinTypes': <Map<String, Object?>?>[
          for (var item in node.mixinTypes) item.accept(this),
        ],
      // 'withKeyword': InvalidType
    };
  }

  @override
  Map<String, Object?>? visitYieldStatement(YieldStatement node) {
    return <String, Object?>{
      ...getLocation(node), 'type': 'YieldStatement',
      'expression': node.expression.accept(this),
      // 'semicolon': InvalidType
      // 'star': InvalidType
      // 'yieldKeyword': InvalidType
      // YieldStatement - Statement
    };
  }
}
