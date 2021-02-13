import 'nodes.dart';
import 'parser.dart';

void text(Parser parser) {
  final start = parser.index;

  while (!parser.isDone && !parser.match('{') && !parser.match('<')) {
    parser.index += 1;
  }

  parser.add(Text(parser.template.substring(start, parser.index)));
}
