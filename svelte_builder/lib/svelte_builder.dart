import 'package:build/build.dart' show Builder, BuilderOptions;
import 'package:svelte_builder/src/builders/meta.dart';

Builder metaBuilder(BuilderOptions options) {
  return const MetaBuilder();
}
