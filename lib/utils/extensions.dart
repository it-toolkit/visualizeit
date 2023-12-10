
extension ObjectExtensions<T extends Object> on T {
  T? takeIf(bool condition) => condition ? this : null;
  T? takeIfDef(Object? object) => object != null? this : null;
}