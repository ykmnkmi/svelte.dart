import 'dart:io' show Platform, Process, exit, stdin;

import 'package:frontend_server_client/frontend_server_client.dart' show FrontendServerClient;
import 'package:path/path.dart' as path;
import 'package:stack_trace/stack_trace.dart' show Trace;
import 'package:watcher/watcher.dart' show Watcher;

const String platformDill = 'lib/_internal/vm_platform_strong.dill';

late final String dartExecutable = path.normalize(Platform.resolvedExecutable);
late final String sdkDir = path.dirname(path.dirname(dartExecutable));
late final String frontendServerPath = path.join(sdkDir, 'bin', 'snapshots', 'frontend_server.dart.snapshot');

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('usage: dart main.dart path-to-dart-file [arguments]');
    throw StateError('no dart file');
  }

  var filePath = arguments[0];
  var fileUri = Uri.file(filePath);

  var outputDill = path.setExtension(filePath, '.dill');
  arguments[0] = outputDill;

  var client = await FrontendServerClient.start(filePath, outputDill, platformDill);

  void run() {
    try {
      var result = Process.runSync(dartExecutable, arguments);

      if (result.stdout != null) {
        print(result.stdout.toString().trimRight());
      }

      if (result.stderr != null) {
        print(result.stderr.toString().trimRight());
      }
    } catch (error, trace) {
      print(error);
      print(Trace.format(trace));
    }
  }

  var invalidated = <Uri>{};

  Future<void> reload({bool runAfter = true}) async {
    try {
      var result = await client.compile(<Uri>[fileUri, ...invalidated]);
      invalidated.clear();

      if (result == null) {
        print('no compilation result, rejecting');
        return client.reject();
      }

      if (result.errorCount > 0) {
        print('compiled with ${result.errorCount} error(s)');
        return client.reject();
      }

      for (var line in result.compilerOutputLines) {
        print(line);
      }

      client.accept();
      client.reset();

      if (runAfter) {
        run();
      }
    } catch (error, trace) {
      print(error);
      print(Trace.format(trace));
    }
  }

  Future<void> watch(Set<Uri> invalidated, [Duration? pollingDelay]) {
    var watcher = Watcher('lib');

    watcher.events.listen((event) {
      print(event);
      invalidated.add(Uri.file(event.path));
    });

    return watcher.ready;
  }

  await watch(invalidated);
  print('init done');

  stdin.echoMode = false;
  stdin.lineMode = false;

  stdin.listen((bytes) async {
    switch (bytes[0]) {
      // r
      case 114:
        print('reloading...');
        await reload();
        break;
      // q
      case 113:
        exit(await client.shutdown());
      // h
      case 104:
        print('usage: press r to reload and q to exit');
        break;
      default:
    }
  });
}

// ignore_for_file: avoid_print
