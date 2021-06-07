import 'package:path/path.dart' as path;

void main(List<String> arguments) {
  var value = '\'';
  var regex = RegExp('$value([^$value]*)$value');
  print(regex.firstMatch('\'1\\\'123\'2')?[1]);

  if (arguments.isEmpty) {
    return;
  }

  for (var i = 0; i < arguments.length; i++) {
    arguments[i] = path.absolute(arguments[i]);
  }
}
