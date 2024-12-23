import 'dart:io';

final packageEntryRe = RegExp('^  (\\w+): (.+)\$', multiLine: true);

void main() {
  var versionsUri = Uri(path: 'tool/package_versions.yaml');
  var resolvedVersionsUri = Directory.current.uri.resolveUri(versionsUri);
  var versionsFile = File.fromUri(resolvedVersionsUri);

  var versions = <String, String>{};

  for (var version in versionsFile.readAsLinesSync()) {
    if (version.isEmpty) {
      continue;
    }

    var parts = version.split(':');
    versions[parts[0]] = parts[1].trimLeft();
  }

  String replace(Match match) {
    return '  ${match[1]}: ${versions[match[1]]}';
  }

  var offset = Directory.current.path.length + 1;

  Directory.current.listSync().whereType<Directory>().forEach((directory) {
    var directoryName = directory.path.substring(offset);

    if (directoryName.startsWith('svelte_')) {
      var pubspecFile = File.fromUri(directory.uri.resolve('pubspec.yaml'));

      if (pubspecFile.existsSync()) {
        var oldPubspec = pubspecFile.readAsStringSync();
        var newContent = oldPubspec.replaceAllMapped(packageEntryRe, replace);
        pubspecFile.writeAsStringSync(newContent);
      }
    }
  });
}
