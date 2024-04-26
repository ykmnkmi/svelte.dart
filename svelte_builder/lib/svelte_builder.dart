import 'package:build/build.dart' show Builder, BuilderOptions;
import 'package:svelte_builder/src/builders/svelte.dart';

Builder svelteBuilder(BuilderOptions options) {
  return const SvelteBuilder();
}
