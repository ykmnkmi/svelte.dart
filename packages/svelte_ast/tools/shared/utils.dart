import 'dart:io';
import 'dart:isolate';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/element/element.dart';

Future<Directory> getRoot(String package) async {
  var srcUri = Uri(scheme: 'package', path: '$package/src');
  var resolvedSrcUri = await Isolate.resolvePackageUri(srcUri);

  if (resolvedSrcUri == null) {
    throw StateError('$package not resolved');
  }

  var src = Directory.fromUri(resolvedSrcUri);
  return src.parent.parent;
}

Future<LibraryElement> getLibrary(AnalysisSession session, Uri uri) async {
  var file = File.fromUri(uri);

  var resolvedLibrary = await session.getResolvedLibrary(file.absolute.path);

  if (resolvedLibrary is ResolvedLibraryResult) {
    return resolvedLibrary.element;
  }

  throw StateError('$uri library not resolved');
}

ClassElement getClass(LibraryElement library, String name) {
  var classElement = library.getClass(name);

  if (classElement == null) {
    throw StateError('$name not resolved');
  }

  return classElement;
}
