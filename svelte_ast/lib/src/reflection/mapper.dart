import 'dart:mirrors';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:csslib/visitor.dart';

const Set<Symbol> _ignored = <Symbol>{
  #immediatelyNegated, // null check error
  #isQualified, // null check error
};

final TypeMirror _object = reflectType(Object);

final TypeMirror _bool = reflectType(bool);

final TypeMirror _num = reflectType(num);

final TypeMirror _string = reflectType(String);

final TypeMirror _list = reflectType(List);

final TypeMirror _map = reflectType(Map);

final TypeMirror _astNodeTypeMirror = reflectType(AstNode);

final TypeMirror _nodeListTypeMirror = reflectType(List<AstNode>);

final TypeMirror _tokenTypeMirror = reflectType(Token);

final TypeMirror _csslibTreeNode = reflectType(TreeNode);

final TypeMirror _csslibListTreeNode = reflectType(List<TreeNode>);

bool _isDeprecated(DeclarationMirror declaration) {
  return declaration.metadata.any((element) {
    return element.reflectee is Deprecated;
  });
}

bool _isCoreValue(TypeMirror typeMirror) {
  return identical(typeMirror, _object) ||
      identical(typeMirror, _bool) ||
      identical(typeMirror, _num) ||
      identical(typeMirror, _string) ||
      (_list.isSubtypeOf(typeMirror) &&
          typeMirror.typeArguments.any(_isCoreValue)) ||
      (_map.isSubtypeOf(typeMirror) && _map.typeArguments.any(_isCoreValue));
}

String _getClassName(InstanceMirror instance) {
  ClassMirror klass = instance.type;
  return MirrorSystem.getName(klass.simpleName);
}

Object? _getValue(InstanceMirror instance, Symbol symbol) {
  InstanceMirror field = instance.getField(symbol);
  return field.reflectee;
}

List<Object?> _seen = <Object?>[];

bool _checkCycle(Object? object) {
  for (int i = _seen.length - 1; i >= 0; i--) {
    if (identical(object, _seen[i])) {
      return true;
    }
  }

  _seen.add(object);
  return false;
}

void _removeSeen(Object? object) {
  assert(_seen.isNotEmpty);
  assert(identical(_seen.last, object));
  _seen.removeLast();
}

Object _getAstNode(AstNode node) {
  if (_checkCycle(node)) {
    return '@seen';
  }

  Map<String, Object?> result = <String, Object?>{
    'start': node.offset,
    'end': node.end,
  };

  InstanceMirror instanceMirror = reflect(node);
  ClassMirror typeMirror = instanceMirror.type;
  TypeMirror originalDeclaration = typeMirror.originalDeclaration;

  if (originalDeclaration is ClassMirror) {
    typeMirror = originalDeclaration;
  }

  result['class'] = MirrorSystem.getName(typeMirror.simpleName);

  void forEach(Symbol symbol, DeclarationMirror declarationMirror) {
    if (declarationMirror.isPrivate ||
        _ignored.contains(symbol) ||
        _isDeprecated(declarationMirror)) {
      return;
    }

    String name = MirrorSystem.getName(symbol);
    TypeMirror type;

    if (declarationMirror is MethodMirror && declarationMirror.isGetter) {
      type = declarationMirror.returnType;
    } else if (declarationMirror is VariableMirror) {
      type = declarationMirror.type;
    } else {
      return;
    }

    if (type.isSubtypeOf(_astNodeTypeMirror)) {
      InstanceMirror fieldMirror = instanceMirror.getField(symbol);
      AstNode? field = fieldMirror.reflectee as AstNode?;

      if (field == null) {
        result[name] = null;
      } else {
        result[name] = _getAstNode(field);
      }
    } else if (type.isSubtypeOf(_nodeListTypeMirror)) {
      InstanceMirror nodes = instanceMirror.getField(symbol);
      Object? values = nodes.reflectee;

      if (values == null) {
        result[name] = null;
      } else {
        result[name] = <Object?>[
          for (AstNode node in values as List<AstNode>) mapper(node),
        ];
      }
    } else if (type.isSubtypeOf(_tokenTypeMirror)) {
      InstanceMirror fieldMirror = instanceMirror.getField(symbol);
      Token? token = fieldMirror.reflectee as Token?;

      if (token == null) {
        result[name] = null;
      } else {
        result[name] = <String, Object?>{
          'start': token.offset,
          'end': token.end,
          'type': '${token.type}',
          'lexeme': token.lexeme,
        };
      }
    } else if (_isCoreValue(type)) {
      result[name] = _getValue(instanceMirror, symbol);
    }
  }

  typeMirror.declarations.forEach(forEach);
  _removeSeen(node);
  return result;
}

Map<String, Object?> _getTreeNode(InstanceMirror instance) {
  InstanceMirror span = instance.getField(#span);
  Map<String, Object?> result = <String, Object?>{};

  if (span.reflectee == null) {
    result['start'] = null;
    result['end'] = null;
  } else {
    result['start'] = _getValue(span.getField(#start), #offset);
    result['end'] = _getValue(span.getField(#end), #offset);
  }

  _fillTreeNode(instance, result);
  return result;
}

void _fillTreeNode(
  InstanceMirror instance,
  Map<String, Object?> result,
) {
  void forEach(Symbol symbol, DeclarationMirror declaration) {
    if (declaration.isPrivate ||
        _ignored.contains(symbol) ||
        _isDeprecated(declaration)) {
      return;
    }

    String name = MirrorSystem.getName(symbol);
    TypeMirror type;

    if (declaration is MethodMirror && declaration.isGetter) {
      type = declaration.returnType;
    } else if (declaration is VariableMirror) {
      type = declaration.type;
    } else {
      return;
    }

    if (type.isSubtypeOf(_csslibTreeNode)) {
      InstanceMirror node = instance.getField(symbol);

      if (node.reflectee == null) {
        result[name] = null;
      } else {
        result[name] = _getTreeNode(node);
      }
    } else if (type.isSubtypeOf(_csslibListTreeNode)) {
      InstanceMirror nodes = instance.getField(symbol);
      Object? values = nodes.reflectee;

      if (values == null) {
        result[name] = null;
      } else {
        result[name] = <Object?>[
          for (var node in values as List<TreeNode>) mapper(node),
        ];
      }
    } else if (_isCoreValue(type)) {
      result[name] = _getValue(instance, symbol);
    }
  }

  ClassMirror type = instance.type;
  result['class'] = MirrorSystem.getName(type.simpleName);
  type.declarations.forEach(forEach);

  for (ClassMirror klass in type.superinterfaces) {
    klass.declarations.forEach(forEach);
  }
}

Object? mapper(Object? node) {
  if (node == null) {
    return null;
  }

  if (node is AstNode) {
    return _getAstNode(node);
  }

  // if (node is TreeNode) {
  //   return _getTreeNode(node);
  // }

  throw UnimplementedError('${node.runtimeType}');
}
