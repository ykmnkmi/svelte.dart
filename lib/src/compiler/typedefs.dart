import 'nodes.dart';
import 'parser.dart';

typedef Reader = Node? Function(Parser parser, Map<String, Node> attributes);
