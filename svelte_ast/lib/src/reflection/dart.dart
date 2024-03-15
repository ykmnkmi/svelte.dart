import 'dart:mirrors';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:svelte_ast/src/reflection/shared.dart';

const Set<Symbol> _ignored = <Symbol>{
  #parent,
  #root,
  #unlabeled,
};

final TypeMirror _astNodeTypeMirror = reflectType(AstNode);

final TypeMirror _nodeListTypeMirror = reflectType(List<AstNode>);

final TypeMirror _tokenTypeMirror = reflectType(Token);

List<Object?> _seen = <Object?>[];
int _i = 0;

bool _checkCycle(Object? object) {
  for (_i = _seen.length - 1; _i >= 0; _i--) {
    if (identical(object, _seen[_i])) {
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

Object dart(AstNode node) {
  if (_checkCycle(node)) {
    return _i == 0 ? '@seen { self }' : '@seen';
  }

  Map<String, Object?> result = <String, Object?>{
    'start': node.offset,
    'end': node.end,
  };

  InstanceMirror instanceMirror = reflect(node);
  ClassMirror classMirror = instanceMirror.type;
  List<ClassMirror> superinterfaces = classMirror.superinterfaces;
  ClassMirror interface = superinterfaces.first;

  result['class'] = MirrorSystem.getName(interface.simpleName);
  result['toString'] = '$node';

  void forEach(Symbol symbol, DeclarationMirror declarationMirror) {
    if (declarationMirror.isPrivate ||
        _ignored.contains(symbol) ||
        isDeprecated(declarationMirror)) {
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
        result[name] = dart(field);
      }
    } else if (type.isSubtypeOf(_nodeListTypeMirror)) {
      InstanceMirror nodes = instanceMirror.getField(symbol);
      Object? values = nodes.reflectee;

      if (values == null) {
        result[name] = null;
      } else {
        List<AstNode> nodes = values as List<AstNode>;
        result[name] = nodes.map<Object?>(dart).toList();
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
    } else if (isCoreValue(type)) {
      result[name] = getValue(instanceMirror, symbol);
    }
  }

  classMirror.declarations.forEach(forEach);

  for (var superinterface in interface.superinterfaces) {
    superinterface.declarations.forEach(forEach);
  }

  _removeSeen(node);
  return result;
}
