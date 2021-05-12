import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

const String source = '<p id="title">hello { name }!</p>';

void main() {
  try {
    final fragment = parse(source);
    print(fragment);
    print(compileFragment(fragment, 'App'));
  } catch (error, stackTrace) {
    print(error);
    print(Trace.format(stackTrace));
  }
}
