import 'package:nutty/compiler.dart';
import 'package:stack_trace/stack_trace.dart';

void main() {
  var source = 'Hello <!-- name -->!';
  var sourceUrl = 'index.nutty';

  try {
    var nodes = parse(source, sourceUrl: sourceUrl);

    for (var node in nodes) {
      print(node.runtimeType);

      if (node is Text) {
        var text = node.text;
        print('text: $text');
      } else if (node is Comment) {
        var text = node.text;
        print('comment: $text');
      }
    }
  } catch (error, stackTrace) {
    print(error);
    print(Trace.from(stackTrace));
  }
}
