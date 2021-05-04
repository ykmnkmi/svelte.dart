String getLibraryName(String name) {
  return name.replaceAllMapped(RegExp('([A-Z])[A-Z]*'), (match) => match.start == 0 ? match[0]!.toLowerCase() : '_' + match[0]!.toLowerCase());
}
