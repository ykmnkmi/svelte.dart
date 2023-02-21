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
      'class': 'AdjacentStrings',
      if (node.strings.isNotEmpty)
        'strings': <Map<String, Object?>?>[
          for (var item in node.strings) item.accept(this),
        ],
      // AdjacentStrings - StringLiteral
      if (node.stringValue != null) 'stringValue': node.stringValue!,
      // StringLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitAnnotation(Annotation node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'Annotation',
      if (node.arguments != null) 'arguments': node.arguments!.accept(this),
      // 'atSign': dynamic
      if (node.constructorName != null)
        'constructorName': node.constructorName!.accept(this),
      // 'element': dynamic
      // 'elementAnnotation': dynamic
      'name': node.name.accept(this),
      // 'period': dynamic
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitArgumentList(ArgumentList node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ArgumentList',
      if (node.arguments.isNotEmpty)
        'arguments': <Map<String, Object?>?>[
          for (var item in node.arguments) item.accept(this),
        ],
      // 'leftParenthesis': dynamic
      // 'rightParenthesis': dynamic
    };
  }

  @override
  Map<String, Object?>? visitAsExpression(AsExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AsExpression',
      // 'asOperator': dynamic
      'expression': node.expression.accept(this),
      'type': node.type.accept(this),
      // AsExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitAssertInitializer(AssertInitializer node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AssertInitializer',
      // AssertInitializer - Assertion
      // 'assertKeyword': dynamic
      // 'comma': dynamic
      'condition': node.condition.accept(this),
      // 'leftParenthesis': dynamic
      if (node.message != null) 'message': node.message!.accept(this),
      // 'rightParenthesis': dynamic
      // AssertInitializer - ConstructorInitializer
    };
  }

  @override
  Map<String, Object?>? visitAssertStatement(AssertStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AssertStatement',
      // 'semicolon': dynamic
      // AssertStatement - Assertion
      // 'assertKeyword': dynamic
      // 'comma': dynamic
      'condition': node.condition.accept(this),
      // 'leftParenthesis': dynamic
      if (node.message != null) 'message': node.message!.accept(this),
      // 'rightParenthesis': dynamic
      // AssertStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitAssignedVariablePattern(
      AssignedVariablePattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AssignedVariablePattern',
      // 'element': dynamic
      // AssignedVariablePattern - VariablePattern
      // 'name': dynamic
      // VariablePattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitAssignmentExpression(AssignmentExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AssignmentExpression',
      'leftHandSide': node.leftHandSide.accept(this),
      // 'operator': dynamic
      'rightHandSide': node.rightHandSide.accept(this),
      // AssignmentExpression - NullShortableExpression
      // NullShortableExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
      // AssignmentExpression - MethodReferenceExpression
      // 'staticElement': dynamic
      // MethodReferenceExpression - Expression
      // Expression - CollectionElement
      // AssignmentExpression - CompoundAssignmentExpression
      // 'readElement': dynamic
      // 'readType': dynamic
      // 'writeElement': dynamic
      // 'writeType': dynamic
      // CompoundAssignmentExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitAugmentationImportDirective(
      AugmentationImportDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AugmentationImportDirective',
      // 'augmentKeyword': dynamic
      // 'element': dynamic
      // 'importKeyword': dynamic
      // 'semicolon': dynamic
      // AugmentationImportDirective - UriBasedDirective
      'uri': node.uri.accept(this),
      // UriBasedDirective - Directive
      // Directive - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'AwaitExpression',
      // 'awaitKeyword': dynamic
      'expression': node.expression.accept(this),
      // AwaitExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitBinaryExpression(BinaryExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'BinaryExpression',
      'leftOperand': node.leftOperand.accept(this),
      // 'operator': dynamic
      'rightOperand': node.rightOperand.accept(this),
      // 'staticInvokeType': dynamic
      // BinaryExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
      // BinaryExpression - MethodReferenceExpression
      // 'staticElement': dynamic
      // MethodReferenceExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitBlock(Block node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'Block',
      // 'leftBracket': dynamic
      // 'rightBracket': dynamic
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
      ...getLocation(node),
      'class': 'BlockFunctionBody',
      'block': node.block.accept(this),
      // BlockFunctionBody - FunctionBody
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
      // 'keyword': dynamic
      // 'star': dynamic
    };
  }

  @override
  Map<String, Object?>? visitBooleanLiteral(BooleanLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'BooleanLiteral',
      // 'literal': dynamic
      if (node.value) 'value': node.value,
      // BooleanLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitBreakStatement(BreakStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'BreakStatement',
      // 'breakKeyword': dynamic
      if (node.label != null) 'label': node.label!.accept(this),
      // 'semicolon': dynamic
      if (node.target != null) 'target': node.target!.accept(this),
      // BreakStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitCascadeExpression(CascadeExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CascadeExpression',
      if (node.cascadeSections.isNotEmpty)
        'cascadeSections': <Map<String, Object?>?>[
          for (var item in node.cascadeSections) item.accept(this),
        ],
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      'target': node.target.accept(this),
      // CascadeExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
      // CascadeExpression - NullShortableExpression
      // NullShortableExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitCaseClause(CaseClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CaseClause',
      // 'caseKeyword': dynamic
      'guardedPattern': node.guardedPattern.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitCastPattern(CastPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CastPattern',
      // 'asToken': dynamic
      'pattern': node.pattern.accept(this),
      'type': node.type.accept(this),
      // CastPattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitCatchClause(CatchClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CatchClause',
      'body': node.body.accept(this),
      // 'catchKeyword': dynamic
      // 'comma': dynamic
      if (node.exceptionParameter != null)
        'exceptionParameter': node.exceptionParameter!.accept(this),
      if (node.exceptionType != null)
        'exceptionType': node.exceptionType!.accept(this),
      // 'leftParenthesis': dynamic
      // 'onKeyword': dynamic
      // 'rightParenthesis': dynamic
      if (node.stackTraceParameter != null)
        'stackTraceParameter': node.stackTraceParameter!.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitCatchClauseParameter(CatchClauseParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CatchClauseParameter',
      // 'declaredElement': dynamic
      // 'name': dynamic
    };
  }

  @override
  Map<String, Object?>? visitClassDeclaration(ClassDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ClassDeclaration',
      // 'declaredElement': dynamic
      if (node.implementsClause != null)
        'implementsClause': node.implementsClause!.accept(this),
      // 'leftBracket': dynamic
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      if (node.nativeClause != null)
        'nativeClause': node.nativeClause!.accept(this),
      // 'rightBracket': dynamic
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      // ClassDeclaration - ClassOrAugmentationDeclaration
      // 'abstractKeyword': dynamic
      // 'baseKeyword': dynamic
      // 'classKeyword': dynamic
      if (node.extendsClause != null)
        'extendsClause': node.extendsClause!.accept(this),
      // 'finalKeyword': dynamic
      // 'interfaceKeyword': dynamic
      // 'mixinKeyword': dynamic
      // 'sealedKeyword': dynamic
      if (node.withClause != null) 'withClause': node.withClause!.accept(this),
      // ClassOrAugmentationDeclaration - NamedCompilationUnitMember
      // 'name': dynamic
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'ClassTypeAlias',
      // 'abstractKeyword': dynamic
      // 'baseKeyword': dynamic
      // 'declaredElement': dynamic
      // 'equals': dynamic
      // 'finalKeyword': dynamic
      if (node.implementsClause != null)
        'implementsClause': node.implementsClause!.accept(this),
      // 'interfaceKeyword': dynamic
      // 'mixinKeyword': dynamic
      // 'sealedKeyword': dynamic
      'superclass': node.superclass.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      'withClause': node.withClause.accept(this),
      // ClassTypeAlias - TypeAlias
      // 'semicolon': dynamic
      // 'typedefKeyword': dynamic
      // TypeAlias - NamedCompilationUnitMember
      // 'name': dynamic
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      ...getLocation(node),
      'class': 'Comment',
      if (node.isBlock) 'isBlock': node.isBlock,
      if (node.isDocumentation) 'isDocumentation': node.isDocumentation,
      if (node.isEndOfLine) 'isEndOfLine': node.isEndOfLine,
      if (node.references.isNotEmpty)
        'references': <Map<String, Object?>?>[
          for (var item in node.references) item.accept(this),
        ],
      // 'tokens': List<dynamic>
    };
  }

  @override
  Map<String, Object?>? visitCommentReference(CommentReference node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CommentReference',
      'expression': node.expression.accept(this),
      // 'newKeyword': dynamic
    };
  }

  @override
  Map<String, Object?>? visitCompilationUnit(CompilationUnit node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CompilationUnit',
      if (node.declarations.isNotEmpty)
        'declarations': <Map<String, Object?>?>[
          for (var item in node.declarations) item.accept(this),
        ],
      // 'declaredElement': dynamic
      if (node.directives.isNotEmpty)
        'directives': <Map<String, Object?>?>[
          for (var item in node.directives) item.accept(this),
        ],
      // 'featureSet': dynamic
      // 'languageVersionToken': dynamic
      // 'lineInfo': dynamic
      if (node.scriptTag != null) 'scriptTag': node.scriptTag!.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitConditionalExpression(ConditionalExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ConditionalExpression',
      // 'colon': dynamic
      'condition': node.condition.accept(this),
      'elseExpression': node.elseExpression.accept(this),
      // 'question': dynamic
      'thenExpression': node.thenExpression.accept(this),
      // ConditionalExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitConfiguration(Configuration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'Configuration',
      // 'equalToken': dynamic
      // 'ifKeyword': dynamic
      // 'leftParenthesis': dynamic
      'name': node.name.accept(this),
      // 'resolvedUri': dynamic
      // 'rightParenthesis': dynamic
      'uri': node.uri.accept(this),
      if (node.value != null) 'value': node.value!.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitConstantPattern(ConstantPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ConstantPattern',
      // 'constKeyword': dynamic
      'expression': node.expression.accept(this),
      // ConstantPattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitConstructorDeclaration(
      ConstructorDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ConstructorDeclaration',
      'body': node.body.accept(this),
      // 'constKeyword': dynamic
      // 'declaredElement': dynamic
      // 'externalKeyword': dynamic
      // 'factoryKeyword': dynamic
      if (node.initializers.isNotEmpty)
        'initializers': <Map<String, Object?>?>[
          for (var item in node.initializers) item.accept(this),
        ],
      // 'name': dynamic
      'parameters': node.parameters.accept(this),
      // 'period': dynamic
      if (node.redirectedConstructor != null)
        'redirectedConstructor': node.redirectedConstructor!.accept(this),
      'returnType': node.returnType.accept(this),
      // 'separator': dynamic
      // ConstructorDeclaration - ClassMember
      // ClassMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'ConstructorFieldInitializer',
      // 'equals': dynamic
      'expression': node.expression.accept(this),
      'fieldName': node.fieldName.accept(this),
      // 'period': dynamic
      // 'thisKeyword': dynamic
      // ConstructorFieldInitializer - ConstructorInitializer
    };
  }

  @override
  Map<String, Object?>? visitConstructorName(ConstructorName node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ConstructorName',
      if (node.name != null) 'name': node.name!.accept(this),
      // 'period': dynamic
      'type': node.type.accept(this),
      // ConstructorName - ConstructorReferenceNode
      // 'staticElement': dynamic
    };
  }

  @override
  Map<String, Object?>? visitConstructorReference(ConstructorReference node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ConstructorReference',
      'constructorName': node.constructorName.accept(this),
      // ConstructorReference - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
      // ConstructorReference - CommentReferableExpression
      // CommentReferableExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitConstructorSelector(ConstructorSelector node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ConstructorSelector',
      'name': node.name.accept(this),
      // 'period': dynamic
    };
  }

  @override
  Map<String, Object?>? visitContinueStatement(ContinueStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ContinueStatement',
      // 'continueKeyword': dynamic
      if (node.label != null) 'label': node.label!.accept(this),
      // 'semicolon': dynamic
      if (node.target != null) 'target': node.target!.accept(this),
      // ContinueStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitDeclaredIdentifier(DeclaredIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'DeclaredIdentifier',
      // 'declaredElement': dynamic
      if (node.isConst) 'isConst': node.isConst,
      if (node.isFinal) 'isFinal': node.isFinal,
      // 'keyword': dynamic
      // 'name': dynamic
      if (node.type != null) 'type': node.type!.accept(this),
      // DeclaredIdentifier - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'DeclaredVariablePattern',
      // 'declaredElement': dynamic
      // 'keyword': dynamic
      if (node.type != null) 'type': node.type!.accept(this),
      // DeclaredVariablePattern - VariablePattern
      // 'name': dynamic
      // VariablePattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitDefaultFormalParameter(
      DefaultFormalParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'DefaultFormalParameter',
      if (node.defaultValue != null)
        'defaultValue': node.defaultValue!.accept(this),
      'parameter': node.parameter.accept(this),
      // 'separator': dynamic
      // DefaultFormalParameter - FormalParameter
      // 'covariantKeyword': dynamic
      // 'declaredElement': dynamic
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
      // 'name': dynamic
      // 'requiredKeyword': dynamic
    };
  }

  @override
  Map<String, Object?>? visitDoStatement(DoStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'DoStatement',
      'body': node.body.accept(this),
      'condition': node.condition.accept(this),
      // 'doKeyword': dynamic
      // 'leftParenthesis': dynamic
      // 'rightParenthesis': dynamic
      // 'semicolon': dynamic
      // 'whileKeyword': dynamic
      // DoStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitDottedName(DottedName node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'DottedName',
      if (node.components.isNotEmpty)
        'components': <Map<String, Object?>?>[
          for (var item in node.components) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitDoubleLiteral(DoubleLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'DoubleLiteral',
      // 'literal': dynamic
      'value': node.value,
      // DoubleLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitEmptyFunctionBody(EmptyFunctionBody node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'EmptyFunctionBody',
      // 'semicolon': dynamic
      // EmptyFunctionBody - FunctionBody
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
      // 'keyword': dynamic
      // 'star': dynamic
    };
  }

  @override
  Map<String, Object?>? visitEmptyStatement(EmptyStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'EmptyStatement',
      // 'semicolon': dynamic
      // EmptyStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitEnumConstantArguments(EnumConstantArguments node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'EnumConstantArguments',
      'argumentList': node.argumentList.accept(this),
      if (node.constructorSelector != null)
        'constructorSelector': node.constructorSelector!.accept(this),
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitEnumConstantDeclaration(
      EnumConstantDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'EnumConstantDeclaration',
      if (node.arguments != null) 'arguments': node.arguments!.accept(this),
      // 'constructorElement': dynamic
      // 'name': dynamic
      // EnumConstantDeclaration - Declaration
      // 'declaredElement': dynamic
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'EnumDeclaration',
      if (node.constants.isNotEmpty)
        'constants': <Map<String, Object?>?>[
          for (var item in node.constants) item.accept(this),
        ],
      // 'declaredElement': dynamic
      // 'enumKeyword': dynamic
      if (node.implementsClause != null)
        'implementsClause': node.implementsClause!.accept(this),
      // 'leftBracket': dynamic
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      // 'rightBracket': dynamic
      // 'semicolon': dynamic
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      if (node.withClause != null) 'withClause': node.withClause!.accept(this),
      // EnumDeclaration - NamedCompilationUnitMember
      // 'name': dynamic
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      ...getLocation(node),
      'class': 'ExportDirective',
      // 'element': dynamic
      // 'exportKeyword': dynamic
      // ExportDirective - NamespaceDirective
      if (node.combinators.isNotEmpty)
        'combinators': <Map<String, Object?>?>[
          for (var item in node.combinators) item.accept(this),
        ],
      if (node.configurations.isNotEmpty)
        'configurations': <Map<String, Object?>?>[
          for (var item in node.configurations) item.accept(this),
        ],
      // 'semicolon': dynamic
      // NamespaceDirective - UriBasedDirective
      'uri': node.uri.accept(this),
      // UriBasedDirective - Directive
      // Directive - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      ...getLocation(node),
      'class': 'ExpressionFunctionBody',
      'expression': node.expression.accept(this),
      // 'functionDefinition': dynamic
      // 'semicolon': dynamic
      // ExpressionFunctionBody - FunctionBody
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
      // 'keyword': dynamic
      // 'star': dynamic
    };
  }

  @override
  Map<String, Object?>? visitExpressionStatement(ExpressionStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ExpressionStatement',
      'expression': node.expression.accept(this),
      // 'semicolon': dynamic
      // ExpressionStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitExtendsClause(ExtendsClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ExtendsClause',
      // 'extendsKeyword': dynamic
      'superclass': node.superclass.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitExtensionDeclaration(ExtensionDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ExtensionDeclaration',
      // 'declaredElement': dynamic
      'extendedType': node.extendedType.accept(this),
      // 'extensionKeyword': dynamic
      // 'leftBracket': dynamic
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      // 'name': dynamic
      // 'onKeyword': dynamic
      // 'rightBracket': dynamic
      // 'typeKeyword': dynamic
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      // ExtensionDeclaration - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      ...getLocation(node),
      'class': 'ExtensionOverride',
      'argumentList': node.argumentList.accept(this),
      // 'extendedType': dynamic
      'extensionName': node.extensionName.accept(this),
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      // 'staticElement': dynamic
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
      // 'typeArgumentTypes': List<dynamic>?
      // ExtensionOverride - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitFieldDeclaration(FieldDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FieldDeclaration',
      // 'abstractKeyword': dynamic
      // 'covariantKeyword': dynamic
      // 'externalKeyword': dynamic
      'fields': node.fields.accept(this),
      if (node.isStatic) 'isStatic': node.isStatic,
      // 'semicolon': dynamic
      // 'staticKeyword': dynamic
      // FieldDeclaration - ClassMember
      // ClassMember - Declaration
      // 'declaredElement': dynamic
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'FieldFormalParameter',
      // 'keyword': dynamic
      // 'name': dynamic
      if (node.parameters != null) 'parameters': node.parameters!.accept(this),
      // 'period': dynamic
      // 'question': dynamic
      // 'thisKeyword': dynamic
      if (node.type != null) 'type': node.type!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      // FieldFormalParameter - NormalFormalParameter
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
      // NormalFormalParameter - FormalParameter
      // 'covariantKeyword': dynamic
      // 'declaredElement': dynamic
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
      // 'requiredKeyword': dynamic
    };
  }

  @override
  Map<String, Object?>? visitForEachPartsWithDeclaration(
      ForEachPartsWithDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ForEachPartsWithDeclaration',
      'loopVariable': node.loopVariable.accept(this),
      // ForEachPartsWithDeclaration - ForEachParts
      // 'inKeyword': dynamic
      'iterable': node.iterable.accept(this),
      // ForEachParts - ForLoopParts
    };
  }

  @override
  Map<String, Object?>? visitForEachPartsWithIdentifier(
      ForEachPartsWithIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ForEachPartsWithIdentifier',
      'identifier': node.identifier.accept(this),
      // ForEachPartsWithIdentifier - ForEachParts
      // 'inKeyword': dynamic
      'iterable': node.iterable.accept(this),
      // ForEachParts - ForLoopParts
    };
  }

  @override
  Map<String, Object?>? visitForEachPartsWithPattern(
      ForEachPartsWithPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ForEachPartsWithPattern',
      // 'keyword': dynamic
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      'pattern': node.pattern.accept(this),
      // ForEachPartsWithPattern - ForEachParts
      // 'inKeyword': dynamic
      'iterable': node.iterable.accept(this),
      // ForEachParts - ForLoopParts
    };
  }

  @override
  Map<String, Object?>? visitForElement(ForElement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ForElement',
      // 'awaitKeyword': dynamic
      'body': node.body.accept(this),
      // 'forKeyword': dynamic
      'forLoopParts': node.forLoopParts.accept(this),
      // 'leftParenthesis': dynamic
      // 'rightParenthesis': dynamic
      // ForElement - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitFormalParameterList(FormalParameterList node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FormalParameterList',
      // 'leftDelimiter': dynamic
      // 'leftParenthesis': dynamic
      // 'parameterElements': List<dynamic>
      if (node.parameters.isNotEmpty)
        'parameters': <Map<String, Object?>?>[
          for (var item in node.parameters) item.accept(this),
        ],
      // 'rightDelimiter': dynamic
      // 'rightParenthesis': dynamic
    };
  }

  @override
  Map<String, Object?>? visitForPartsWithDeclarations(
      ForPartsWithDeclarations node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ForPartsWithDeclarations',
      'variables': node.variables.accept(this),
      // ForPartsWithDeclarations - ForParts
      if (node.condition != null) 'condition': node.condition!.accept(this),
      // 'leftSeparator': dynamic
      // 'rightSeparator': dynamic
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
      'class': 'ForPartsWithExpression',
      if (node.initialization != null)
        'initialization': node.initialization!.accept(this),
      // ForPartsWithExpression - ForParts
      if (node.condition != null) 'condition': node.condition!.accept(this),
      // 'leftSeparator': dynamic
      // 'rightSeparator': dynamic
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
      ...getLocation(node),
      'class': 'ForPartsWithPattern',
      'variables': node.variables.accept(this),
      // ForPartsWithPattern - ForParts
      if (node.condition != null) 'condition': node.condition!.accept(this),
      // 'leftSeparator': dynamic
      // 'rightSeparator': dynamic
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
      'class': 'ForStatement',
      // 'awaitKeyword': dynamic
      'body': node.body.accept(this),
      // 'forKeyword': dynamic
      'forLoopParts': node.forLoopParts.accept(this),
      // 'leftParenthesis': dynamic
      // 'rightParenthesis': dynamic
      // ForStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitFunctionDeclaration(FunctionDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FunctionDeclaration',
      // 'declaredElement': dynamic
      // 'externalKeyword': dynamic
      'functionExpression': node.functionExpression.accept(this),
      if (node.isGetter) 'isGetter': node.isGetter,
      if (node.isSetter) 'isSetter': node.isSetter,
      // 'propertyKeyword': dynamic
      if (node.returnType != null) 'returnType': node.returnType!.accept(this),
      // FunctionDeclaration - NamedCompilationUnitMember
      // 'name': dynamic
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      ...getLocation(node),
      'class': 'FunctionDeclarationStatement',
      'functionDeclaration': node.functionDeclaration.accept(this),
      // FunctionDeclarationStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitFunctionExpression(FunctionExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FunctionExpression',
      'body': node.body.accept(this),
      // 'declaredElement': dynamic
      if (node.parameters != null) 'parameters': node.parameters!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      // FunctionExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitFunctionExpressionInvocation(
      FunctionExpressionInvocation node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FunctionExpressionInvocation',
      'function': node.function.accept(this),
      // 'staticElement': dynamic
      // FunctionExpressionInvocation - NullShortableExpression
      // NullShortableExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
      // FunctionExpressionInvocation - InvocationExpression
      'argumentList': node.argumentList.accept(this),
      // 'staticInvokeType': dynamic
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
      // 'typeArgumentTypes': List<dynamic>?
      // InvocationExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitFunctionReference(FunctionReference node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FunctionReference',
      'function': node.function.accept(this),
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
      // 'typeArgumentTypes': List<dynamic>?
      // FunctionReference - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
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
      'class': 'FunctionTypeAlias',
      // 'declaredElement': dynamic
      'parameters': node.parameters.accept(this),
      if (node.returnType != null) 'returnType': node.returnType!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      // FunctionTypeAlias - TypeAlias
      // 'semicolon': dynamic
      // 'typedefKeyword': dynamic
      // TypeAlias - NamedCompilationUnitMember
      // 'name': dynamic
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'FunctionTypedFormalParameter',
      // 'name': dynamic
      'parameters': node.parameters.accept(this),
      // 'question': dynamic
      if (node.returnType != null) 'returnType': node.returnType!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      // FunctionTypedFormalParameter - NormalFormalParameter
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
      // NormalFormalParameter - FormalParameter
      // 'covariantKeyword': dynamic
      // 'declaredElement': dynamic
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
      // 'requiredKeyword': dynamic
    };
  }

  @override
  Map<String, Object?>? visitGenericFunctionType(GenericFunctionType node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'GenericFunctionType',
      // 'functionKeyword': dynamic
      'parameters': node.parameters.accept(this),
      if (node.returnType != null) 'returnType': node.returnType!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      // GenericFunctionType - TypeAnnotation
      // 'question': dynamic
      // 'type': dynamic
    };
  }

  @override
  Map<String, Object?>? visitGenericTypeAlias(GenericTypeAlias node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'GenericTypeAlias',
      // 'equals': dynamic
      if (node.functionType != null)
        'functionType': node.functionType!.accept(this),
      'type': node.type.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      // GenericTypeAlias - TypeAlias
      // 'semicolon': dynamic
      // 'typedefKeyword': dynamic
      // TypeAlias - NamedCompilationUnitMember
      // 'name': dynamic
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // 'declaredElement': dynamic
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'GuardedPattern',
      'pattern': node.pattern.accept(this),
      if (node.whenClause != null) 'whenClause': node.whenClause!.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitHideCombinator(HideCombinator node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'HideCombinator',
      if (node.hiddenNames.isNotEmpty)
        'hiddenNames': <Map<String, Object?>?>[
          for (var item in node.hiddenNames) item.accept(this),
        ],
      // HideCombinator - Combinator
      // 'keyword': dynamic
    };
  }

  @override
  Map<String, Object?>? visitIfElement(IfElement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'IfElement',
      if (node.caseClause != null) 'caseClause': node.caseClause!.accept(this),
      'condition': node.condition.accept(this),
      if (node.elseElement != null)
        'elseElement': node.elseElement!.accept(this),
      // 'elseKeyword': dynamic
      'expression': node.expression.accept(this),
      // 'ifKeyword': dynamic
      // 'leftParenthesis': dynamic
      // 'rightParenthesis': dynamic
      'thenElement': node.thenElement.accept(this),
      // IfElement - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitIfStatement(IfStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'IfStatement',
      if (node.caseClause != null) 'caseClause': node.caseClause!.accept(this),
      'condition': node.condition.accept(this),
      // 'elseKeyword': dynamic
      if (node.elseStatement != null)
        'elseStatement': node.elseStatement!.accept(this),
      'expression': node.expression.accept(this),
      // 'ifKeyword': dynamic
      // 'leftParenthesis': dynamic
      // 'rightParenthesis': dynamic
      'thenStatement': node.thenStatement.accept(this),
      // IfStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitImplementsClause(ImplementsClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ImplementsClause',
      // 'implementsKeyword': dynamic
      if (node.interfaces.isNotEmpty)
        'interfaces': <Map<String, Object?>?>[
          for (var item in node.interfaces) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?>? visitImplicitCallReference(ImplicitCallReference node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ImplicitCallReference',
      'expression': node.expression.accept(this),
      // 'staticElement': dynamic
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
      // 'typeArgumentTypes': List<dynamic>
      // ImplicitCallReference - MethodReferenceExpression
      // MethodReferenceExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitImportDirective(ImportDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ImportDirective',
      // 'asKeyword': dynamic
      // 'deferredKeyword': dynamic
      // 'element': dynamic
      // 'importKeyword': dynamic
      if (node.prefix != null) 'prefix': node.prefix!.accept(this),
      // ImportDirective - NamespaceDirective
      if (node.combinators.isNotEmpty)
        'combinators': <Map<String, Object?>?>[
          for (var item in node.combinators) item.accept(this),
        ],
      if (node.configurations.isNotEmpty)
        'configurations': <Map<String, Object?>?>[
          for (var item in node.configurations) item.accept(this),
        ],
      // 'semicolon': dynamic
      // NamespaceDirective - UriBasedDirective
      'uri': node.uri.accept(this),
      // UriBasedDirective - Directive
      // Directive - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
  Map<String, Object?>? visitIndexExpression(IndexExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'IndexExpression',
      'index': node.index.accept(this),
      if (node.isCascaded) 'isCascaded': node.isCascaded,
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      // 'leftBracket': dynamic
      // 'period': dynamic
      // 'question': dynamic
      'realTarget': node.realTarget.accept(this),
      // 'rightBracket': dynamic
      if (node.target != null) 'target': node.target!.accept(this),
      // IndexExpression - NullShortableExpression
      // NullShortableExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
      // IndexExpression - MethodReferenceExpression
      // 'staticElement': dynamic
      // MethodReferenceExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitInstanceCreationExpression(
      InstanceCreationExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'InstanceCreationExpression',
      'argumentList': node.argumentList.accept(this),
      'constructorName': node.constructorName.accept(this),
      if (node.isConst) 'isConst': node.isConst,
      // 'keyword': dynamic
      // InstanceCreationExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitIntegerLiteral(IntegerLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'IntegerLiteral',
      // 'literal': dynamic
      if (node.value != null) 'value': node.value!,
      // IntegerLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitInterpolationExpression(
      InterpolationExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'InterpolationExpression',
      'expression': node.expression.accept(this),
      // 'leftBracket': dynamic
      // 'rightBracket': dynamic
      // InterpolationExpression - InterpolationElement
    };
  }

  @override
  Map<String, Object?>? visitInterpolationString(InterpolationString node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'InterpolationString',
      // 'contents': dynamic
      'contentsEnd': node.contentsEnd,
      'contentsOffset': node.contentsOffset,
      'value': node.value,
      // InterpolationString - InterpolationElement
    };
  }

  @override
  Map<String, Object?>? visitIsExpression(IsExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'IsExpression',
      'expression': node.expression.accept(this),
      // 'isOperator': dynamic
      // 'notOperator': dynamic
      'type': node.type.accept(this),
      // IsExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitLabel(Label node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'Label',
      // 'colon': dynamic
      'label': node.label.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitLabeledStatement(LabeledStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'LabeledStatement',
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
      'class': 'LibraryAugmentationDirective',
      // 'augmentKeyword': dynamic
      // 'libraryKeyword': dynamic
      // 'semicolon': dynamic
      // LibraryAugmentationDirective - UriBasedDirective
      'uri': node.uri.accept(this),
      // UriBasedDirective - Directive
      // 'element': dynamic
      // Directive - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'LibraryDirective',
      // 'libraryKeyword': dynamic
      if (node.name2 != null) 'name2': node.name2!.accept(this),
      // 'semicolon': dynamic
      // LibraryDirective - Directive
      // 'element': dynamic
      // Directive - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'LibraryIdentifier',
      if (node.components.isNotEmpty)
        'components': <Map<String, Object?>?>[
          for (var item in node.components) item.accept(this),
        ],
      // LibraryIdentifier - Identifier
      'name': node.name,
      // 'staticElement': dynamic
      // Identifier - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
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
      'class': 'ListLiteral',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      // 'leftBracket': dynamic
      // 'rightBracket': dynamic
      // ListLiteral - TypedLiteral
      // 'constKeyword': dynamic
      if (node.isConst) 'isConst': node.isConst,
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
      // TypedLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitListPattern(ListPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ListPattern',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      // 'leftBracket': dynamic
      // 'requiredType': dynamic
      // 'rightBracket': dynamic
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
      // ListPattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitLogicalAndPattern(LogicalAndPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'LogicalAndPattern',
      'leftOperand': node.leftOperand.accept(this),
      // 'operator': dynamic
      'rightOperand': node.rightOperand.accept(this),
      // LogicalAndPattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitLogicalOrPattern(LogicalOrPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'LogicalOrPattern',
      'leftOperand': node.leftOperand.accept(this),
      // 'operator': dynamic
      'rightOperand': node.rightOperand.accept(this),
      // LogicalOrPattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitMapLiteralEntry(MapLiteralEntry node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'MapLiteralEntry',
      'key': node.key.accept(this),
      // 'separator': dynamic
      'value': node.value.accept(this),
      // MapLiteralEntry - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitMapPattern(MapPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'MapPattern',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      // 'leftBracket': dynamic
      // 'requiredType': dynamic
      // 'rightBracket': dynamic
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
      // MapPattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitMapPatternEntry(MapPatternEntry node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'MapPatternEntry',
      'key': node.key.accept(this),
      // 'separator': dynamic
      'value': node.value.accept(this),
      // MapPatternEntry - MapPatternElement
    };
  }

  @override
  Map<String, Object?>? visitMethodDeclaration(MethodDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'MethodDeclaration',
      'body': node.body.accept(this),
      // 'declaredElement': dynamic
      // 'externalKeyword': dynamic
      if (node.isAbstract) 'isAbstract': node.isAbstract,
      if (node.isGetter) 'isGetter': node.isGetter,
      if (node.isOperator) 'isOperator': node.isOperator,
      if (node.isSetter) 'isSetter': node.isSetter,
      if (node.isStatic) 'isStatic': node.isStatic,
      // 'modifierKeyword': dynamic
      // 'name': dynamic
      // 'operatorKeyword': dynamic
      if (node.parameters != null) 'parameters': node.parameters!.accept(this),
      // 'propertyKeyword': dynamic
      if (node.returnType != null) 'returnType': node.returnType!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      // MethodDeclaration - ClassMember
      // ClassMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      ...getLocation(node),
      'class': 'MethodInvocation',
      if (node.isCascaded) 'isCascaded': node.isCascaded,
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      'methodName': node.methodName.accept(this),
      // 'operator': dynamic
      if (node.realTarget != null) 'realTarget': node.realTarget!.accept(this),
      if (node.target != null) 'target': node.target!.accept(this),
      // MethodInvocation - NullShortableExpression
      // NullShortableExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
      // MethodInvocation - InvocationExpression
      'argumentList': node.argumentList.accept(this),
      'function': node.function.accept(this),
      // 'staticInvokeType': dynamic
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
      // 'typeArgumentTypes': List<dynamic>?
      // InvocationExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitMixinDeclaration(MixinDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'MixinDeclaration',
      // 'declaredElement': dynamic
      if (node.implementsClause != null)
        'implementsClause': node.implementsClause!.accept(this),
      // 'leftBracket': dynamic
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      // 'rightBracket': dynamic
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      // MixinDeclaration - MixinOrAugmentationDeclaration
      // 'baseKeyword': dynamic
      // 'finalKeyword': dynamic
      // 'interfaceKeyword': dynamic
      // 'mixinKeyword': dynamic
      if (node.onClause != null) 'onClause': node.onClause!.accept(this),
      // 'sealedKeyword': dynamic
      // MixinOrAugmentationDeclaration - NamedCompilationUnitMember
      // 'name': dynamic
      // NamedCompilationUnitMember - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      ...getLocation(node),
      'class': 'NamedExpression',
      // 'element': dynamic
      'expression': node.expression.accept(this),
      'name': node.name.accept(this),
      // NamedExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitNamedType(NamedType node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'NamedType',
      if (node.isDeferred) 'isDeferred': node.isDeferred,
      'name': node.name.accept(this),
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
      // NamedType - TypeAnnotation
      // 'question': dynamic
      // 'type': dynamic
    };
  }

  @override
  Map<String, Object?>? visitNativeClause(NativeClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'NativeClause',
      if (node.name != null) 'name': node.name!.accept(this),
      // 'nativeKeyword': dynamic
    };
  }

  @override
  Map<String, Object?>? visitNativeFunctionBody(NativeFunctionBody node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'NativeFunctionBody',
      // 'nativeKeyword': dynamic
      // 'semicolon': dynamic
      if (node.stringLiteral != null)
        'stringLiteral': node.stringLiteral!.accept(this),
      // NativeFunctionBody - FunctionBody
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
      // 'keyword': dynamic
      // 'star': dynamic
    };
  }

  @override
  Map<String, Object?>? visitNullAssertPattern(NullAssertPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'NullAssertPattern',
      // 'operator': dynamic
      'pattern': node.pattern.accept(this),
      // NullAssertPattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitNullCheckPattern(NullCheckPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'NullCheckPattern',
      // 'operator': dynamic
      'pattern': node.pattern.accept(this),
      // NullCheckPattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitNullLiteral(NullLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'NullLiteral',
      // 'literal': dynamic
      // NullLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitObjectPattern(ObjectPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ObjectPattern',
      if (node.fields.isNotEmpty)
        'fields': <Map<String, Object?>?>[
          for (var item in node.fields) item.accept(this),
        ],
      // 'leftParenthesis': dynamic
      // 'rightParenthesis': dynamic
      'type': node.type.accept(this),
      // ObjectPattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitOnClause(OnClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'OnClause',
      // 'onKeyword': dynamic
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
      ...getLocation(node),
      'class': 'ParenthesizedExpression',
      'expression': node.expression.accept(this),
      // 'leftParenthesis': dynamic
      // 'rightParenthesis': dynamic
      // ParenthesizedExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitParenthesizedPattern(ParenthesizedPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ParenthesizedPattern',
      // 'leftParenthesis': dynamic
      'pattern': node.pattern.accept(this),
      // 'rightParenthesis': dynamic
      // ParenthesizedPattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitPartDirective(PartDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PartDirective',
      // 'element': dynamic
      // 'partKeyword': dynamic
      // 'semicolon': dynamic
      // PartDirective - UriBasedDirective
      'uri': node.uri.accept(this),
      // UriBasedDirective - Directive
      // Directive - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'PartOfDirective',
      if (node.libraryName != null)
        'libraryName': node.libraryName!.accept(this),
      // 'ofKeyword': dynamic
      // 'partKeyword': dynamic
      // 'semicolon': dynamic
      if (node.uri != null) 'uri': node.uri!.accept(this),
      // PartOfDirective - Directive
      // 'element': dynamic
      // Directive - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'PatternAssignment',
      // 'equals': dynamic
      'expression': node.expression.accept(this),
      'pattern': node.pattern.accept(this),
      // PatternAssignment - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitPatternField(PatternField node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PatternField',
      // 'element': dynamic
      if (node.name != null) 'name': node.name!.accept(this),
      'pattern': node.pattern.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitPatternFieldName(PatternFieldName node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PatternFieldName',
      // 'colon': dynamic
      // 'name': dynamic
    };
  }

  @override
  Map<String, Object?>? visitPatternVariableDeclaration(
      PatternVariableDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PatternVariableDeclaration',
      // 'equals': dynamic
      'expression': node.expression.accept(this),
      // 'keyword': dynamic
      'pattern': node.pattern.accept(this),
      // PatternVariableDeclaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      ...getLocation(node),
      'class': 'PatternVariableDeclarationStatement',
      'declaration': node.declaration.accept(this),
      // 'semicolon': dynamic
      // PatternVariableDeclarationStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitPostfixExpression(PostfixExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PostfixExpression',
      'operand': node.operand.accept(this),
      // 'operator': dynamic
      // PostfixExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
      // PostfixExpression - NullShortableExpression
      // NullShortableExpression - Expression
      // Expression - CollectionElement
      // PostfixExpression - MethodReferenceExpression
      // 'staticElement': dynamic
      // MethodReferenceExpression - Expression
      // Expression - CollectionElement
      // PostfixExpression - CompoundAssignmentExpression
      // 'readElement': dynamic
      // 'readType': dynamic
      // 'writeElement': dynamic
      // 'writeType': dynamic
      // CompoundAssignmentExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitPrefixedIdentifier(PrefixedIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PrefixedIdentifier',
      'identifier': node.identifier.accept(this),
      if (node.isDeferred) 'isDeferred': node.isDeferred,
      // 'period': dynamic
      'prefix': node.prefix.accept(this),
      // PrefixedIdentifier - Identifier
      'name': node.name,
      // 'staticElement': dynamic
      // Identifier - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
      // Identifier - CommentReferableExpression
      // CommentReferableExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitPrefixExpression(PrefixExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PrefixExpression',
      'operand': node.operand.accept(this),
      // 'operator': dynamic
      // PrefixExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
      // PrefixExpression - NullShortableExpression
      // NullShortableExpression - Expression
      // Expression - CollectionElement
      // PrefixExpression - MethodReferenceExpression
      // 'staticElement': dynamic
      // MethodReferenceExpression - Expression
      // Expression - CollectionElement
      // PrefixExpression - CompoundAssignmentExpression
      // 'readElement': dynamic
      // 'readType': dynamic
      // 'writeElement': dynamic
      // 'writeType': dynamic
      // CompoundAssignmentExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitPropertyAccess(PropertyAccess node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PropertyAccess',
      if (node.isCascaded) 'isCascaded': node.isCascaded,
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      // 'operator': dynamic
      'propertyName': node.propertyName.accept(this),
      'realTarget': node.realTarget.accept(this),
      if (node.target != null) 'target': node.target!.accept(this),
      // PropertyAccess - NullShortableExpression
      // NullShortableExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
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
      'class': 'RecordLiteral',
      // 'constKeyword': dynamic
      if (node.fields.isNotEmpty)
        'fields': <Map<String, Object?>?>[
          for (var item in node.fields) item.accept(this),
        ],
      if (node.isConst) 'isConst': node.isConst,
      // 'leftParenthesis': dynamic
      // 'rightParenthesis': dynamic
      // RecordLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitRecordPattern(RecordPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RecordPattern',
      if (node.fields.isNotEmpty)
        'fields': <Map<String, Object?>?>[
          for (var item in node.fields) item.accept(this),
        ],
      // 'leftParenthesis': dynamic
      // 'rightParenthesis': dynamic
      // RecordPattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitRecordTypeAnnotation(RecordTypeAnnotation node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RecordTypeAnnotation',
      // 'leftParenthesis': dynamic
      if (node.namedFields != null)
        'namedFields': node.namedFields!.accept(this),
      if (node.positionalFields.isNotEmpty)
        'positionalFields': <Map<String, Object?>?>[
          for (var item in node.positionalFields) item.accept(this),
        ],
      // 'rightParenthesis': dynamic
      // RecordTypeAnnotation - TypeAnnotation
      // 'question': dynamic
      // 'type': dynamic
    };
  }

  @override
  Map<String, Object?>? visitRecordTypeAnnotationNamedField(
      RecordTypeAnnotationNamedField node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RecordTypeAnnotationNamedField',
      // 'name': dynamic
      // RecordTypeAnnotationNamedField - RecordTypeAnnotationField
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      'type': node.type.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitRecordTypeAnnotationNamedFields(
      RecordTypeAnnotationNamedFields node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RecordTypeAnnotationNamedFields',
      if (node.fields.isNotEmpty)
        'fields': <Map<String, Object?>?>[
          for (var item in node.fields) item.accept(this),
        ],
      // 'leftBracket': dynamic
      // 'rightBracket': dynamic
    };
  }

  @override
  Map<String, Object?>? visitRecordTypeAnnotationPositionalField(
      RecordTypeAnnotationPositionalField node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RecordTypeAnnotationPositionalField',
      // RecordTypeAnnotationPositionalField - RecordTypeAnnotationField
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      // 'name': dynamic
      'type': node.type.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitRedirectingConstructorInvocation(
      RedirectingConstructorInvocation node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RedirectingConstructorInvocation',
      'argumentList': node.argumentList.accept(this),
      if (node.constructorName != null)
        'constructorName': node.constructorName!.accept(this),
      // 'period': dynamic
      // 'thisKeyword': dynamic
      // RedirectingConstructorInvocation - ConstructorInitializer
      // RedirectingConstructorInvocation - ConstructorReferenceNode
      // 'staticElement': dynamic
    };
  }

  @override
  Map<String, Object?>? visitRelationalPattern(RelationalPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RelationalPattern',
      // 'element': dynamic
      'operand': node.operand.accept(this),
      // 'operator': dynamic
      // RelationalPattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitRestPatternElement(RestPatternElement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RestPatternElement',
      // 'operator': dynamic
      if (node.pattern != null) 'pattern': node.pattern!.accept(this),
      // RestPatternElement - ListPatternElement
      // RestPatternElement - MapPatternElement
    };
  }

  @override
  Map<String, Object?>? visitRethrowExpression(RethrowExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RethrowExpression',
      // 'rethrowKeyword': dynamic
      // RethrowExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitReturnStatement(ReturnStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ReturnStatement',
      if (node.expression != null) 'expression': node.expression!.accept(this),
      // 'returnKeyword': dynamic
      // 'semicolon': dynamic
      // ReturnStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitScriptTag(ScriptTag node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ScriptTag',
      // 'scriptTag': dynamic
    };
  }

  @override
  Map<String, Object?>? visitSetOrMapLiteral(SetOrMapLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SetOrMapLiteral',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      if (node.isMap) 'isMap': node.isMap,
      if (node.isSet) 'isSet': node.isSet,
      // 'leftBracket': dynamic
      // 'rightBracket': dynamic
      // SetOrMapLiteral - TypedLiteral
      // 'constKeyword': dynamic
      if (node.isConst) 'isConst': node.isConst,
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
      // TypedLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitShowCombinator(ShowCombinator node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ShowCombinator',
      if (node.shownNames.isNotEmpty)
        'shownNames': <Map<String, Object?>?>[
          for (var item in node.shownNames) item.accept(this),
        ],
      // ShowCombinator - Combinator
      // 'keyword': dynamic
    };
  }

  @override
  Map<String, Object?>? visitSimpleFormalParameter(SimpleFormalParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SimpleFormalParameter',
      // 'keyword': dynamic
      if (node.type != null) 'type': node.type!.accept(this),
      // SimpleFormalParameter - NormalFormalParameter
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
      // NormalFormalParameter - FormalParameter
      // 'covariantKeyword': dynamic
      // 'declaredElement': dynamic
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
      // 'name': dynamic
      // 'requiredKeyword': dynamic
    };
  }

  @override
  Map<String, Object?>? visitSimpleIdentifier(SimpleIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SimpleIdentifier',
      // 'tearOffTypeArgumentTypes': List<dynamic>?
      // 'token': dynamic
      // SimpleIdentifier - Identifier
      'name': node.name,
      // 'staticElement': dynamic
      // Identifier - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
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
      'class': 'SimpleStringLiteral',
      // 'literal': dynamic
      'value': node.value,
      // SimpleStringLiteral - SingleStringLiteral
      'contentsEnd': node.contentsEnd,
      'contentsOffset': node.contentsOffset,
      if (node.isMultiline) 'isMultiline': node.isMultiline,
      if (node.isRaw) 'isRaw': node.isRaw,
      if (node.isSingleQuoted) 'isSingleQuoted': node.isSingleQuoted,
      // SingleStringLiteral - StringLiteral
      if (node.stringValue != null) 'stringValue': node.stringValue!,
      // StringLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitSpreadElement(SpreadElement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SpreadElement',
      'expression': node.expression.accept(this),
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      // 'spreadOperator': dynamic
      // SpreadElement - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitStringInterpolation(StringInterpolation node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'StringInterpolation',
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
      if (node.stringValue != null) 'stringValue': node.stringValue!,
      // StringLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitSuperConstructorInvocation(
      SuperConstructorInvocation node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SuperConstructorInvocation',
      'argumentList': node.argumentList.accept(this),
      if (node.constructorName != null)
        'constructorName': node.constructorName!.accept(this),
      // 'period': dynamic
      // 'superKeyword': dynamic
      // SuperConstructorInvocation - ConstructorInitializer
      // SuperConstructorInvocation - ConstructorReferenceNode
      // 'staticElement': dynamic
    };
  }

  @override
  Map<String, Object?>? visitSuperExpression(SuperExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SuperExpression',
      // 'superKeyword': dynamic
      // SuperExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitSuperFormalParameter(SuperFormalParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SuperFormalParameter',
      // 'keyword': dynamic
      // 'name': dynamic
      if (node.parameters != null) 'parameters': node.parameters!.accept(this),
      // 'period': dynamic
      // 'question': dynamic
      // 'superKeyword': dynamic
      if (node.type != null) 'type': node.type!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      // SuperFormalParameter - NormalFormalParameter
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      if (node.sortedCommentAndAnnotations.isNotEmpty)
        'sortedCommentAndAnnotations': <Map<String, Object?>?>[
          for (var item in node.sortedCommentAndAnnotations) item.accept(this),
        ],
      // NormalFormalParameter - FormalParameter
      // 'covariantKeyword': dynamic
      // 'declaredElement': dynamic
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
      // 'requiredKeyword': dynamic
    };
  }

  @override
  Map<String, Object?>? visitSwitchCase(SwitchCase node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SwitchCase',
      'expression': node.expression.accept(this),
      // SwitchCase - SwitchMember
      // 'colon': dynamic
      // 'keyword': dynamic
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
      'class': 'SwitchDefault',
      // SwitchDefault - SwitchMember
      // 'colon': dynamic
      // 'keyword': dynamic
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
      'class': 'SwitchExpression',
      if (node.cases.isNotEmpty)
        'cases': <Map<String, Object?>?>[
          for (var item in node.cases) item.accept(this),
        ],
      'expression': node.expression.accept(this),
      // 'leftBracket': dynamic
      // 'leftParenthesis': dynamic
      // 'rightBracket': dynamic
      // 'rightParenthesis': dynamic
      // 'switchKeyword': dynamic
      // SwitchExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitSwitchExpressionCase(SwitchExpressionCase node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SwitchExpressionCase',
      // 'arrow': dynamic
      'expression': node.expression.accept(this),
      'guardedPattern': node.guardedPattern.accept(this),
    };
  }

  @override
  Map<String, Object?>? visitSwitchPatternCase(SwitchPatternCase node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SwitchPatternCase',
      'guardedPattern': node.guardedPattern.accept(this),
      // SwitchPatternCase - SwitchMember
      // 'colon': dynamic
      // 'keyword': dynamic
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
      ...getLocation(node),
      'class': 'SwitchStatement',
      'expression': node.expression.accept(this),
      // 'leftBracket': dynamic
      // 'leftParenthesis': dynamic
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      // 'rightBracket': dynamic
      // 'rightParenthesis': dynamic
      // 'switchKeyword': dynamic
      // SwitchStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitSymbolLiteral(SymbolLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SymbolLiteral',
      // 'components': List<dynamic>
      // 'poundSign': dynamic
      // SymbolLiteral - Literal
      // Literal - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitThisExpression(ThisExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ThisExpression',
      // 'thisKeyword': dynamic
      // ThisExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitThrowExpression(ThrowExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ThrowExpression',
      'expression': node.expression.accept(this),
      // 'throwKeyword': dynamic
      // ThrowExpression - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitTopLevelVariableDeclaration(
      TopLevelVariableDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'TopLevelVariableDeclaration',
      // 'externalKeyword': dynamic
      // 'semicolon': dynamic
      'variables': node.variables.accept(this),
      // TopLevelVariableDeclaration - CompilationUnitMember
      // CompilationUnitMember - Declaration
      // 'declaredElement': dynamic
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      ...getLocation(node),
      'class': 'TryStatement',
      'body': node.body.accept(this),
      if (node.catchClauses.isNotEmpty)
        'catchClauses': <Map<String, Object?>?>[
          for (var item in node.catchClauses) item.accept(this),
        ],
      if (node.finallyBlock != null)
        'finallyBlock': node.finallyBlock!.accept(this),
      // 'finallyKeyword': dynamic
      // 'tryKeyword': dynamic
      // TryStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitTypeArgumentList(TypeArgumentList node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'TypeArgumentList',
      if (node.arguments.isNotEmpty)
        'arguments': <Map<String, Object?>?>[
          for (var item in node.arguments) item.accept(this),
        ],
      // 'leftBracket': dynamic
      // 'rightBracket': dynamic
    };
  }

  @override
  Map<String, Object?>? visitTypeLiteral(TypeLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'TypeLiteral',
      'type': node.type.accept(this),
      // TypeLiteral - Expression
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
      // 'precedence': dynamic
      // 'staticParameterElement': dynamic
      // 'staticType': dynamic
      // Expression - CollectionElement
      // TypeLiteral - CommentReferableExpression
      // CommentReferableExpression - Expression
      // Expression - CollectionElement
    };
  }

  @override
  Map<String, Object?>? visitTypeParameter(TypeParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'TypeParameter',
      if (node.bound != null) 'bound': node.bound!.accept(this),
      // 'declaredElement': dynamic
      // 'extendsKeyword': dynamic
      // 'name': dynamic
      // TypeParameter - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'TypeParameterList',
      // 'leftBracket': dynamic
      // 'rightBracket': dynamic
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
      'class': 'VariableDeclaration',
      // 'declaredElement': dynamic
      // 'equals': dynamic
      if (node.initializer != null)
        'initializer': node.initializer!.accept(this),
      if (node.isConst) 'isConst': node.isConst,
      if (node.isFinal) 'isFinal': node.isFinal,
      if (node.isLate) 'isLate': node.isLate,
      // 'name': dynamic
      // VariableDeclaration - Declaration
      // Declaration - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      ...getLocation(node),
      'class': 'VariableDeclarationList',
      if (node.isConst) 'isConst': node.isConst,
      if (node.isFinal) 'isFinal': node.isFinal,
      if (node.isLate) 'isLate': node.isLate,
      // 'keyword': dynamic
      // 'lateKeyword': dynamic
      if (node.type != null) 'type': node.type!.accept(this),
      if (node.variables.isNotEmpty)
        'variables': <Map<String, Object?>?>[
          for (var item in node.variables) item.accept(this),
        ],
      // VariableDeclarationList - AnnotatedNode
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      // 'firstTokenAfterCommentAndMetadata': dynamic
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
      'class': 'VariableDeclarationStatement',
      // 'semicolon': dynamic
      'variables': node.variables.accept(this),
      // VariableDeclarationStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitWhenClause(WhenClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'WhenClause',
      'expression': node.expression.accept(this),
      // 'whenKeyword': dynamic
    };
  }

  @override
  Map<String, Object?>? visitWhileStatement(WhileStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'WhileStatement',
      'body': node.body.accept(this),
      'condition': node.condition.accept(this),
      // 'leftParenthesis': dynamic
      // 'rightParenthesis': dynamic
      // 'whileKeyword': dynamic
      // WhileStatement - Statement
    };
  }

  @override
  Map<String, Object?>? visitWildcardPattern(WildcardPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'WildcardPattern',
      // 'keyword': dynamic
      // 'name': dynamic
      if (node.type != null) 'type': node.type!.accept(this),
      // WildcardPattern - DartPattern
      // 'matchedValueType': dynamic
      // 'precedence': dynamic
      // DartPattern - ListPatternElement
    };
  }

  @override
  Map<String, Object?>? visitWithClause(WithClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'WithClause',
      if (node.mixinTypes.isNotEmpty)
        'mixinTypes': <Map<String, Object?>?>[
          for (var item in node.mixinTypes) item.accept(this),
        ],
      // 'withKeyword': dynamic
    };
  }

  @override
  Map<String, Object?>? visitYieldStatement(YieldStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'YieldStatement',
      'expression': node.expression.accept(this),
      // 'semicolon': dynamic
      // 'star': dynamic
      // 'yieldKeyword': dynamic
      // YieldStatement - Statement
    };
  }
}
