import 'dart:mirrors';

typedef Enter<T extends Object> = void Function(T node);

typedef Leave<T extends Object> = void Function(T node);

void walk<T extends Object>(T node, {Enter? enter, Leave? leave}) {
  if (enter == null && leave == null) {
    return;
  }

  TypeMirror typeTMirror = reflectType(T);
  Set<T> seen = Set<T>.identity();

  void visitor(T node) {
    if (seen.add(node)) {
      if (enter != null) {
        enter(node);
      }

      var instanceMirrot = reflect(node);
      var classMirror = instanceMirrot.type;

      classMirror.instanceMembers.forEach((symbol, instanceMember) {
        if (instanceMember.isPrivate || !instanceMember.isGetter) {
          return;
        }

        if (instanceMember.returnType.isSubtypeOf(typeTMirror)) {
          InstanceMirror fieldMirror = instanceMirrot.getField(symbol);

          if (fieldMirror.hasReflectee) {
            var field = fieldMirror.reflectee;

            if (field == null || identical(node, field)) {
              return;
            }

            visitor(field as T);
          }
        }
      });

      if (leave != null) {
        leave(node);
      }

      seen.remove(node);
    }
  }

  visitor(node);
}
