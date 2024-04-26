// ignore_for_file: avoid_print
library;

import 'dart:async' show Future, runZonedGuarded;

import 'package:build/build.dart'
    show AssetId, Builder, MultiPackageAssetReader, runBuilder;
import 'package:build_resolvers/build_resolvers.dart' show AnalyzerResolvers;
import 'package:build_test/build_test.dart'
    show
        InMemoryAssetReader,
        InMemoryAssetWriter,
        MultiAssetReader,
        PackageAssetReader,
        RecordingAssetWriter,
        WrittenAssetReader;
import 'package:logging/logging.dart' show Level, Logger;
import 'package:stack_trace/stack_trace.dart' show Trace;
import 'package:svelte_ast/svelte_ast.dart';
import 'package:svelte_builder/src/builders/svelte.dart';

final Map<AssetId, String> sourceAssets = <AssetId, String>{
  AssetId('app', 'web/app.svelte'): r'''
<!-- app.svelte -->
<script context="module">
  const message = 'Hello world!';
</script>
<script>
  // imports
  import 'package:svelte/svelte.dart';

  // properties
  external int count = 0;

  // body
  $: doubled = count * 2;
  $: quadrupled = doubled * 2;

	$: if (count >= 10) {
		print('count is dangerously high!');
		count = 9;
	}

  void handleClick() {
    count += 1;
  }

  const duration = Duration(seconds: 1);

  onMount(() {
    var timer = Timer.periodic(duration, (timer) {
      count += 1;
    });

    return () {
      timer.cancel();
    };
  });
</script>

<p>{message}</p>

<button on:click={handleClick}>
  Clicked {count} {count == 1 ? 'time' : 'times'}
</button>

<p>{count} * 2 = {doubled}</p>
<p>{doubled} * 2 = {quadrupled}</p>
''',
};

final logger = Logger.root
  ..level = Level.ALL
  ..onRecord.listen(print);

Future<void> main() async {
  await runZonedGuarded<Future<void>>(run, (error, stackTrace) {
    if (error is ParseError) {
      print(error.errorCode.message);
      print(error.span.highlight());
    } else {
      print(error);
    }

    print(Trace.format(stackTrace));
  });
}

Future<void> build(
  Builder builder,
  Set<AssetId> assets, {
  required String rootPackage,
  required MultiPackageAssetReader reader,
  required RecordingAssetWriter writer,
}) async {
  assets.add(AssetId(rootPackage, r'web/$web$'));

  var resolvers = AnalyzerResolvers.sharedInstance;

  for (var asset in assets) {
    var inputAssets = <AssetId>{asset};
    await runBuilder(builder, inputAssets, reader, writer, resolvers,
        logger: logger);
  }
}

void printAssets(Map<AssetId, List<int>> assets, [Set<AssetId>? written]) {
  if (written != null) {
    assets.forEach((asset, value) {
      if (written.contains(asset)) {
        print('-- ${asset.package}:${asset.path}');
        print(String.fromCharCodes(value));
      }
    });
  } else {
    assets.forEach((asset, value) {
      print('-- ${asset.package}:${asset.path}');
      print(String.fromCharCodes(value));
    });
  }
}

Future<void> run() async {
  var isolateReader = await PackageAssetReader.currentIsolate();
  var inMemoryReader = InMemoryAssetReader(rootPackage: 'app');
  sourceAssets.forEach(inMemoryReader.cacheStringAsset);

  var inMemoryWriter = InMemoryAssetWriter();
  var writtenReader = WrittenAssetReader(inMemoryWriter);

  var readers = [isolateReader, inMemoryReader, writtenReader];
  var multiReader = MultiAssetReader(readers);

  print('> SVELTE '.padRight(80, '='));

  await build(
    const SvelteBuilder(),
    <AssetId>{AssetId('app', 'web/app.svelte')},
    rootPackage: 'app',
    reader: multiReader,
    writer: inMemoryWriter,
  );

  printAssets(inMemoryWriter.assets);
}
