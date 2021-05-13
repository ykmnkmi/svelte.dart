import 'dart:convert';
import 'dart:io';

import 'package:frontend_server_client/frontend_server_client.dart';
import 'package:path/path.dart' as path;
import 'package:stack_trace/stack_trace.dart';
import 'package:stream_transform/stream_transform.dart';

const String platformDill = 'lib/_internal/vm_platform_strong.dill';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    return;
  }

  arguments = arguments.toList();

  final sdkRoot = path.dirname(path.dirname(Platform.resolvedExecutable));
  final outputDill = path.join('.dart_tool', 'out', 'output.dill');

  final runAfterCompile = arguments.remove('-r') || arguments.remove('--run');

  final targetFilePath = path.normalize(arguments[0]);
  final targetFile = File(targetFilePath);

  void start(FrontendServerClient client) {
    Future<void> run([String line = '']) {
      final arguments = <String>[outputDill, ...line.trim().split(' ')];
      final message = 'running ${Platform.resolvedExecutable} ${arguments.join(' ')}';
      print(message);
      print('-' * (message.length - 1));
      return Process.run(Platform.resolvedExecutable, arguments).then<void>(runCompiled).catchError(catchError);
    }

    Future<void> compile([FileSystemEvent? event]) {
      Future<void> parse(CompileResult? result) {
        if (result == null) {
          print('no compilation result, rejecting');
          return client.reject();
        }

        if (result.errorCount > 0) {
          print('compiled with ${result.errorCount} error(s)');
          return client.reject();
        }

        print('compiled successful');
        result.compilerOutputLines.forEach(print);
        client.accept();
        client.reset();

        if (runAfterCompile) {
          return run();
        }

        return Future<void>.value();
      }

      return client.compile(event == null ? null : <Uri>[targetFile.uri]).then<void>(parse).catchError(catchError);
    }

    if (Platform.isWindows) {
      final stream = targetFile.parent.watch(events: FileSystemEvent.modify).where((event) => event.path == targetFile.path);
      stream.debounce(Duration(milliseconds: 100)).asyncMap<void>(compile).drain<void>();
    } else {
      final stream = targetFile.watch(events: FileSystemEvent.modify);
      stream.debounce(Duration(milliseconds: 100)).asyncMap<void>(compile).drain<void>();
    }

    Future<void> listen(String line) {
      if (line.startsWith('run')) {
        return run(line.substring(3));
      }

      if (line.startsWith('exit')) {
        print('shutdown ...');
        return client.shutdown().then<void>(exit);
      }

      return Future<void>.value();
    }

    compile().then((_) => stdin.transform(utf8.decoder).asyncMap<void>(listen).drain<void>());
  }

  FrontendServerClient.start(targetFilePath, outputDill, platformDill, printIncrementalDependencies: false, sdkRoot: sdkRoot)
      .then<void>(start)
      .catchError(catchError);
}

void runCompiled(ProcessResult result) {
  stdout.write(result.stdout);

  if (result.stderr != null) {
    stdout.write(result.stderr);
  }
}

void catchError(Object error, StackTrace stack) {
  print(error);
  print(Trace.format(stack));
}
