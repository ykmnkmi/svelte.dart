import 'package:path/path.dart' as path;

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    return;
  }

  for (var i = 0; i < arguments.length; i++) {
    arguments[i] = path.absolute(arguments[i]);
  }
}
