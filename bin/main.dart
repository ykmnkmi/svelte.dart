import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

// hello world
// const String source = '<h1>Hello {name}!</h1>';

// dynamic attributes
const String source = '<img {src} alt="{name} dancing">';

void main() {
  try {
    final fragment = parse(source);
    print(fragment);
    print(compileFragment(fragment, 'App'));
  } catch (error, stack) {
    print(error);
    print(Trace.format(stack));
  }
}
