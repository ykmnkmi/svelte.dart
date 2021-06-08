import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

// basic
// const String source = '<h1>Hello world!</h1>';

// adding data
const String source = '<h1>Hello { name.toUpperCase() }!</h1>';

void main() {
  try {
    final library = parse('App', source);
    print(compile(library));
  } catch (error, stack) {
    print(error);
    print(Trace.format(stack));
  }
}
