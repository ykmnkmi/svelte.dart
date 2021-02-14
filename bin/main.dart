import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

void main() {
  try {
    print(parse('<button on:click={handleClick}>Clicked {{ count }} {{ count == 1 ? \'time\' : \'times\' }}</button>'));
  } catch (e, st) {
    print(e);
    print(Trace.from(st).terse);
  }
}
