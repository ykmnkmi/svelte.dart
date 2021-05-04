import 'package:piko/compiler.dart';

const String source = 'hello world!';

void main() {
  try {
    final fragment = parse(source);
    print(fragment);
    print(compileFragment(fragment, generate: Generate.dom, name: 'App'));
  } catch (error, stackTrace) {
    print(error);
    print(stackTrace);
  }
}
