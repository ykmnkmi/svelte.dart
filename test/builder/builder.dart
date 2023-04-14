import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:svelte/builders.dart';

const Map<String, Object> assets = <String, Object>{
  'svelte|web/App.svelte': '''
<p>hello world!</p>
''',
};

const SvelteBuilder svelteBuilder = SvelteBuilder();

Future<void> main() async {
  var writer = InMemoryAssetWriter();

  await testBuilder(
    svelteBuilder,
    assets,
    reader: PackageAssetReader.forPackageRoot('.', 'svelte'),
    writer: writer,
    rootPackage: 'svelte',
  );

  writer.assets.forEach((key, value) {
    stdout
      ..writeln(key)
      ..add(value)
      ..writeln();
  });
}
