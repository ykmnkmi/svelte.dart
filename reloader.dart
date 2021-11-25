import 'dart:convert' show utf8;
import 'dart:io' show Platform, Process, exit, stdin;

import 'package:frontend_server_client/frontend_server_client.dart' show FrontendServerClient;
import 'package:path/path.dart' as path;
import 'package:stack_trace/stack_trace.dart' show Trace;
import 'package:watcher/watcher.dart' show Watcher;

const String platformDill = 'lib/_internal/vm_platform_strong.dill';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('usage: dart main.dart path-to-dart-file [arguments]');
    throw StateError('no dart file');
  }

  var filePath = arguments[0];
  var fileUri = Uri.file(filePath);

  var executable = Platform.resolvedExecutable;
  var sdkRoot = path.dirname(path.dirname(executable));
  var outputDill = path.join('.dart_tool', 'incremental_build.dill');
  arguments[0] = outputDill;

  var client = await FrontendServerClient.start(filePath, outputDill, platformDill, sdkRoot: sdkRoot);

  void run() {
    try {
      var result = Process.runSync(executable, arguments, stdoutEncoding: null, stderrEncoding: null);

      if (result.stdout != null) {
        print(utf8.decode(result.stdout as List<int>).toString().trimRight());
      }

      if (result.stderr != null) {
        print(utf8.decode(result.stderr as List<int>));
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

  await reload();
  await watch(invalidated);

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
        exit(0);
      // h
      case 104:
        print('usage: press r to reload and q to exit');
        break;
      default:
    }
  });
}

// ignore_for_file: avoid_print