extension ObjectExtensions<T extends Object> on T {
  T? takeIf(bool condition) => condition ? this : null;
  T? takeIfDef(Object? object) => object != null ? this : null;
  R? let<R>(R Function(T) map) => map(this);
}

extension StringExtensions on String {
  String trimIndent() {
    final List<String> lines = split('\n');

    // Find the minimum indentation level
    int minIndentation = lines
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.indexOf(RegExp(r'\S')))
        .let((list) => list.isEmpty ? 0 : list.reduce((minIndent, currentIndent) => (currentIndent < minIndent) ? currentIndent : minIndent))
        ?? 0;

    // Remove the common indentation from each line
    final trimmedLines = lines.map((line) => line.trim().isNotEmpty ? line.substring(minIndentation) : "");

    // Join the lines back together
    final result = trimmedLines.join('\n');

    return result;
  }
}
