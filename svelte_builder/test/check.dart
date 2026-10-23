// ignore_for_file: avoid_print
library;

import 'dart:async';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:svelte_ast/svelte_ast.dart';
import 'package:svelte_builder/svelte_builder.dart';

final Map<String, String> sourceAssets = <String, String>{
  'app|lib/app.svelte': '''
<!-- app.svelte -->
<script>
  import 'dart:async';

  import 'package:svelte/svelte.dart';

  var step = prop<int>(1);

  var count = state<int>(0);
  var doubled = derived<int>(() => count() * 2);
  var quadrupled = derived<int>(() => doubled() * 2);

  void handleClick() {
    count.set(count() + step());
  }

  onMount(() {
    var timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      count.increment();
    });

    return () {
      timer.cancel();
    };
  });
</script>

<button onclick={handleClick}>
  Clicked {count()} {count() == 1 ? 'time' : 'times'}
</button>

<p>{count()} * 2 = {doubled()}</p>
<p>{doubled()} * 2 = {quadrupled()}</p>''',
};

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

void printAssets(ReaderWriterTesting testing, [Set<AssetId>? written]) {
  if (written == null) {
    for (AssetId asset in testing.assetsWritten) {
      if (testing.exists(asset)) {
        print('-- ${asset.package}:${asset.path}');
        print(testing.readString(asset));
      }
    }
  } else {
    for (AssetId asset in testing.assetsWritten) {
      if (written.contains(asset)) {
        if (testing.exists(asset)) {
          print('-- ${asset.package}:${asset.path}');
          print(testing.readString(asset));
        }
      }
    }
  }
}

Future<void> run() async {
  TestReaderWriter testReaderWriter = TestReaderWriter(rootPackage: 'app');
  await testReaderWriter.testing.loadIsolateSources();

  sourceAssets.forEach((String id, String contents) {
    testReaderWriter.testing.writeString(makeAssetId(id), contents);
  });

  print('> Transform '.padRight(80, '='));

  await testBuilder(
    transformer(BuilderOptions.empty),
    sourceAssets,
    generateFor: <String>{'app|lib/app.svelte'},
    rootPackage: 'app',
    onLog: print,
    readerWriter: testReaderWriter,
    flattenOutput: true,
  );

  printAssets(testReaderWriter.testing, <AssetId>{
    makeAssetId('app|lib/app.svelte.dart'),
  });
}

typedef Props = ({int Function() count});
