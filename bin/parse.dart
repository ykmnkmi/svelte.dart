import 'package:path/path.dart' as path;

void main(List<String> arguments) {
  print((pop<int>(1)).bitLength);

  if (arguments.isEmpty) {
    return;
  }

  for (var i = 0; i < arguments.length; i++) {
    arguments[i] = path.absolute(arguments[i]);
  }
}

T pop<T extends num?>(num n) {
  return n as T;
}
