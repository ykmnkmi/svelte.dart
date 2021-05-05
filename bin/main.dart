import 'package:piko/compiler.dart';

const String source = 'hello {name}!';

void main() {
  try {
    final fragment = parse(source);
    print(fragment);
    print(compileFragment(fragment, name: 'App'));
  } catch (error, stackTrace) {
    print(error);
    print(stackTrace);
  }
}
