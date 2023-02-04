import 'package:svelte/src/runtime/props.dart';

const String spreadKey = r'$$spread';

Props getSpreadUpdate(List<Props> levels, List<Props?> updates) {
  var update = <String, Object?>{};

  var toNullOut = <String>{};
  var accountedFor = <String>{spreadKey};

  for (var i = levels.length; i >= 0; i -= 1) {
    var oldProps = levels[i];
    var newProps = updates[i];

    if (newProps != null) {
      for (var key in oldProps.keys) {
        if (!newProps.containsKey(key)) {
          toNullOut.add(key);
        }

        for (var key in newProps.keys) {
          if (!accountedFor.contains(key)) {
            update[key] = newProps[key];
            accountedFor.add(key);
          }
        }

        levels[i] = newProps;
      }
    } else {
      for (var key in oldProps.keys) {
        accountedFor.add(key);
      }
    }
  }

  // TODO(runtime): not ported part
  // for (const key in to_null_out) {
	// 	 if (!(key in update)) update[key] = undefined;
	// }

  return update;
}

Props getSpreadProps(Object? props) {
  if (props == null || props is! Map<String, Object?>) {
    return const <String, Object?>{};
  }

  return props;
}
