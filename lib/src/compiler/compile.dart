import 'compile/dom.dart';
import 'compile/program.dart';
import 'compile/ssr.dart';
import 'compile/utils.dart';
import 'nodes.dart';
import 'parser.dart';

enum Generate {
  dom,
  ssr,
}

Program? compile(String source, {Generate? generate, String name = 'Component'}) {
  final fragment = parse(source);
  return compileFragment(fragment, generate: generate, name: name);
}

Program? compileFragment(Fragment fragment, {Generate? generate, String name = 'Component', bool preserveComments = false}) {
  if (!preserveComments) {
    removeComments(fragment);
  }

  trim(fragment);

  switch (generate) {
    case Generate.dom:
      return dom(name, fragment);
    case Generate.ssr:
      return ssr(name, fragment);
    default:
      return null;
  }
}
