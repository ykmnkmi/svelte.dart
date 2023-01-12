// generated with `tools/generate_script_to_json.dart`
// ignore_for_file: depend_on_referenced_packages

import 'package:analyzer/dart/ast/ast.dart'
    show
        AdjacentStrings,
        Annotation,
        ArgumentList,
        AsExpression,
        AssertInitializer,
        AssertStatement,
        AssignedVariablePattern,
        AssignmentExpression,
        AstNode,
        AugmentationImportDirective,
        AwaitExpression,
        BinaryExpression,
        BinaryPattern,
        Block,
        BlockFunctionBody,
        BooleanLiteral,
        BreakStatement,
        CascadeExpression,
        CaseClause,
        CastPattern,
        CatchClause,
        CatchClauseParameter,
        ClassDeclaration,
        ClassTypeAlias,
        Comment,
        CommentReference,
        CompilationUnit,
        ConditionalExpression,
        Configuration,
        ConstantPattern,
        ConstructorDeclaration,
        ConstructorFieldInitializer,
        ConstructorName,
        ConstructorReference,
        ConstructorSelector,
        ContinueStatement,
        DeclaredIdentifier,
        DeclaredVariablePattern,
        DefaultFormalParameter,
        DoStatement,
        DottedName,
        DoubleLiteral,
        EmptyFunctionBody,
        EmptyStatement,
        EnumConstantArguments,
        EnumConstantDeclaration,
        EnumDeclaration,
        ExportDirective,
        ExpressionFunctionBody,
        ExpressionStatement,
        ExtendsClause,
        ExtensionDeclaration,
        ExtensionOverride,
        FieldDeclaration,
        FieldFormalParameter,
        ForEachPartsWithDeclaration,
        ForEachPartsWithIdentifier,
        ForEachPartsWithPattern,
        ForElement,
        ForPartsWithDeclarations,
        ForPartsWithExpression,
        ForPartsWithPattern,
        ForStatement,
        FormalParameterList,
        FunctionDeclaration,
        FunctionDeclarationStatement,
        FunctionExpression,
        FunctionExpressionInvocation,
        FunctionReference,
        FunctionTypeAlias,
        FunctionTypedFormalParameter,
        GenericFunctionType,
        GenericTypeAlias,
        GuardedPattern,
        HideCombinator,
        IfElement,
        IfStatement,
        ImplementsClause,
        ImplicitCallReference,
        ImportDirective,
        IndexExpression,
        InstanceCreationExpression,
        IntegerLiteral,
        InterpolationExpression,
        InterpolationString,
        IsExpression,
        Label,
        LabeledStatement,
        LibraryAugmentationDirective,
        LibraryDirective,
        LibraryIdentifier,
        ListLiteral,
        ListPattern,
        MapLiteralEntry,
        MapPattern,
        MapPatternEntry,
        MethodDeclaration,
        MethodInvocation,
        MixinDeclaration,
        NamedExpression,
        NamedType,
        NativeClause,
        NativeFunctionBody,
        NullLiteral,
        ObjectPattern,
        OnClause,
        ParenthesizedExpression,
        ParenthesizedPattern,
        PartDirective,
        PartOfDirective,
        PatternAssignment,
        PatternVariableDeclaration,
        PatternVariableDeclarationStatement,
        PostfixExpression,
        PostfixPattern,
        PrefixExpression,
        PrefixedIdentifier,
        PropertyAccess,
        RecordLiteral,
        RecordPattern,
        RecordPatternField,
        RecordPatternFieldName,
        RecordTypeAnnotation,
        RecordTypeAnnotationNamedField,
        RecordTypeAnnotationNamedFields,
        RecordTypeAnnotationPositionalField,
        RedirectingConstructorInvocation,
        RelationalPattern,
        RestPatternElement,
        RethrowExpression,
        ReturnStatement,
        ScriptTag,
        SetOrMapLiteral,
        ShowCombinator,
        SimpleFormalParameter,
        SimpleIdentifier,
        SimpleStringLiteral,
        SpreadElement,
        StringInterpolation,
        SuperConstructorInvocation,
        SuperExpression,
        SuperFormalParameter,
        SwitchCase,
        SwitchDefault,
        SwitchExpression,
        SwitchExpressionCase,
        SwitchPatternCase,
        SwitchStatement,
        SymbolLiteral,
        ThisExpression,
        ThrowExpression,
        TopLevelVariableDeclaration,
        TryStatement,
        TypeArgumentList,
        TypeLiteral,
        TypeParameter,
        TypeParameterList,
        VariableDeclaration,
        VariableDeclarationList,
        VariableDeclarationStatement,
        WhenClause,
        WhileStatement,
        WithClause,
        YieldStatement;
import 'package:analyzer/dart/ast/visitor.dart' show ThrowingAstVisitor;

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
      '_': 'AdjacentStrings',
      ...getLocation(node),
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
      '_': 'Annotation',
      ...getLocation(node),
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
      '_': 'ArgumentList',
      ...getLocation(node),
      if (node.arguments.isNotEmpty)
        'arguments': <Map<String, Object?>?>[
          for (var item in node.arguments) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitAsExpression(AsExpression node) {
    return <String, Object?>{
      '_': 'AsExpression',
      ...getLocation(node),
      'expression': node.expression.accept(this),
      'type': node.type.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitAssertInitializer(AssertInitializer node) {
    return <String, Object?>{
      '_': 'AssertInitializer',
      ...getLocation(node),
      'condition': node.condition.accept(this),
      if (node.message != null) 'message': node.message!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitAssertStatement(AssertStatement node) {
    return <String, Object?>{
      '_': 'AssertStatement',
      ...getLocation(node),
      'condition': node.condition.accept(this),
      if (node.message != null) 'message': node.message!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitAssignedVariablePattern(
      AssignedVariablePattern node) {
    return <String, Object?>{
      '_': 'AssignedVariablePattern',
      ...getLocation(node),
    };
  }

  @override
  Map<String, Object?> visitAssignmentExpression(AssignmentExpression node) {
    return <String, Object?>{
      '_': 'AssignmentExpression',
      ...getLocation(node),
      'leftHandSide': node.leftHandSide.accept(this),
      'rightHandSide': node.rightHandSide.accept(this),
    };
  }

  @override
  Map<String, Object?> visitAugmentationImportDirective(
      AugmentationImportDirective node) {
    return <String, Object?>{
      '_': 'AugmentationImportDirective',
      ...getLocation(node),
      'uri': node.uri.accept(this),
    };
  }

  @override
  Map<String, Object?> visitAwaitExpression(AwaitExpression node) {
    return <String, Object?>{
      '_': 'AwaitExpression',
      ...getLocation(node),
      'expression': node.expression.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitBinaryExpression(BinaryExpression node) {
    return <String, Object?>{
      '_': 'BinaryExpression',
      ...getLocation(node),
      'leftOperand': node.leftOperand.accept(this),
      'rightOperand': node.rightOperand.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitBinaryPattern(BinaryPattern node) {
    return <String, Object?>{
      '_': 'BinaryPattern',
      ...getLocation(node),
      'leftOperand': node.leftOperand.accept(this),
      'rightOperand': node.rightOperand.accept(this),
    };
  }

  @override
  Map<String, Object?> visitBlock(Block node) {
    return <String, Object?>{
      '_': 'Block',
      ...getLocation(node),
      if (node.statements.isNotEmpty)
        'statements': <Map<String, Object?>?>[
          for (var item in node.statements) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitBlockFunctionBody(BlockFunctionBody node) {
    return <String, Object?>{
      '_': 'BlockFunctionBody',
      ...getLocation(node),
      'block': node.block.accept(this),
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
    };
  }

  @override
  Map<String, Object?> visitBooleanLiteral(BooleanLiteral node) {
    return <String, Object?>{
      '_': 'BooleanLiteral',
      ...getLocation(node),
      if (node.value) 'value': node.value,
    };
  }

  @override
  Map<String, Object?> visitBreakStatement(BreakStatement node) {
    return <String, Object?>{
      '_': 'BreakStatement',
      ...getLocation(node),
      if (node.label != null) 'label': node.label!.accept(this),
      if (node.target != null) 'target': node.target!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitCascadeExpression(CascadeExpression node) {
    return <String, Object?>{
      '_': 'CascadeExpression',
      ...getLocation(node),
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
      '_': 'CaseClause',
      ...getLocation(node),
      'guardedPattern': node.guardedPattern.accept(this),
    };
  }

  @override
  Map<String, Object?> visitCastPattern(CastPattern node) {
    return <String, Object?>{
      '_': 'CastPattern',
      ...getLocation(node),
      'pattern': node.pattern.accept(this),
      'type': node.type.accept(this),
    };
  }

  @override
  Map<String, Object?> visitCatchClause(CatchClause node) {
    return <String, Object?>{
      '_': 'CatchClause',
      ...getLocation(node),
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
      '_': 'CatchClauseParameter',
      ...getLocation(node),
    };
  }

  @override
  Map<String, Object?> visitClassDeclaration(ClassDeclaration node) {
    return <String, Object?>{
      '_': 'ClassDeclaration',
      ...getLocation(node),
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
      '_': 'ClassTypeAlias',
      ...getLocation(node),
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
      '_': 'Comment',
      ...getLocation(node),
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
      '_': 'CommentReference',
      ...getLocation(node),
      'expression': node.expression.accept(this),
    };
  }

  @override
  Map<String, Object?> visitCompilationUnit(CompilationUnit node) {
    return <String, Object?>{
      '_': 'CompilationUnit',
      ...getLocation(node),
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
      '_': 'ConditionalExpression',
      ...getLocation(node),
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
      '_': 'Configuration',
      ...getLocation(node),
      'name': node.name.accept(this),
      'uri': node.uri.accept(this),
      if (node.value != null) 'value': node.value!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitConstantPattern(ConstantPattern node) {
    return <String, Object?>{
      '_': 'ConstantPattern',
      ...getLocation(node),
      'expression': node.expression.accept(this),
    };
  }

  @override
  Map<String, Object?> visitConstructorDeclaration(
      ConstructorDeclaration node) {
    return <String, Object?>{
      '_': 'ConstructorDeclaration',
      ...getLocation(node),
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
      '_': 'ConstructorFieldInitializer',
      ...getLocation(node),
      'expression': node.expression.accept(this),
      'fieldName': node.fieldName.accept(this),
    };
  }

  @override
  Map<String, Object?> visitConstructorName(ConstructorName node) {
    return <String, Object?>{
      '_': 'ConstructorName',
      ...getLocation(node),
      if (node.name != null) 'name': node.name!.accept(this),
      'type': node.type.accept(this),
    };
  }

  @override
  Map<String, Object?> visitConstructorReference(ConstructorReference node) {
    return <String, Object?>{
      '_': 'ConstructorReference',
      ...getLocation(node),
      'constructorName': node.constructorName.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitConstructorSelector(ConstructorSelector node) {
    return <String, Object?>{
      '_': 'ConstructorSelector',
      ...getLocation(node),
      'name': node.name.accept(this),
    };
  }

  @override
  Map<String, Object?> visitContinueStatement(ContinueStatement node) {
    return <String, Object?>{
      '_': 'ContinueStatement',
      ...getLocation(node),
      if (node.label != null) 'label': node.label!.accept(this),
      if (node.target != null) 'target': node.target!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitDeclaredIdentifier(DeclaredIdentifier node) {
    return <String, Object?>{
      '_': 'DeclaredIdentifier',
      ...getLocation(node),
      if (node.isConst) 'isConst': node.isConst,
      if (node.isFinal) 'isFinal': node.isFinal,
      if (node.type != null) 'type': node.type!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitDeclaredVariablePattern(
      DeclaredVariablePattern node) {
    return <String, Object?>{
      '_': 'DeclaredVariablePattern',
      ...getLocation(node),
      if (node.type != null) 'type': node.type!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitDefaultFormalParameter(
      DefaultFormalParameter node) {
    return <String, Object?>{
      '_': 'DefaultFormalParameter',
      ...getLocation(node),
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
      '_': 'DoStatement',
      ...getLocation(node),
      'body': node.body.accept(this),
      'condition': node.condition.accept(this),
    };
  }

  @override
  Map<String, Object?> visitDottedName(DottedName node) {
    return <String, Object?>{
      '_': 'DottedName',
      ...getLocation(node),
      if (node.components.isNotEmpty)
        'components': <Map<String, Object?>?>[
          for (var item in node.components) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitDoubleLiteral(DoubleLiteral node) {
    return <String, Object?>{
      '_': 'DoubleLiteral',
      ...getLocation(node),
      'value': node.value,
    };
  }

  @override
  Map<String, Object?> visitEmptyFunctionBody(EmptyFunctionBody node) {
    return <String, Object?>{
      '_': 'EmptyFunctionBody',
      ...getLocation(node),
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
    };
  }

  @override
  Map<String, Object?> visitEmptyStatement(EmptyStatement node) {
    return <String, Object?>{
      '_': 'EmptyStatement',
      ...getLocation(node),
    };
  }

  @override
  Map<String, Object?> visitEnumConstantArguments(EnumConstantArguments node) {
    return <String, Object?>{
      '_': 'EnumConstantArguments',
      ...getLocation(node),
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
      '_': 'EnumConstantDeclaration',
      ...getLocation(node),
      if (node.arguments != null) 'arguments': node.arguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitEnumDeclaration(EnumDeclaration node) {
    return <String, Object?>{
      '_': 'EnumDeclaration',
      ...getLocation(node),
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
      '_': 'ExportDirective',
      ...getLocation(node),
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
      '_': 'ExpressionFunctionBody',
      ...getLocation(node),
      'expression': node.expression.accept(this),
      if (node.isAsynchronous) 'isAsynchronous': node.isAsynchronous,
      if (node.isGenerator) 'isGenerator': node.isGenerator,
      if (node.isSynchronous) 'isSynchronous': node.isSynchronous,
    };
  }

  @override
  Map<String, Object?> visitExpressionStatement(ExpressionStatement node) {
    return <String, Object?>{
      '_': 'ExpressionStatement',
      ...getLocation(node),
      'expression': node.expression.accept(this),
    };
  }

  @override
  Map<String, Object?> visitExtendsClause(ExtendsClause node) {
    return <String, Object?>{
      '_': 'ExtendsClause',
      ...getLocation(node),
      'superclass': node.superclass.accept(this),
    };
  }

  @override
  Map<String, Object?> visitExtensionDeclaration(ExtensionDeclaration node) {
    return <String, Object?>{
      '_': 'ExtensionDeclaration',
      ...getLocation(node),
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
      '_': 'ExtensionOverride',
      ...getLocation(node),
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
      '_': 'FieldDeclaration',
      ...getLocation(node),
      'fields': node.fields.accept(this),
      if (node.isStatic) 'isStatic': node.isStatic,
    };
  }

  @override
  Map<String, Object?> visitFieldFormalParameter(FieldFormalParameter node) {
    return <String, Object?>{
      '_': 'FieldFormalParameter',
      ...getLocation(node),
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
      '_': 'ForEachPartsWithDeclaration',
      ...getLocation(node),
      'loopVariable': node.loopVariable.accept(this),
      'iterable': node.iterable.accept(this),
    };
  }

  @override
  Map<String, Object?> visitForEachPartsWithIdentifier(
      ForEachPartsWithIdentifier node) {
    return <String, Object?>{
      '_': 'ForEachPartsWithIdentifier',
      ...getLocation(node),
      'identifier': node.identifier.accept(this),
      'iterable': node.iterable.accept(this),
    };
  }

  @override
  Map<String, Object?> visitForEachPartsWithPattern(
      ForEachPartsWithPattern node) {
    return <String, Object?>{
      '_': 'ForEachPartsWithPattern',
      ...getLocation(node),
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
      '_': 'ForElement',
      ...getLocation(node),
      'body': node.body.accept(this),
      'forLoopParts': node.forLoopParts.accept(this),
    };
  }

  @override
  Map<String, Object?> visitFormalParameterList(FormalParameterList node) {
    return <String, Object?>{
      '_': 'FormalParameterList',
      ...getLocation(node),
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
      '_': 'ForPartsWithDeclarations',
      ...getLocation(node),
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
      '_': 'ForPartsWithExpression',
      ...getLocation(node),
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
      '_': 'ForPartsWithPattern',
      ...getLocation(node),
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
      '_': 'ForStatement',
      ...getLocation(node),
      'body': node.body.accept(this),
      'forLoopParts': node.forLoopParts.accept(this),
    };
  }

  @override
  Map<String, Object?> visitFunctionDeclaration(FunctionDeclaration node) {
    return <String, Object?>{
      '_': 'FunctionDeclaration',
      ...getLocation(node),
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
      '_': 'FunctionDeclarationStatement',
      ...getLocation(node),
      'functionDeclaration': node.functionDeclaration.accept(this),
    };
  }

  @override
  Map<String, Object?> visitFunctionExpression(FunctionExpression node) {
    return <String, Object?>{
      '_': 'FunctionExpression',
      ...getLocation(node),
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
      '_': 'FunctionExpressionInvocation',
      ...getLocation(node),
      'function': node.function.accept(this),
      'argumentList': node.argumentList.accept(this),
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitFunctionReference(FunctionReference node) {
    return <String, Object?>{
      '_': 'FunctionReference',
      ...getLocation(node),
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
      '_': 'FunctionTypeAlias',
      ...getLocation(node),
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
      '_': 'FunctionTypedFormalParameter',
      ...getLocation(node),
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
      '_': 'GenericFunctionType',
      ...getLocation(node),
      'parameters': node.parameters.accept(this),
      if (node.returnType != null) 'returnType': node.returnType!.accept(this),
      if (node.typeParameters != null)
        'typeParameters': node.typeParameters!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitGenericTypeAlias(GenericTypeAlias node) {
    return <String, Object?>{
      '_': 'GenericTypeAlias',
      ...getLocation(node),
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
      '_': 'GuardedPattern',
      ...getLocation(node),
      'pattern': node.pattern.accept(this),
      if (node.whenClause != null) 'whenClause': node.whenClause!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitHideCombinator(HideCombinator node) {
    return <String, Object?>{
      '_': 'HideCombinator',
      ...getLocation(node),
      if (node.hiddenNames.isNotEmpty)
        'hiddenNames': <Map<String, Object?>?>[
          for (var item in node.hiddenNames) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitIfElement(IfElement node) {
    return <String, Object?>{
      '_': 'IfElement',
      ...getLocation(node),
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
      '_': 'IfStatement',
      ...getLocation(node),
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
      '_': 'ImplementsClause',
      ...getLocation(node),
      if (node.interfaces.isNotEmpty)
        'interfaces': <Map<String, Object?>?>[
          for (var item in node.interfaces) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitImplicitCallReference(ImplicitCallReference node) {
    return <String, Object?>{
      '_': 'ImplicitCallReference',
      ...getLocation(node),
      'expression': node.expression.accept(this),
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitImportDirective(ImportDirective node) {
    return <String, Object?>{
      '_': 'ImportDirective',
      ...getLocation(node),
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
      '_': 'IndexExpression',
      ...getLocation(node),
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
      '_': 'InstanceCreationExpression',
      ...getLocation(node),
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
      '_': 'IntegerLiteral',
      ...getLocation(node),
      if (node.value != null) 'value': node.value!,
    };
  }

  @override
  Map<String, Object?> visitInterpolationExpression(
      InterpolationExpression node) {
    return <String, Object?>{
      '_': 'InterpolationExpression',
      ...getLocation(node),
      'expression': node.expression.accept(this),
    };
  }

  @override
  Map<String, Object?> visitInterpolationString(InterpolationString node) {
    return <String, Object?>{
      '_': 'InterpolationString',
      ...getLocation(node),
      'contentsEnd': node.contentsEnd,
      'contentsOffset': node.contentsOffset,
      'value': node.value,
    };
  }

  @override
  Map<String, Object?> visitIsExpression(IsExpression node) {
    return <String, Object?>{
      '_': 'IsExpression',
      ...getLocation(node),
      'expression': node.expression.accept(this),
      'type': node.type.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitLabel(Label node) {
    return <String, Object?>{
      '_': 'Label',
      ...getLocation(node),
      'label': node.label.accept(this),
    };
  }

  @override
  Map<String, Object?> visitLabeledStatement(LabeledStatement node) {
    return <String, Object?>{
      '_': 'LabeledStatement',
      ...getLocation(node),
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
      '_': 'LibraryAugmentationDirective',
      ...getLocation(node),
      'uri': node.uri.accept(this),
    };
  }

  @override
  Map<String, Object?> visitLibraryDirective(LibraryDirective node) {
    return <String, Object?>{
      '_': 'LibraryDirective',
      ...getLocation(node),
      if (node.name2 != null) 'name2': node.name2!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitLibraryIdentifier(LibraryIdentifier node) {
    return <String, Object?>{
      '_': 'LibraryIdentifier',
      ...getLocation(node),
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
      '_': 'ListLiteral',
      ...getLocation(node),
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
      '_': 'ListPattern',
      ...getLocation(node),
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
      '_': 'MapLiteralEntry',
      ...getLocation(node),
      'key': node.key.accept(this),
      'value': node.value.accept(this),
    };
  }

  @override
  Map<String, Object?> visitMapPattern(MapPattern node) {
    return <String, Object?>{
      '_': 'MapPattern',
      ...getLocation(node),
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
      '_': 'MapPatternEntry',
      ...getLocation(node),
      'key': node.key.accept(this),
      'value': node.value.accept(this),
    };
  }

  @override
  Map<String, Object?> visitMethodDeclaration(MethodDeclaration node) {
    return <String, Object?>{
      '_': 'MethodDeclaration',
      ...getLocation(node),
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
      '_': 'MethodInvocation',
      ...getLocation(node),
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
      '_': 'MixinDeclaration',
      ...getLocation(node),
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
      '_': 'NamedExpression',
      ...getLocation(node),
      'expression': node.expression.accept(this),
      'name': node.name.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitNamedType(NamedType node) {
    return <String, Object?>{
      '_': 'NamedType',
      ...getLocation(node),
      if (node.isDeferred) 'isDeferred': node.isDeferred,
      'name': node.name.accept(this),
      if (node.typeArguments != null)
        'typeArguments': node.typeArguments!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitNativeClause(NativeClause node) {
    return <String, Object?>{
      '_': 'NativeClause',
      ...getLocation(node),
      if (node.name != null) 'name': node.name!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitNativeFunctionBody(NativeFunctionBody node) {
    return <String, Object?>{
      '_': 'NativeFunctionBody',
      ...getLocation(node),
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
      '_': 'NullLiteral',
      ...getLocation(node),
    };
  }

  @override
  Map<String, Object?> visitObjectPattern(ObjectPattern node) {
    return <String, Object?>{
      '_': 'ObjectPattern',
      ...getLocation(node),
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
      '_': 'OnClause',
      ...getLocation(node),
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
      '_': 'ParenthesizedExpression',
      ...getLocation(node),
      'expression': node.expression.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitParenthesizedPattern(ParenthesizedPattern node) {
    return <String, Object?>{
      '_': 'ParenthesizedPattern',
      ...getLocation(node),
      'pattern': node.pattern.accept(this),
    };
  }

  @override
  Map<String, Object?> visitPartDirective(PartDirective node) {
    return <String, Object?>{
      '_': 'PartDirective',
      ...getLocation(node),
      'uri': node.uri.accept(this),
    };
  }

  @override
  Map<String, Object?> visitPartOfDirective(PartOfDirective node) {
    return <String, Object?>{
      '_': 'PartOfDirective',
      ...getLocation(node),
      if (node.libraryName != null)
        'libraryName': node.libraryName!.accept(this),
      if (node.uri != null) 'uri': node.uri!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitPatternAssignment(PatternAssignment node) {
    return <String, Object?>{
      '_': 'PatternAssignment',
      ...getLocation(node),
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
      '_': 'PatternVariableDeclaration',
      ...getLocation(node),
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
      '_': 'PatternVariableDeclarationStatement',
      ...getLocation(node),
      'declaration': node.declaration.accept(this),
    };
  }

  @override
  Map<String, Object?> visitPostfixExpression(PostfixExpression node) {
    return <String, Object?>{
      '_': 'PostfixExpression',
      ...getLocation(node),
      'operand': node.operand.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitPostfixPattern(PostfixPattern node) {
    return <String, Object?>{
      '_': 'PostfixPattern',
      ...getLocation(node),
      'operand': node.operand.accept(this),
    };
  }

  @override
  Map<String, Object?> visitPrefixedIdentifier(PrefixedIdentifier node) {
    return <String, Object?>{
      '_': 'PrefixedIdentifier',
      ...getLocation(node),
      'identifier': node.identifier.accept(this),
      if (node.isDeferred) 'isDeferred': node.isDeferred,
      'prefix': node.prefix.accept(this),
      'name': node.name,
    };
  }

  @override
  Map<String, Object?> visitPrefixExpression(PrefixExpression node) {
    return <String, Object?>{
      '_': 'PrefixExpression',
      ...getLocation(node),
      'operand': node.operand.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitPropertyAccess(PropertyAccess node) {
    return <String, Object?>{
      '_': 'PropertyAccess',
      ...getLocation(node),
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
      '_': 'RecordLiteral',
      ...getLocation(node),
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
      '_': 'RecordPattern',
      ...getLocation(node),
      if (node.fields.isNotEmpty)
        'fields': <Map<String, Object?>?>[
          for (var item in node.fields) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitRecordPatternField(RecordPatternField node) {
    return <String, Object?>{
      '_': 'RecordPatternField',
      ...getLocation(node),
      if (node.fieldName != null) 'fieldName': node.fieldName!.accept(this),
      'pattern': node.pattern.accept(this),
    };
  }

  @override
  Map<String, Object?> visitRecordPatternFieldName(
      RecordPatternFieldName node) {
    return <String, Object?>{
      '_': 'RecordPatternFieldName',
      ...getLocation(node),
    };
  }

  @override
  Map<String, Object?> visitRecordTypeAnnotation(RecordTypeAnnotation node) {
    return <String, Object?>{
      '_': 'RecordTypeAnnotation',
      ...getLocation(node),
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
      '_': 'RecordTypeAnnotationNamedField',
      ...getLocation(node),
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
      '_': 'RecordTypeAnnotationNamedFields',
      ...getLocation(node),
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
      '_': 'RecordTypeAnnotationPositionalField',
      ...getLocation(node),
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
      '_': 'RedirectingConstructorInvocation',
      ...getLocation(node),
      'argumentList': node.argumentList.accept(this),
      if (node.constructorName != null)
        'constructorName': node.constructorName!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitRelationalPattern(RelationalPattern node) {
    return <String, Object?>{
      '_': 'RelationalPattern',
      ...getLocation(node),
      'operand': node.operand.accept(this),
    };
  }

  @override
  Map<String, Object?> visitRestPatternElement(RestPatternElement node) {
    return <String, Object?>{
      '_': 'RestPatternElement',
      ...getLocation(node),
      if (node.pattern != null) 'pattern': node.pattern!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitRethrowExpression(RethrowExpression node) {
    return <String, Object?>{
      '_': 'RethrowExpression',
      ...getLocation(node),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitReturnStatement(ReturnStatement node) {
    return <String, Object?>{
      '_': 'ReturnStatement',
      ...getLocation(node),
      if (node.expression != null) 'expression': node.expression!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitScriptTag(ScriptTag node) {
    return <String, Object?>{
      '_': 'ScriptTag',
      ...getLocation(node),
    };
  }

  @override
  Map<String, Object?> visitSetOrMapLiteral(SetOrMapLiteral node) {
    return <String, Object?>{
      '_': 'SetOrMapLiteral',
      ...getLocation(node),
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
      '_': 'ShowCombinator',
      ...getLocation(node),
      if (node.shownNames.isNotEmpty)
        'shownNames': <Map<String, Object?>?>[
          for (var item in node.shownNames) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitSimpleFormalParameter(SimpleFormalParameter node) {
    return <String, Object?>{
      '_': 'SimpleFormalParameter',
      ...getLocation(node),
      if (node.type != null) 'type': node.type!.accept(this),
      if (node.documentationComment != null)
        'documentationComment': node.documentationComment!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitSimpleIdentifier(SimpleIdentifier node) {
    return <String, Object?>{
      '_': 'SimpleIdentifier',
      ...getLocation(node),
      'name': node.name,
    };
  }

  @override
  Map<String, Object?> visitSimpleStringLiteral(SimpleStringLiteral node) {
    return <String, Object?>{
      '_': 'SimpleStringLiteral',
      ...getLocation(node),
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
      '_': 'SpreadElement',
      ...getLocation(node),
      'expression': node.expression.accept(this),
      if (node.isNullAware) 'isNullAware': node.isNullAware,
    };
  }

  @override
  Map<String, Object?> visitStringInterpolation(StringInterpolation node) {
    return <String, Object?>{
      '_': 'StringInterpolation',
      ...getLocation(node),
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
      '_': 'SuperConstructorInvocation',
      ...getLocation(node),
      'argumentList': node.argumentList.accept(this),
      if (node.constructorName != null)
        'constructorName': node.constructorName!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitSuperExpression(SuperExpression node) {
    return <String, Object?>{
      '_': 'SuperExpression',
      ...getLocation(node),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitSuperFormalParameter(SuperFormalParameter node) {
    return <String, Object?>{
      '_': 'SuperFormalParameter',
      ...getLocation(node),
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
      '_': 'SwitchCase',
      ...getLocation(node),
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
      '_': 'SwitchDefault',
      ...getLocation(node),
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
      '_': 'SwitchExpression',
      ...getLocation(node),
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
      '_': 'SwitchExpressionCase',
      ...getLocation(node),
      'expression': node.expression.accept(this),
      'guardedPattern': node.guardedPattern.accept(this),
    };
  }

  @override
  Map<String, Object?> visitSwitchPatternCase(SwitchPatternCase node) {
    return <String, Object?>{
      '_': 'SwitchPatternCase',
      ...getLocation(node),
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
      '_': 'SwitchStatement',
      ...getLocation(node),
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
      '_': 'SymbolLiteral',
      ...getLocation(node),
    };
  }

  @override
  Map<String, Object?> visitThisExpression(ThisExpression node) {
    return <String, Object?>{
      '_': 'ThisExpression',
      ...getLocation(node),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitThrowExpression(ThrowExpression node) {
    return <String, Object?>{
      '_': 'ThrowExpression',
      ...getLocation(node),
      'expression': node.expression.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitTopLevelVariableDeclaration(
      TopLevelVariableDeclaration node) {
    return <String, Object?>{
      '_': 'TopLevelVariableDeclaration',
      ...getLocation(node),
      'variables': node.variables.accept(this),
    };
  }

  @override
  Map<String, Object?> visitTryStatement(TryStatement node) {
    return <String, Object?>{
      '_': 'TryStatement',
      ...getLocation(node),
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
      '_': 'TypeArgumentList',
      ...getLocation(node),
      if (node.arguments.isNotEmpty)
        'arguments': <Map<String, Object?>?>[
          for (var item in node.arguments) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitTypeLiteral(TypeLiteral node) {
    return <String, Object?>{
      '_': 'TypeLiteral',
      ...getLocation(node),
      'type': node.type.accept(this),
      if (node.inConstantContext) 'inConstantContext': node.inConstantContext,
      if (node.isAssignable) 'isAssignable': node.isAssignable,
    };
  }

  @override
  Map<String, Object?> visitTypeParameter(TypeParameter node) {
    return <String, Object?>{
      '_': 'TypeParameter',
      ...getLocation(node),
      if (node.bound != null) 'bound': node.bound!.accept(this),
    };
  }

  @override
  Map<String, Object?> visitTypeParameterList(TypeParameterList node) {
    return <String, Object?>{
      '_': 'TypeParameterList',
      ...getLocation(node),
      if (node.typeParameters.isNotEmpty)
        'typeParameters': <Map<String, Object?>?>[
          for (var item in node.typeParameters) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitVariableDeclaration(VariableDeclaration node) {
    return <String, Object?>{
      '_': 'VariableDeclaration',
      ...getLocation(node),
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
      '_': 'VariableDeclarationList',
      ...getLocation(node),
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
      '_': 'VariableDeclarationStatement',
      ...getLocation(node),
      'variables': node.variables.accept(this),
    };
  }

  @override
  Map<String, Object?> visitWhenClause(WhenClause node) {
    return <String, Object?>{
      '_': 'WhenClause',
      ...getLocation(node),
      'expression': node.expression.accept(this),
    };
  }

  @override
  Map<String, Object?> visitWhileStatement(WhileStatement node) {
    return <String, Object?>{
      '_': 'WhileStatement',
      ...getLocation(node),
      'body': node.body.accept(this),
      'condition': node.condition.accept(this),
    };
  }

  @override
  Map<String, Object?> visitWithClause(WithClause node) {
    return <String, Object?>{
      '_': 'WithClause',
      ...getLocation(node),
      if (node.mixinTypes.isNotEmpty)
        'mixinTypes': <Map<String, Object?>?>[
          for (var item in node.mixinTypes) item.accept(this),
        ],
    };
  }

  @override
  Map<String, Object?> visitYieldStatement(YieldStatement node) {
    return <String, Object?>{
      '_': 'YieldStatement',
      ...getLocation(node),
      'expression': node.expression.accept(this),
    };
  }
}
