import 'package:nutty/runtime.dart';

import 'nested.dart' deferred as _;

Future<Component> nestedDefferedFactory() async {
  await _.loadLibrary();
  return _.Nested();
}
