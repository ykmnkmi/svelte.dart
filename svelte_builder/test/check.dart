// ignore_for_file: avoid_print
library;

import 'dart:async';

import 'package:build/build.dart';
import 'package:build_resolvers/build_resolvers.dart';
import 'package:build_test/build_test.dart';
import 'package:glob/glob.dart';
import 'package:logging/logging.dart';
import 'package:package_config/package_config.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/svelte_ast.dart';
import 'package:svelte_builder/svelte_builder.dart';

final Map<AssetId, String> sourceAssets = <AssetId, String>{
  AssetId('app', 'web/app.svelte'): '''
<!-- app.svelte -->
<script module>
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
<p>{doubled} * 2 = {quadrupled}</p>''',
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
  required AssetReader reader,
  required AssetWriter writer,
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

void printAssets(ReaderWriterTesting testing, [Set<AssetId>? written]) {
  if (written != null) {
    for (AssetId asset in testing.assetsWritten) {
      if (written.contains(asset)) {
        print('-- ${asset.package}:${asset.path}');
        print(testing.readString(asset));
      }
    }
  } else {
    for (AssetId asset in testing.assetsWritten) {
      print('-- ${asset.package}:${asset.path}');
      print(testing.readString(asset));
    }
  }
}

Future<void> run() async {
  TestReaderWriter testReaderWriter = TestReaderWriter(rootPackage: 'app');

  PackageAssetReader packagesReader = await PackageAssetReader.currentIsolate();

  for (Package package in packagesReader.packageConfig.packages) {
    await for (AssetId id in packagesReader.findAssets(
      Glob('**'),
      package: package.name,
    )) {
      testReaderWriter.testing.writeBytes(
        id,
        await packagesReader.readAsBytes(id),
      );
    }
  }

  sourceAssets.forEach(testReaderWriter.testing.writeString);

  print('> Transform '.padRight(80, '='));

  await build(
    transformer(BuilderOptions.empty),
    <AssetId>{AssetId('app', 'web/app.svelte')},
    rootPackage: 'app',
    reader: testReaderWriter,
    writer: testReaderWriter,
  );

  printAssets(testReaderWriter.testing);
}
