import 'package:piko/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

// basic
// const String source = '<h1>Hello world!</h1>';

// adding data
// const String source = '<h1>Hello { name.toUpperCase() }!</h1>';

// dynamic data
// const String source = '<img {src} alt="{name} dances.">';

// styling: final style = {'color': 'purple', 'font-family': '\'Comic Sans MS\', cursive', 'font-size': '2em'};
// const String source = '<p {style}>This is a paragraph.</p>';
// const String source = '<p style={style}>This is a paragraph.</p>';

// nested components
// const String nested = '<b>paragraph</b>';
const String source = '<p>This is a <Nested/>.</p>';

void main() {
  try {
    final library = parse('App', source);
    print(compile(library));
  } catch (error, stack) {
    print(error);
    print(Trace.format(stack));
  }
}
