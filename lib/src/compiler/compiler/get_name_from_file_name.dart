String getNameFromFileName(String fileName) {
  fileName = fileName
      .trim()
      .replaceAll(RegExp('^_+'), '')
      .replaceAll(RegExp('_+\$'), '');

  if (fileName.isEmpty || fileName.startsWith('_') || fileName.contains('%')) {
    throw Exception('Could not derive component name from file $fileName');
  }

  return fileName;
}
