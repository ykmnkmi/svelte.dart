const String _spreadKey = '__spread';

Map<String, Object?> getSpreadUpdate(
  List<Map<String, Object?>> levels,
  List<Map<String, Object?>?> updates,
) {
  Map<String, Object?> update = <String, Object?>{};

  Set<String> toNullOut = <String>{};
  Set<String> accountedFor = <String>{_spreadKey};

  for (int i = levels.length; i >= 0; i -= 1) {
    Map<String, Object?> oldProps = levels[i];
    Map<String, Object?>? newProps = updates[i];

    if (newProps != null) {
      for (String key in oldProps.keys) {
        if (!newProps.containsKey(key)) {
          toNullOut.add(key);
        }

        for (String key in newProps.keys) {
          if (!accountedFor.contains(key)) {
            update[key] = newProps[key];
            accountedFor.add(key);
          }
        }

        levels[i] = newProps;
      }
    } else {
      for (String key in oldProps.keys) {
        accountedFor.add(key);
      }
    }
  }

  // TODO(runtime): not ported
  // for (const key in to_null_out) {
  // 	 if (!(key in update)) update[key] = undefined;
  // }

  return update;
}

Map<String, Object?> getSpreadProps(Object? props) {
  if (props == null || props is! Map<String, Object?>) {
    return const <String, Object?>{};
  }

  return props;
}
