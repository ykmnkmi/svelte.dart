import 'dart:mirrors';

import 'package:csslib/visitor.dart';

final TypeMirror _object = reflectType(Object);

final TypeMirror _bool = reflectType(bool);

final TypeMirror _num = reflectType(num);

final TypeMirror _string = reflectType(String);

final TypeMirror _list = reflectType(List);

final TypeMirror _map = reflectType(Map);

bool _isDeprecated(InstanceMirror instance) {
  return instance.reflectee is Deprecated;
}

bool isDeprecated(DeclarationMirror declaration) {
  return declaration.metadata.any(_isDeprecated);
}

bool isEncodable(TypeMirror typeMirror) {
  return identical(typeMirror, _bool) ||
      identical(typeMirror, _string) ||
      typeMirror.isSubtypeOf(_num) ||
      (typeMirror.isSubtypeOf(_list) &&
          typeMirror.typeArguments.any(isEncodable)) ||
      (typeMirror.isSubtypeOf(_map) && _map.typeArguments.any(isEncodable));
}

bool isObject(TypeMirror typeMirror) {
  return identical(typeMirror, _object);
}

Object? getValue(InstanceMirror instance, Symbol symbol) {
  try {
    InstanceMirror field = instance.getField(symbol);
    Object? reflectee = field.reflectee;
    return reflectee is Identifier ? '@Identifier' : reflectee;
  } catch (error) {
    return '@error { $error }';
  }
}
