import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

const String source = '<p>hello world!</p>';

void main() {
  try {
    print(parse(source));
  } catch (e, st) {
    print(e);
    print(Trace.from(st).terse);
  }
}
