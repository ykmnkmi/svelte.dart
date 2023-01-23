// generated with `tools/generate_script_to_json.dart`
// ignore_for_file: depend_on_referenced_packages

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

Map<String, Object?> describeToken(Token token) {
  return <String, Object?>{
    'start': token.offset,
    'end': token.end,
    'type': token.type.name,
    'lexeme': token.lexeme,
  };
}

class DartToJsonVisitor extends ThrowingAstVisitor<Map<String, Object?>> {
  const DartToJsonVisitor();

  Map<String, Object?> getLocation(AstNode node) {
    return <String, Object?>{
      'start': node.offset,
      'end': node.end,
    };
  }

  List<Map<String, Object?>?> visitAll(List<AstNode> nodes) {
    return <Map<String, Object?>?>[for (var node in nodes) node.accept(this)];
  }

  @override
  Map<String, Object?> visitAdjacentStrings(AdjacentStrings node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AdjacentStrings',
      if (node.strings.isNotEmpty)
        'strings': <Map<String, Object?>?>[
          for (var item in node.strings) item.accept(this),
        ],
      if (node.stringValue != null) 'stringValue': node.stringValue!,
    };
  }

  @override
  Map<String, Object?> visitAnnotation(Annotation node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'Annotation',
      if (node.arguments != null) 'arguments': node.arguments!.accept(this),
      if (node.constructorName != null)
        'constructorName': node.constructorName!.accept(this),
      'name': node.name.accept(this),
      'parent': node.parent.accept(this),
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitArgumentList(ArgumentList node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ArgumentList',
      if (node.arguments.isNotEmpty)
        'arguments': <Map<String, Object?>?>[
          for (var item in node.arguments) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitAsExpression(AsExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AsExpression',
      'expression': node.expression.accept(this),
      'type': node.type.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitAssertInitializer(AssertInitializer node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AssertInitializer',
      'condition': node.condition.accept(this),
      if (node.message != null) 'message': node.message!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitAssertStatement(AssertStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AssertStatement',
      'condition': node.condition.accept(this),
      if (node.message != null) 'message': node.message!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitAssignedVariablePattern(
      AssignedVariablePattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AssignedVariablePattern',
    };
  }

  @override
  Map<String, Object?> visitAssignmentExpression(AssignmentExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AssignmentExpression',
      'leftHandSide': node.leftHandSide.accept(this),
      'rightHandSide': node.rightHandSide.accept(this),
    };
  }

  @override
  Map<String, Object?> visitAugmentationImportDirective(
      AugmentationImportDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AugmentationImportDirective',
      'uri': node.uri.accept(this),
    };
  }

  @override
  Map<String, Object?> visitAwaitExpression(AwaitExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'AwaitExpression',
      'expression': node.expression.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitBinaryExpression(BinaryExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'BinaryExpression',
      'leftOperand': node.leftOperand.accept(this),
      'rightOperand': node.rightOperand.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitBinaryPattern(BinaryPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'BinaryPattern',
      'leftOperand': node.leftOperand.accept(this),
      'rightOperand': node.rightOperand.accept(this),
    };
  }

  @override
  Map<String, Object?> visitBlock(Block node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'Block',
      if (node.statements.isNotEmpty)
        'statements': <Map<String, Object?>?>[
          for (var item in node.statements) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitBlockFunctionBody(BlockFunctionBody node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'BlockFunctionBody',
      'block': node.block.accept(this),
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
    };
  }

  @override
  Map<String, Object?> visitBooleanLiteral(BooleanLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'BooleanLiteral',
      if (node.value) 'value': node.value,
    };
  }

  @override
  Map<String, Object?> visitBreakStatement(BreakStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'BreakStatement',
      if (node.label != null) 'label': node.label!.accept(this),
      if (node.target != null) 'target': node.target!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitCascadeExpression(CascadeExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CascadeExpression',
      if (node.cascadeSections.isNotEmpty)
        'cascadeSections': <Map<String, Object?>?>[
          for (var item in node.cascadeSections) item.accept(this),
        ],
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      'target': node.target.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitCaseClause(CaseClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CaseClause',
      'guardedPattern': node.guardedPattern.accept(this),
    };
  }

  @override
  Map<String, Object?> visitCastPattern(CastPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CastPattern',
      'pattern': node.pattern.accept(this),
      'type': node.type.accept(this),
    };
  }

  @override
  Map<String, Object?> visitCatchClause(CatchClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CatchClause',
      'body': node.body.accept(this),
      if (node.exceptionParameter != null)
        'exceptionParameter': node.exceptionParameter!.accept(this),
      if (node.exceptionType != null)
        'exceptionType': node.exceptionType!.accept(this),
      if (node.stackTraceParameter != null)
        'stackTraceParameter': node.stackTraceParameter!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitCatchClauseParameter(CatchClauseParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CatchClauseParameter',
    };
  }

  @override
  Map<String, Object?> visitClassDeclaration(ClassDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ClassDeclaration',
      if (node.implementsClause != null)
        'implementsClause': node.implementsClause!.accept(this),
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      if (node.nativeClause != null)
        'nativeClause': node.nativeClause!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      if (node.extendsClause != null)
        'extendsClause': node.extendsClause!.accept(this),
      if (node.withClause != null) 'withClause': node.withClause!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitClassTypeAlias(ClassTypeAlias node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ClassTypeAlias',
      if (node.implementsClause != null)
        'implementsClause': node.implementsClause!.accept(this),
      'superclass': node.superclass.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      'withClause': node.withClause.accept(this),
    };
  }

  @override
  Map<String, Object?> visitComment(Comment node) {
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
    };
  }

  @override
  Map<String, Object?> visitCommentReference(CommentReference node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CommentReference',
      'expression': node.expression.accept(this),
    };
  }

  @override
  Map<String, Object?> visitCompilationUnit(CompilationUnit node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'CompilationUnit',
      if (node.declarations.isNotEmpty)
        'declarations': <Map<String, Object?>?>[
          for (var item in node.declarations) item.accept(this),
        ],
      if (node.directives.isNotEmpty)
        'directives': <Map<String, Object?>?>[
          for (var item in node.directives) item.accept(this),
        ],
      if (node.scriptTag != null) 'scriptTag': node.scriptTag!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitConditionalExpression(ConditionalExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ConditionalExpression',
      'condition': node.condition.accept(this),
      'elseExpression': node.elseExpression.accept(this),
      'thenExpression': node.thenExpression.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitConfiguration(Configuration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'Configuration',
      'name': node.name.accept(this),
      'uri': node.uri.accept(this),
      if (node.value != null) 'value': node.value!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitConstantPattern(ConstantPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ConstantPattern',
      'expression': node.expression.accept(this),
    };
  }

  @override
  Map<String, Object?> visitConstructorDeclaration(
      ConstructorDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ConstructorDeclaration',
      'body': node.body.accept(this),
      if (node.initializers.isNotEmpty)
        'initializers': <Map<String, Object?>?>[
          for (var item in node.initializers) item.accept(this),
        ],
      'parameters': node.parameters.accept(this),
      if (node.redirectedConstructor != null)
        'redirectedConstructor': node.redirectedConstructor!.accept(this),
      'returnType': node.returnType.accept(this),
    };
  }

  @override
  Map<String, Object?> visitConstructorFieldInitializer(
      ConstructorFieldInitializer node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ConstructorFieldInitializer',
      'expression': node.expression.accept(this),
      'fieldName': node.fieldName.accept(this),
    };
  }

  @override
  Map<String, Object?> visitConstructorName(ConstructorName node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ConstructorName',
      if (node.name != null) 'name': node.name!.accept(this),
      'type': node.type.accept(this),
    };
  }

  @override
  Map<String, Object?> visitConstructorReference(ConstructorReference node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ConstructorReference',
      'constructorName': node.constructorName.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitConstructorSelector(ConstructorSelector node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ConstructorSelector',
      'name': node.name.accept(this),
    };
  }

  @override
  Map<String, Object?> visitContinueStatement(ContinueStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ContinueStatement',
      if (node.label != null) 'label': node.label!.accept(this),
      if (node.target != null) 'target': node.target!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitDeclaredIdentifier(DeclaredIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'DeclaredIdentifier',
      if (node.isConst) 'isConst': node.isConst,
      if (node.isFinal) 'isFinal': node.isFinal,
      if (node.type != null) 'type': node.type!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitDeclaredVariablePattern(
      DeclaredVariablePattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'DeclaredVariablePattern',
      if (node.type != null) 'type': node.type!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitDefaultFormalParameter(
      DefaultFormalParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'DefaultFormalParameter',
      if (node.defaultValue != null)
        'defaultValue': node.defaultValue!.accept(this),
      'parameter': node.parameter.accept(this),
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
    };
  }

  @override
  Map<String, Object?> visitDoStatement(DoStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'DoStatement',
      'body': node.body.accept(this),
      'condition': node.condition.accept(this),
    };
  }

  @override
  Map<String, Object?> visitDottedName(DottedName node) {
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
  Map<String, Object?> visitDoubleLiteral(DoubleLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'DoubleLiteral',
      'value': node.value,
    };
  }

  @override
  Map<String, Object?> visitEmptyFunctionBody(EmptyFunctionBody node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'EmptyFunctionBody',
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
    };
  }

  @override
  Map<String, Object?> visitEmptyStatement(EmptyStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'EmptyStatement',
    };
  }

  @override
  Map<String, Object?> visitEnumConstantArguments(EnumConstantArguments node) {
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
  Map<String, Object?> visitEnumConstantDeclaration(
      EnumConstantDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'EnumConstantDeclaration',
      if (node.arguments != null) 'arguments': node.arguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitEnumDeclaration(EnumDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'EnumDeclaration',
      if (node.constants.isNotEmpty)
        'constants': <Map<String, Object?>?>[
          for (var item in node.constants) item.accept(this),
        ],
      if (node.implementsClause != null)
        'implementsClause': node.implementsClause!.accept(this),
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      if (node.withClause != null) 'withClause': node.withClause!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitExportDirective(ExportDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ExportDirective',
      if (node.combinators.isNotEmpty)
        'combinators': <Map<String, Object?>?>[
          for (var item in node.combinators) item.accept(this),
        ],
      if (node.configurations.isNotEmpty)
        'configurations': <Map<String, Object?>?>[
          for (var item in node.configurations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitExpressionFunctionBody(
      ExpressionFunctionBody node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ExpressionFunctionBody',
      'expression': node.expression.accept(this),
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
    };
  }

  @override
  Map<String, Object?> visitExpressionStatement(ExpressionStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ExpressionStatement',
      'expression': node.expression.accept(this),
    };
  }

  @override
  Map<String, Object?> visitExtendsClause(ExtendsClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ExtendsClause',
      'superclass': node.superclass.accept(this),
    };
  }

  @override
  Map<String, Object?> visitExtensionDeclaration(ExtensionDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ExtensionDeclaration',
      'extendedType': node.extendedType.accept(this),
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitExtensionOverride(ExtensionOverride node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ExtensionOverride',
      'argumentList': node.argumentList.accept(this),
      'extensionName': node.extensionName.accept(this),
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitFieldDeclaration(FieldDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FieldDeclaration',
      'fields': node.fields.accept(this),
      if (node.isStatic) 'isStatic': node.isStatic,
    };
  }

  @override
  Map<String, Object?> visitFieldFormalParameter(FieldFormalParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FieldFormalParameter',
      if (node.parameters != null) 'parameters': node.parameters!.accept(this),
      if (node.type != null) 'type': node.type!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitForEachPartsWithDeclaration(
      ForEachPartsWithDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ForEachPartsWithDeclaration',
      'loopVariable': node.loopVariable.accept(this),
      'iterable': node.iterable.accept(this),
    };
  }

  @override
  Map<String, Object?> visitForEachPartsWithIdentifier(
      ForEachPartsWithIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ForEachPartsWithIdentifier',
      'identifier': node.identifier.accept(this),
      'iterable': node.iterable.accept(this),
    };
  }

  @override
  Map<String, Object?> visitForEachPartsWithPattern(
      ForEachPartsWithPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ForEachPartsWithPattern',
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      'pattern': node.pattern.accept(this),
      'iterable': node.iterable.accept(this),
    };
  }

  @override
  Map<String, Object?> visitForElement(ForElement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ForElement',
      'body': node.body.accept(this),
      'forLoopParts': node.forLoopParts.accept(this),
    };
  }

  @override
  Map<String, Object?> visitFormalParameterList(FormalParameterList node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FormalParameterList',
      if (node.parameters.isNotEmpty)
        'parameters': <Map<String, Object?>?>[
          for (var item in node.parameters) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitForPartsWithDeclarations(
      ForPartsWithDeclarations node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ForPartsWithDeclarations',
      'variables': node.variables.accept(this),
      if (node.condition != null) 'condition': node.condition!.accept(this),
      if (node.updaters.isNotEmpty)
        'updaters': <Map<String, Object?>?>[
          for (var item in node.updaters) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitForPartsWithExpression(
      ForPartsWithExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ForPartsWithExpression',
      if (node.initialization != null)
        'initialization': node.initialization!.accept(this),
      if (node.condition != null) 'condition': node.condition!.accept(this),
      if (node.updaters.isNotEmpty)
        'updaters': <Map<String, Object?>?>[
          for (var item in node.updaters) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitForPartsWithPattern(ForPartsWithPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ForPartsWithPattern',
      'variables': node.variables.accept(this),
      if (node.condition != null) 'condition': node.condition!.accept(this),
      if (node.updaters.isNotEmpty)
        'updaters': <Map<String, Object?>?>[
          for (var item in node.updaters) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitForStatement(ForStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ForStatement',
      'body': node.body.accept(this),
      'forLoopParts': node.forLoopParts.accept(this),
    };
  }

  @override
  Map<String, Object?> visitFunctionDeclaration(FunctionDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FunctionDeclaration',
      'functionExpression': node.functionExpression.accept(this),
      if (node.isGetter) 'isGetter': node.isGetter,
      if (node.isSetter) 'isSetter': node.isSetter,
      if (node.returnType != null) 'returnType': node.returnType!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitFunctionDeclarationStatement(
      FunctionDeclarationStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FunctionDeclarationStatement',
      'functionDeclaration': node.functionDeclaration.accept(this),
    };
  }

  @override
  Map<String, Object?> visitFunctionExpression(FunctionExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FunctionExpression',
      'body': node.body.accept(this),
      if (node.parameters != null) 'parameters': node.parameters!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitFunctionExpressionInvocation(
      FunctionExpressionInvocation node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FunctionExpressionInvocation',
      'function': node.function.accept(this),
      'argumentList': node.argumentList.accept(this),
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitFunctionReference(FunctionReference node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FunctionReference',
      'function': node.function.accept(this),
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitFunctionTypeAlias(FunctionTypeAlias node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FunctionTypeAlias',
      'parameters': node.parameters.accept(this),
      if (node.returnType != null) 'returnType': node.returnType!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitFunctionTypedFormalParameter(
      FunctionTypedFormalParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'FunctionTypedFormalParameter',
      'parameters': node.parameters.accept(this),
      if (node.returnType != null) 'returnType': node.returnType!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitGenericFunctionType(GenericFunctionType node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'GenericFunctionType',
      'parameters': node.parameters.accept(this),
      if (node.returnType != null) 'returnType': node.returnType!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitGenericTypeAlias(GenericTypeAlias node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'GenericTypeAlias',
      if (node.functionType != null)
        'functionType': node.functionType!.accept(this),
      'type': node.type.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitGuardedPattern(GuardedPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'GuardedPattern',
      'pattern': node.pattern.accept(this),
      if (node.whenClause != null) 'whenClause': node.whenClause!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitHideCombinator(HideCombinator node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'HideCombinator',
      if (node.hiddenNames.isNotEmpty)
        'hiddenNames': <Map<String, Object?>?>[
          for (var item in node.hiddenNames) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitIfElement(IfElement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'IfElement',
      if (node.caseClause != null) 'caseClause': node.caseClause!.accept(this),
      'condition': node.condition.accept(this),
      if (node.elseElement != null)
        'elseElement': node.elseElement!.accept(this),
      'expression': node.expression.accept(this),
      'thenElement': node.thenElement.accept(this),
    };
  }

  @override
  Map<String, Object?> visitIfStatement(IfStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'IfStatement',
      if (node.caseClause != null) 'caseClause': node.caseClause!.accept(this),
      'condition': node.condition.accept(this),
      if (node.elseStatement != null)
        'elseStatement': node.elseStatement!.accept(this),
      'expression': node.expression.accept(this),
      'thenStatement': node.thenStatement.accept(this),
    };
  }

  @override
  Map<String, Object?> visitImplementsClause(ImplementsClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ImplementsClause',
      if (node.interfaces.isNotEmpty)
        'interfaces': <Map<String, Object?>?>[
          for (var item in node.interfaces) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitImplicitCallReference(ImplicitCallReference node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ImplicitCallReference',
      'expression': node.expression.accept(this),
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitImportDirective(ImportDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ImportDirective',
      if (node.prefix != null) 'prefix': node.prefix!.accept(this),
      if (node.combinators.isNotEmpty)
        'combinators': <Map<String, Object?>?>[
          for (var item in node.combinators) item.accept(this),
        ],
      if (node.configurations.isNotEmpty)
        'configurations': <Map<String, Object?>?>[
          for (var item in node.configurations) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitIndexExpression(IndexExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'IndexExpression',
      'index': node.index.accept(this),
      if (node.isCascaded) 'isCascaded': node.isCascaded,
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      'realTarget': node.realTarget.accept(this),
      if (node.target != null) 'target': node.target!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitInstanceCreationExpression(
      InstanceCreationExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'InstanceCreationExpression',
      'argumentList': node.argumentList.accept(this),
      'constructorName': node.constructorName.accept(this),
      if (node.isConst) 'isConst': node.isConst,
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitIntegerLiteral(IntegerLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'IntegerLiteral',
      if (node.value != null) 'value': node.value!,
    };
  }

  @override
  Map<String, Object?> visitInterpolationExpression(
      InterpolationExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'InterpolationExpression',
      'expression': node.expression.accept(this),
    };
  }

  @override
  Map<String, Object?> visitInterpolationString(InterpolationString node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'InterpolationString',
      'contentsEnd': node.contentsEnd,
      'contentsOffset': node.contentsOffset,
      'value': node.value,
    };
  }

  @override
  Map<String, Object?> visitIsExpression(IsExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'IsExpression',
      'expression': node.expression.accept(this),
      'type': node.type.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitLabel(Label node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'Label',
      'label': node.label.accept(this),
    };
  }

  @override
  Map<String, Object?> visitLabeledStatement(LabeledStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'LabeledStatement',
      if (node.labels.isNotEmpty)
        'labels': <Map<String, Object?>?>[
          for (var item in node.labels) item.accept(this),
        ],
      'statement': node.statement.accept(this),
    };
  }

  @override
  Map<String, Object?> visitLibraryAugmentationDirective(
      LibraryAugmentationDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'LibraryAugmentationDirective',
      'uri': node.uri.accept(this),
    };
  }

  @override
  Map<String, Object?> visitLibraryDirective(LibraryDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'LibraryDirective',
      if (node.name2 != null) 'name2': node.name2!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitLibraryIdentifier(LibraryIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'LibraryIdentifier',
      if (node.components.isNotEmpty)
        'components': <Map<String, Object?>?>[
          for (var item in node.components) item.accept(this),
        ],
      'name': node.name,
    };
  }

  @override
  Map<String, Object?> visitListLiteral(ListLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ListLiteral',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      if (node.isConst) 'isConst': node.isConst,
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitListPattern(ListPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ListPattern',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitMapLiteralEntry(MapLiteralEntry node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'MapLiteralEntry',
      'key': node.key.accept(this),
      'value': node.value.accept(this),
    };
  }

  @override
  Map<String, Object?> visitMapPattern(MapPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'MapPattern',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitMapPatternEntry(MapPatternEntry node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'MapPatternEntry',
      'key': node.key.accept(this),
      'value': node.value.accept(this),
    };
  }

  @override
  Map<String, Object?> visitMethodDeclaration(MethodDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'MethodDeclaration',
      'body': node.body.accept(this),
      if (node.isAbstract) 'isAbstract': node.isAbstract,
      if (node.isGetter) 'isGetter': node.isGetter,
      if (node.isOperator) 'isOperator': node.isOperator,
      if (node.isSetter) 'isSetter': node.isSetter,
      if (node.isStatic) 'isStatic': node.isStatic,
      if (node.parameters != null) 'parameters': node.parameters!.accept(this),
      if (node.returnType != null) 'returnType': node.returnType!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitMethodInvocation(MethodInvocation node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'MethodInvocation',
      if (node.isCascaded) 'isCascaded': node.isCascaded,
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      'methodName': node.methodName.accept(this),
      if (node.realTarget != null) 'realTarget': node.realTarget!.accept(this),
      if (node.target != null) 'target': node.target!.accept(this),
      'argumentList': node.argumentList.accept(this),
      'function': node.function.accept(this),
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitMixinDeclaration(MixinDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'MixinDeclaration',
      if (node.implementsClause != null)
        'implementsClause': node.implementsClause!.accept(this),
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      if (node.onClause != null) 'onClause': node.onClause!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitNamedExpression(NamedExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'NamedExpression',
      'expression': node.expression.accept(this),
      'name': node.name.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitNamedType(NamedType node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'NamedType',
      if (node.isDeferred) 'isDeferred': node.isDeferred,
      'name': node.name.accept(this),
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitNativeClause(NativeClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'NativeClause',
      if (node.name != null) 'name': node.name!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitNativeFunctionBody(NativeFunctionBody node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'NativeFunctionBody',
      if (node.stringLiteral != null)
        'stringLiteral': node.stringLiteral!.accept(this),
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
    };
  }

  @override
  Map<String, Object?> visitNullLiteral(NullLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'NullLiteral',
    };
  }

  @override
  Map<String, Object?> visitObjectPattern(ObjectPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ObjectPattern',
      if (node.fields.isNotEmpty)
        'fields': <Map<String, Object?>?>[
          for (var item in node.fields) item.accept(this),
        ],
      'type': node.type.accept(this),
    };
  }

  @override
  Map<String, Object?> visitOnClause(OnClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'OnClause',
      if (node.superclassConstraints.isNotEmpty)
        'superclassConstraints': <Map<String, Object?>?>[
          for (var item in node.superclassConstraints) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitParenthesizedExpression(
      ParenthesizedExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ParenthesizedExpression',
      'expression': node.expression.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitParenthesizedPattern(ParenthesizedPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ParenthesizedPattern',
      'pattern': node.pattern.accept(this),
    };
  }

  @override
  Map<String, Object?> visitPartDirective(PartDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PartDirective',
      'uri': node.uri.accept(this),
    };
  }

  @override
  Map<String, Object?> visitPartOfDirective(PartOfDirective node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PartOfDirective',
      if (node.libraryName != null)
        'libraryName': node.libraryName!.accept(this),
      if (node.uri != null) 'uri': node.uri!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitPatternAssignment(PatternAssignment node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PatternAssignment',
      'expression': node.expression.accept(this),
      'pattern': node.pattern.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitPatternVariableDeclaration(
      PatternVariableDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PatternVariableDeclaration',
      'expression': node.expression.accept(this),
      'pattern': node.pattern.accept(this),
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitPatternVariableDeclarationStatement(
      PatternVariableDeclarationStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PatternVariableDeclarationStatement',
      'declaration': node.declaration.accept(this),
    };
  }

  @override
  Map<String, Object?> visitPostfixExpression(PostfixExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PostfixExpression',
      'operand': node.operand.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitPostfixPattern(PostfixPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PostfixPattern',
      'operand': node.operand.accept(this),
    };
  }

  @override
  Map<String, Object?> visitPrefixedIdentifier(PrefixedIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PrefixedIdentifier',
      'identifier': node.identifier.accept(this),
      if (node.isDeferred) 'isDeferred': node.isDeferred,
      'prefix': node.prefix.accept(this),
      'name': node.name,
    };
  }

  @override
  Map<String, Object?> visitPrefixExpression(PrefixExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PrefixExpression',
      'operand': node.operand.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitPropertyAccess(PropertyAccess node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'PropertyAccess',
      if (node.isCascaded) 'isCascaded': node.isCascaded,
      if (node.isNullAware) 'isNullAware': node.isNullAware,
      'propertyName': node.propertyName.accept(this),
      'realTarget': node.realTarget.accept(this),
      if (node.target != null) 'target': node.target!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitRecordLiteral(RecordLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RecordLiteral',
      if (node.fields.isNotEmpty)
        'fields': <Map<String, Object?>?>[
          for (var item in node.fields) item.accept(this),
        ],
      if (node.isConst) 'isConst': node.isConst,
    };
  }

  @override
  Map<String, Object?> visitRecordPattern(RecordPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RecordPattern',
      if (node.fields.isNotEmpty)
        'fields': <Map<String, Object?>?>[
          for (var item in node.fields) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitRecordPatternField(RecordPatternField node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RecordPatternField',
      if (node.fieldName != null) 'fieldName': node.fieldName!.accept(this),
      'pattern': node.pattern.accept(this),
    };
  }

  @override
  Map<String, Object?> visitRecordPatternFieldName(
      RecordPatternFieldName node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RecordPatternFieldName',
    };
  }

  @override
  Map<String, Object?> visitRecordTypeAnnotation(RecordTypeAnnotation node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RecordTypeAnnotation',
      if (node.namedFields != null)
        'namedFields': node.namedFields!.accept(this),
      if (node.positionalFields.isNotEmpty)
        'positionalFields': <Map<String, Object?>?>[
          for (var item in node.positionalFields) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitRecordTypeAnnotationNamedField(
      RecordTypeAnnotationNamedField node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RecordTypeAnnotationNamedField',
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      'type': node.type.accept(this),
    };
  }

  @override
  Map<String, Object?> visitRecordTypeAnnotationNamedFields(
      RecordTypeAnnotationNamedFields node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RecordTypeAnnotationNamedFields',
      if (node.fields.isNotEmpty)
        'fields': <Map<String, Object?>?>[
          for (var item in node.fields) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitRecordTypeAnnotationPositionalField(
      RecordTypeAnnotationPositionalField node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RecordTypeAnnotationPositionalField',
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
      'type': node.type.accept(this),
    };
  }

  @override
  Map<String, Object?> visitRedirectingConstructorInvocation(
      RedirectingConstructorInvocation node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RedirectingConstructorInvocation',
      'argumentList': node.argumentList.accept(this),
      if (node.constructorName != null)
        'constructorName': node.constructorName!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitRelationalPattern(RelationalPattern node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RelationalPattern',
      'operand': node.operand.accept(this),
    };
  }

  @override
  Map<String, Object?> visitRestPatternElement(RestPatternElement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RestPatternElement',
      if (node.pattern != null) 'pattern': node.pattern!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitRethrowExpression(RethrowExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'RethrowExpression',
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitReturnStatement(ReturnStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ReturnStatement',
      if (node.expression != null) 'expression': node.expression!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitScriptTag(ScriptTag node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ScriptTag',
    };
  }

  @override
  Map<String, Object?> visitSetOrMapLiteral(SetOrMapLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SetOrMapLiteral',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      if (node.isMap) 'isMap': node.isMap,
      if (node.isSet) 'isSet': node.isSet,
      if (node.isConst) 'isConst': node.isConst,
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitShowCombinator(ShowCombinator node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ShowCombinator',
      if (node.shownNames.isNotEmpty)
        'shownNames': <Map<String, Object?>?>[
          for (var item in node.shownNames) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitSimpleFormalParameter(SimpleFormalParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SimpleFormalParameter',
      if (node.type != null) 'type': node.type!.accept(this),
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitSimpleIdentifier(SimpleIdentifier node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SimpleIdentifier',
      'name': node.name,
    };
  }

  @override
  Map<String, Object?> visitSimpleStringLiteral(SimpleStringLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SimpleStringLiteral',
      'value': node.value,
      'contentsEnd': node.contentsEnd,
      'contentsOffset': node.contentsOffset,
      if (node.isMultiline) 'isMultiline': node.isMultiline,
      if (node.isRaw) 'isRaw': node.isRaw,
      if (node.isSingleQuoted) 'isSingleQuoted': node.isSingleQuoted,
    };
  }

  @override
  Map<String, Object?> visitSpreadElement(SpreadElement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SpreadElement',
      'expression': node.expression.accept(this),
      if (node.isNullAware) 'isNullAware': node.isNullAware,
    };
  }

  @override
  Map<String, Object?> visitStringInterpolation(StringInterpolation node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'StringInterpolation',
      if (node.elements.isNotEmpty)
        'elements': <Map<String, Object?>?>[
          for (var item in node.elements) item.accept(this),
        ],
      'firstString': node.firstString.accept(this),
      'lastString': node.lastString.accept(this),
      'contentsEnd': node.contentsEnd,
      'contentsOffset': node.contentsOffset,
      if (node.isMultiline) 'isMultiline': node.isMultiline,
      if (node.isRaw) 'isRaw': node.isRaw,
      if (node.isSingleQuoted) 'isSingleQuoted': node.isSingleQuoted,
    };
  }

  @override
  Map<String, Object?> visitSuperConstructorInvocation(
      SuperConstructorInvocation node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SuperConstructorInvocation',
      'argumentList': node.argumentList.accept(this),
      if (node.constructorName != null)
        'constructorName': node.constructorName!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitSuperExpression(SuperExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SuperExpression',
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitSuperFormalParameter(SuperFormalParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SuperFormalParameter',
      if (node.parameters != null) 'parameters': node.parameters!.accept(this),
      if (node.type != null) 'type': node.type!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitSwitchCase(SwitchCase node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SwitchCase',
      'expression': node.expression.accept(this),
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
  Map<String, Object?> visitSwitchDefault(SwitchDefault node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SwitchDefault',
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
  Map<String, Object?> visitSwitchExpression(SwitchExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SwitchExpression',
      if (node.cases.isNotEmpty)
        'cases': <Map<String, Object?>?>[
          for (var item in node.cases) item.accept(this),
        ],
      'expression': node.expression.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitSwitchExpressionCase(SwitchExpressionCase node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SwitchExpressionCase',
      'expression': node.expression.accept(this),
      'guardedPattern': node.guardedPattern.accept(this),
    };
  }

  @override
  Map<String, Object?> visitSwitchPatternCase(SwitchPatternCase node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SwitchPatternCase',
      'guardedPattern': node.guardedPattern.accept(this),
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
  Map<String, Object?> visitSwitchStatement(SwitchStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SwitchStatement',
      'expression': node.expression.accept(this),
      if (node.members.isNotEmpty)
        'members': <Map<String, Object?>?>[
          for (var item in node.members) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitSymbolLiteral(SymbolLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'SymbolLiteral',
    };
  }

  @override
  Map<String, Object?> visitThisExpression(ThisExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ThisExpression',
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitThrowExpression(ThrowExpression node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'ThrowExpression',
      'expression': node.expression.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitTopLevelVariableDeclaration(
      TopLevelVariableDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'TopLevelVariableDeclaration',
      'variables': node.variables.accept(this),
    };
  }

  @override
  Map<String, Object?> visitTryStatement(TryStatement node) {
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
    };
  }

  @override
  Map<String, Object?> visitTypeArgumentList(TypeArgumentList node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'TypeArgumentList',
      if (node.arguments.isNotEmpty)
        'arguments': <Map<String, Object?>?>[
          for (var item in node.arguments) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitTypeLiteral(TypeLiteral node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'TypeLiteral',
      'type': node.type.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitTypeParameter(TypeParameter node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'TypeParameter',
      if (node.bound != null) 'bound': node.bound!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitTypeParameterList(TypeParameterList node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'TypeParameterList',
      if (node.typeParameters.isNotEmpty)
        'typeParameters': <Map<String, Object?>?>[
          for (var item in node.typeParameters) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitVariableDeclaration(VariableDeclaration node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'VariableDeclaration',
      if (node.initializer != null)
        'initializer': node.initializer!.accept(this),
      if (node.isConst) 'isConst': node.isConst,
      if (node.isFinal) 'isFinal': node.isFinal,
      if (node.isLate) 'isLate': node.isLate,
    };
  }

  @override
  Map<String, Object?> visitVariableDeclarationList(
      VariableDeclarationList node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'VariableDeclarationList',
      if (node.isConst) 'isConst': node.isConst,
      if (node.isFinal) 'isFinal': node.isFinal,
      if (node.isLate) 'isLate': node.isLate,
      if (node.type != null) 'type': node.type!.accept(this),
      if (node.variables.isNotEmpty)
        'variables': <Map<String, Object?>?>[
          for (var item in node.variables) item.accept(this),
        ],
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
      if (node.metadata.isNotEmpty)
        'metadata': <Map<String, Object?>?>[
          for (var item in node.metadata) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitVariableDeclarationStatement(
      VariableDeclarationStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'VariableDeclarationStatement',
      'variables': node.variables.accept(this),
    };
  }

  @override
  Map<String, Object?> visitWhenClause(WhenClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'WhenClause',
      'expression': node.expression.accept(this),
    };
  }

  @override
  Map<String, Object?> visitWhileStatement(WhileStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'WhileStatement',
      'body': node.body.accept(this),
      'condition': node.condition.accept(this),
    };
  }

  @override
  Map<String, Object?> visitWithClause(WithClause node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'WithClause',
      if (node.mixinTypes.isNotEmpty)
        'mixinTypes': <Map<String, Object?>?>[
          for (var item in node.mixinTypes) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitYieldStatement(YieldStatement node) {
    return <String, Object?>{
      ...getLocation(node),
      'class': 'YieldStatement',
      'expression': node.expression.accept(this),
    };
  }
}
