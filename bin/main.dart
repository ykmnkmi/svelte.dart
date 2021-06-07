import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

// basic
const String source = '<h1>Hello {name}!</h1>';

// dynamic attributes
// const String source = '<img {src} alt="{name} dancing"/>';

void main() {
  try {
    final fragments = parse(source);

    for (var i = 0; i < fragments.length; i++) {
      final title = '${fragments[i]}';
      print('-' * title.length);
      print('$title\n');
      print(compileFragment('App$i', fragments[i]));
    }
  } catch (error, stack) {
    print(error);
    print(Trace.format(stack));
  }
}
