import 'constants.dart';

bool closingTagOmitted(String current, String? next) {
  if (disallowedContents.containsKey(current)) {
    if (next == null || disallowedContents[current]!.contains(next)) {
      return true;
    }
  }

  return false;
}

bool isVoid(String tag) {
  tag = tag.toLowerCase();
  return RegExp('^(?:$voids)\$').hasMatch(tag) || tag == '!doctype';
}
