class ExistsException implements Exception {
  final String msg;
  const ExistsException(this.msg);
  String toString() => '${this.runtimeType}: $msg';
}
