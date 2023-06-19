import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/element/element.dart';

Future<Directory> getRoot(String package) async {
  Uri srcUri = Uri(scheme: 'package', path: '$package/src');
  Uri? resolvedSrcUri = await Isolate.resolvePackageUri(srcUri);

  if (resolvedSrcUri == null) {
    throw StateError('$package not resolved');
  }

  Directory src = Directory.fromUri(resolvedSrcUri);
  return src.parent.parent;
}

Future<LibraryElement> getLibrary(AnalysisSession session, Uri uri) async {
  File file = File.fromUri(uri);

  SomeResolvedLibraryResult resolvedLibrary =
      await session.getResolvedLibrary(file.absolute.path);

  if (resolvedLibrary is ResolvedLibraryResult) {
    return resolvedLibrary.element;
  }

  throw StateError('$uri library not resolved');
}

ClassElement getClass(LibraryElement library, String name) {
  ClassElement? classElement = library.getClass(name);

  if (classElement == null) {
    throw StateError('$name not resolved');
  }

  return classElement;
}
