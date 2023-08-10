import 'dart:mirrors';

import 'package:analyzer/dart/ast/ast.dart' as analyzer show AstNode, NodeList;
import 'package:analyzer/dart/ast/token.dart' as analyzer show Token;
import 'package:csslib/visitor.dart' as csslib show TreeNode;

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

final TypeMirror _analyzerAstNode = reflectType(analyzer.AstNode);

final TypeMirror _analyzerNodeList = reflectType(analyzer.NodeList);

final TypeMirror _analyzerToken = reflectType(analyzer.Token);

final TypeMirror _csslibTreeNode = reflectType(csslib.TreeNode);

final TypeMirror _csslibListTreeNode = reflectType(List<csslib.TreeNode>);

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
  var klass = instance.type;
  return MirrorSystem.getName(klass.simpleName);
}

Object? _getValue(InstanceMirror instance, Symbol symbol) {
  var field = instance.getField(symbol);
  return field.reflectee;
}

Map<String, Object?> _getAstNode(InstanceMirror instance) {
  var result = <String, Object?>{
    'start': _getValue(instance, #offset),
    'end': _getValue(instance, #end),
  };

  _fillAstNode(instance, result);
  return result;
}

List<Object?> _seen = <Object?>[];

bool _checkCycle(Object? object) {
  for (int i = _seen.length - 1; i >= 0; i--) {
    if (identical(object, _seen[i]) || object == _seen[i]) {
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

void _fillAstNode(
  InstanceMirror instance,
  Map<String, Object?> result,
) {
  void forEach(Symbol symbol, DeclarationMirror declaration) {
    if (declaration.isPrivate ||
        _ignored.contains(symbol) ||
        _isDeprecated(declaration)) {
      return;
    }

    var name = MirrorSystem.getName(symbol);

    TypeMirror type;

    if (declaration is MethodMirror && declaration.isGetter) {
      type = declaration.returnType;
    } else if (declaration is VariableMirror) {
      type = declaration.type;
    } else {
      return;
    }

    if (type.isSubtypeOf(_analyzerAstNode)) {
      var node = instance.getField(symbol);

      if (node.reflectee == null) {
        result[name] = null;
      } else {
        if (_checkCycle(node.reflectee)) {
          result[name] = '@seen';
          return;
        }

        result[name] = _getAstNode(node);
        _removeSeen(node.reflectee);
      }

      return;
    }

    if (type.isSubtypeOf(_analyzerNodeList)) {
      var nodes = instance.getField(symbol);
      var values = nodes.reflectee;

      if (values == null) {
        result[name] = null;
      } else {
        result[name] = <Object?>[
          for (var node in values as analyzer.NodeList) mapper(node),
        ];
      }

      return;
    }

    if (identical(type, _analyzerToken)) {
      var token = instance.getField(symbol);

      if (token.reflectee == null) {
        result[name] = null;
      } else {
        result[name] = <String, Object?>{
          'start': _getValue(token, #offset),
          'end': _getValue(token, #end),
          'type': _getValue(token, #type).toString(),
          'lexeme': _getValue(token, #lexeme),
        };
      }

      return;
    }

    if (_isCoreValue(type)) {
      result[name] = _getValue(instance, symbol);
      return;
    }
  }

  ClassMirror type = instance.type;

  if (type.superinterfaces case [..., var typeInterface]) {
    result['class'] = MirrorSystem.getName(typeInterface.simpleName);
    typeInterface.declarations.forEach(forEach);

    for (ClassMirror klass in typeInterface.superinterfaces) {
      klass.declarations.forEach(forEach);
    }
  }

  // for (var superinterface in instance.type.superinterfaces) {
  //   print((superinterface, superinterface.superclass, superinterface.superinterfaces));
  // }
}

Map<String, Object?> _getTreeNode(InstanceMirror instance) {
  var span = instance.getField(#span);
  var result = <String, Object?>{};

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

    var name = MirrorSystem.getName(symbol);

    TypeMirror type;

    if (declaration is MethodMirror && declaration.isGetter) {
      type = declaration.returnType;
    } else if (declaration is VariableMirror) {
      type = declaration.type;
    } else {
      return;
    }

    if (type.isSubtypeOf(_csslibTreeNode)) {
      var node = instance.getField(symbol);

      if (node.reflectee == null) {
        result[name] = null;
      } else {
        result[name] = _getTreeNode(node);
      }

      return;
    }

    if (type.isSubtypeOf(_csslibListTreeNode)) {
      var nodes = instance.getField(symbol);
      var values = nodes.reflectee;

      if (values == null) {
        result[name] = null;
      } else {
        result[name] = <Object?>[
          for (var node in values as List<csslib.TreeNode>) mapper(node),
        ];
      }

      if (_isCoreValue(type)) {
        result[name] = _getValue(instance, symbol);
        return;
      }

      return;
    }
  }

  ClassMirror type = instance.type;

  result['class'] = MirrorSystem.getName(type.simpleName);
  type.declarations.forEach(forEach);

  for (ClassMirror klass in type.superinterfaces) {
    klass.declarations.forEach(forEach);
  }
}

Object? mapper(Object? object) {
  if (object == null) {
    return null;
  }

  var instance = reflect(object);

  if (object is analyzer.AstNode) {
    return _getAstNode(instance);
  }

  if (object is csslib.TreeNode) {
    return _getTreeNode(instance);
  }

  throw UnimplementedError(_getClassName(instance));
}
