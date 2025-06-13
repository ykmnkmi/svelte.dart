// ignore_for_file: avoid_print
library;

import 'dart:async' show Future, runZonedGuarded;

import 'package:build/build.dart'
    show AssetId, Builder, BuilderOptions, MultiPackageAssetReader, runBuilder;
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
import 'package:svelte_ast/svelte_ast.dart' show ParseError;
import 'package:svelte_builder/svelte_builder.dart';

final Map<AssetId, String> sourceAssets = <AssetId, String>{
  AssetId('app', 'web/app.svelte'): '''
<!-- app.svelte -->
<script context="module">
  const duration = Duration(seconds: 1);
</script>
<script>
  // imports
  import 'package:svelte/svelte.dart';

  // properties
  external int step = 1;

  // body
  var count = state<int>(0);
  var doubled = derived<int>(count * 2);
  var quadrupled = derived<int>(doubled * 2);

	effect(() {
    if (count >= 10) {
      print('count is dangerously high!');
      count = 9;
    }
  });

  void handleClick() {
    count += 1;
  }

  onMount(() {
    var timer = Timer.periodic(duration, (timer) {
      count += 1;
    });

    return () {
      timer.cancel();
    };
  });
</script>

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
      print(error.message);
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

  AnalyzerResolvers resolvers = AnalyzerResolvers.sharedInstance;

  for (AssetId asset in assets) {
    await runBuilder(
      builder,
      <AssetId>{asset},
      reader,
      writer,
      resolvers,
      logger: logger,
    );
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
  PackageAssetReader isolateReader = await PackageAssetReader.currentIsolate();
  InMemoryAssetReader inMemoryReader = InMemoryAssetReader(rootPackage: 'app');
  sourceAssets.forEach(inMemoryReader.cacheStringAsset);

  InMemoryAssetWriter inMemoryWriter = InMemoryAssetWriter();
  WrittenAssetReader writtenReader = WrittenAssetReader(inMemoryWriter);

  List<MultiPackageAssetReader> readers = [
    isolateReader,
    inMemoryReader,
    writtenReader,
  ];

  MultiAssetReader multiReader = MultiAssetReader(readers);

  print('> Transform '.padRight(80, '='));

  await build(
    transformer(BuilderOptions.empty),
    <AssetId>{AssetId('app', 'web/app.svelte')},
    rootPackage: 'app',
    reader: multiReader,
    writer: inMemoryWriter,
  );

  printAssets(inMemoryWriter.assets);
}
