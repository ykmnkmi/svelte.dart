import 'dart:convert';
import 'dart:io';

import 'package:frontend_server_client/frontend_server_client.dart';
import 'package:path/path.dart' as path;
import 'package:pedantic/pedantic.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:stream_transform/stream_transform.dart';

const String platformDill = 'lib/_internal/vm_platform_strong.dill';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    return;
  }

  arguments = arguments.toList();

  try {
    final sdkRoot = path.dirname(path.dirname(Platform.resolvedExecutable));
    final outputDillDirectory = Directory.systemTemp.createTempSync('piko');
    final outputDillFile = File(path.join(outputDillDirectory.path, 'output.dill'));

    final runAfterCompile = arguments.remove('-r') || arguments.remove('--run');

    final targetFilePath = arguments[0];
    final targetFile = File(targetFilePath);

    final client = await FrontendServerClient.start(targetFilePath, outputDillFile.path, platformDill, printIncrementalDependencies: false, sdkRoot: sdkRoot);

    ProcessSignal.sigint.watch().listen((_) async {
      await client.shutdown();
    });

    if (Platform.isLinux) {
      ProcessSignal.sigterm.watch().listen((_) async {
        await client.shutdown();
      });
    }

    Future<void> run(String line) async {
      final arguments = <String>[outputDillFile.path, ...line.trim().split(' ')];
      stdout.writeln('${Platform.resolvedExecutable} ${arguments.join(' ')}');

      final result = await Process.run(Platform.resolvedExecutable, arguments, runInShell: true);
      stdout.write(result.stdout);
    }

    Future<void> compile([FileSystemEvent? event]) async {
      final result = await client.compile(event == null ? null : <Uri>[targetFile.uri]);

      if (result != null) {
        if (result.errorCount == 0) {
          stdout.writeln('compiled successful');
          result.compilerOutputLines.forEach(stdout.writeln);
          client.accept();
          client.reset();

          if (runAfterCompile) {
            await run('');
          }
        } else {
          stdout.writeln('compiled with ${result.errorCount} error(s)');
          await client.reject();
        }
      } else {
        stdout.writeln('no compilation result, rejecting');
        await client.reject();
      }
    }

    if (Platform.isWindows) {
      final stream = targetFile.parent.watch(events: FileSystemEvent.modify).where((event) => event.path == targetFile.path);
      unawaited(stream.debounce(Duration(milliseconds: 100)).asyncMap<void>(compile).drain<void>());
    } else {
      final stream = targetFile.watch(events: FileSystemEvent.modify);
      unawaited(stream.debounce(Duration(milliseconds: 100)).asyncMap<void>(compile).drain<void>());
    }

    Future<void> listen(String line) async {
      if (line.startsWith('run')) {
        await run(line.substring(3));
      } else if (line.startsWith('exit')) {
        stdout.writeln('shutdown ...');
        await client.shutdown();
        exit(0);
      }
    }

    await compile();
    await stdin.transform(utf8.decoder).asyncMap<void>(listen).drain<void>();
  } catch (error, stack) {
    stdout.writeln(error);
    stdout.writeln(Trace.format(stack));
  }
}
