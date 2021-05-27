import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

const String source = '<button on:click={ handleClick }>Clicked { count } { count == 1 ? \'time\' : \'times\' }</button>';
// const String source = '<p>hello { name }!</p>';

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
