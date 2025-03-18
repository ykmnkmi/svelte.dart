import 'dart:io';

final packageEntryRe = RegExp('^  (\\w+): (.+)\$', multiLine: true);

void main() {
  var versionsUri = Uri.file('tool/package_versions.yaml');
  var resolvedVersionsUri = Directory.current.uri.resolveUri(versionsUri);
  var versionsFile = File.fromUri(resolvedVersionsUri);

  var versions = <String, String>{};

  var lines = versionsFile.readAsLinesSync();

  for (int i = 0; i < lines.length; i += 1) {
    var line = lines[i];

    if (line.isEmpty) {
      continue;
    }

    var parts = line.split(':');
    versions[parts[0]] = parts[1].trimLeft();
  }

  String replace(Match match) {
    return '  ${match[1]}: ${versions[match[1]]}';
  }

  updateVersions(Directory.current, replace);

  var entities = Directory.current.listSync(recursive: true);

  for (var directory in entities) {
    if (directory is Directory) {
      updateVersions(directory, replace);
    }
  }
}

void updateVersions(Directory directory, String Function(Match match) replace) {
  var pubspecFile = File.fromUri(directory.uri.resolve('pubspec.yaml'));

  if (pubspecFile.existsSync()) {
    var oldPubspec = pubspecFile.readAsStringSync();
    var newContent = oldPubspec.replaceAllMapped(packageEntryRe, replace);
    pubspecFile.writeAsStringSync(newContent);
  }
}
