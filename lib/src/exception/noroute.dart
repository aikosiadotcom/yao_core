class NoRouteException implements Exception {
  final String msg;
  const NoRouteException(this.msg);
  String toString() => '${this.runtimeType}: $msg';
}
