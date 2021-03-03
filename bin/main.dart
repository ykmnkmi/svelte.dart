import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

void main() {
  try {
    print(parse('Hello { count !'));
  } catch (e, st) {
    print(e);
    print(Trace.from(st).terse);
  }
}
