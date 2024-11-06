import 'dart:mirrors';

typedef Enter<T extends Object> = void Function(T? parent, T node);

typedef Leave<T extends Object> = void Function(T? parent, T node);

// TODO(ast): test walker
void walk<T extends Object>(T node, {Enter<T>? enter, Leave<T>? leave}) {
  if (enter == null && leave == null) {
    return;
  }

  TypeMirror typeTMirror = reflectType(T);
  TypeMirror typeTListMirror = reflectType(List<T>);

  Set<T> seen = Set<T>.identity();

  void visit(T? parent, T node) {
    if (seen.add(node)) {
      if (enter != null) {
        enter(parent, node);
      }

      InstanceMirror instanceMirror = reflect(node);
      ClassMirror classMirror =
          instanceMirror.type.originalDeclaration as ClassMirror;

      void visitEach(Symbol symbol, DeclarationMirror declarationMember) {
        if (declarationMember.isPrivate) {
          return;
        }

        TypeMirror returnType;

        if (declarationMember is MethodMirror && declarationMember.isGetter) {
          returnType = declarationMember.returnType;
        } else if (declarationMember is VariableMirror) {
          returnType = declarationMember.type;
        } else {
          return;
        }

        if (returnType.isSubtypeOf(typeTListMirror)) {
          InstanceMirror fieldMirror = instanceMirror.getField(symbol);

          if (fieldMirror.hasReflectee) {
            List<T?>? field = fieldMirror.reflectee as List<T?>?;

            if (field == null || field.isEmpty) {
              return;
            }

            for (T? value in field) {
              if (value == null || identical(node, value)) {
                continue;
              }

              visit(node, value);
            }
          }
        } else if (returnType.isSubtypeOf(typeTMirror)) {
          InstanceMirror fieldMirror = instanceMirror.getField(symbol);

          if (fieldMirror.hasReflectee) {
            T? field = fieldMirror.reflectee as T?;

            if (field == null || identical(node, field)) {
              return;
            }

            visit(node, field);
          }
        }
      }

      classMirror.declarations.forEach(visitEach);

      if (leave != null) {
        leave(parent, node);
      }

      seen.remove(node);
    }
  }

  visit(null, node);
}

// TODO(ast): test walker
void walkAll<T extends Object>(
  List<T> nodes, {
  Enter<T>? enter,
  Leave<T>? leave,
}) {
  for (T node in nodes) {
    walk(node, enter: enter, leave: leave);
  }
}
