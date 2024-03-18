import 'dart:mirrors';

import 'package:csslib/visitor.dart';
import 'package:source_span/source_span.dart';
import 'package:svelte_ast/src/reflection/shared.dart';

const Set<Symbol> _ignored = <Symbol>{};

final TypeMirror _treeNodeTypeMirror = reflectType(TreeNode);

final TypeMirror _nodeListTypeMirror = reflectType(List<TreeNode>);

final TypeMirror _sourceSpanTypeMirror = reflectType(SourceSpan);

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

// TODO(css): Handle dynamic type
Object css(TreeNode node) {
  if (_checkCycle(node)) {
    return _i == 0 ? '@seen { self }' : '@seen';
  }

  SourceSpan? span = node.span;

  InstanceMirror instanceMirror = reflect(node);
  ClassMirror classMirror = instanceMirror.type;
  List<ClassMirror> superinterfaces = classMirror.superinterfaces;

  Map<String, Object?> result = <String, Object?>{
    '@class': MirrorSystem.getName(classMirror.simpleName),
    '@toString': '$node',
    'start': span?.start.offset,
    'end': span?.end.offset,
  };

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

    if (type.isSubtypeOf(_treeNodeTypeMirror)) {
      InstanceMirror fieldMirror = instanceMirror.getField(symbol);
      TreeNode? field = fieldMirror.reflectee as TreeNode?;

      if (field == null) {
        result[name] = null;
      } else {
        result[name] = css(field);
      }
    } else if (type.isSubtypeOf(_nodeListTypeMirror)) {
      InstanceMirror nodes = instanceMirror.getField(symbol);
      Object? values = nodes.reflectee;

      if (values == null) {
        result[name] = null;
      } else {
        List<TreeNode> nodes = values as List<TreeNode>;
        result[name] = nodes.map<Object?>(css).toList();
      }
    } else if (type.isSubtypeOf(_sourceSpanTypeMirror)) {
      InstanceMirror fieldMirror = instanceMirror.getField(symbol);
      SourceSpan? span = fieldMirror.reflectee as SourceSpan?;

      if (span == null) {
        result[name] = null;
      } else {
        result[name] = <String, Object?>{
          'start': span.start.offset,
          'end': span.end.offset,
          'lexeme': span.text,
        };
      }
    } else if (isEncodable(type)) {
      result[name] = getValue(instanceMirror, symbol);
    }
  }

  classMirror.declarations.forEach(forEach);

  for (var superinterface in superinterfaces) {
    superinterface.declarations.forEach(forEach);
  }

  _removeSeen(node);
  return result;
}
