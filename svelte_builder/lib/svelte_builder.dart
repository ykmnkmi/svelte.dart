import 'package:build/build.dart' show Builder, BuilderOptions;
import 'package:svelte_builder/src/builders/meta.dart';
import 'package:svelte_builder/src/builders/svelte.dart';

Builder metaBuilder(BuilderOptions options) {
  return const MetaBuilder();
}

Builder svelteBuilder(BuilderOptions options) {
  return const SvelteBuilder();
}
