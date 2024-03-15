import 'dart:mirrors';

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

bool isCoreValue(TypeMirror typeMirror) {
  return identical(typeMirror, _object) ||
      identical(typeMirror, _bool) ||
      identical(typeMirror, _num) ||
      identical(typeMirror, _string) ||
      (_list.isSubtypeOf(typeMirror) &&
          typeMirror.typeArguments.any(isCoreValue)) ||
      (_map.isSubtypeOf(typeMirror) && _map.typeArguments.any(isCoreValue));
}

Object? getValue(InstanceMirror instance, Symbol symbol) {
  try {
    InstanceMirror field = instance.getField(symbol);
    return field.reflectee;
  } catch (error) {
    return '@error { $error }';
  }
}
