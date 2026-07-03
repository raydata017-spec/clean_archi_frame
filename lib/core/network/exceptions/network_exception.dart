class NetworkException implements Exception {
  final String message;
  final String? type;

  NetworkException({
    required this.message,
    this.type,
  });

  @override
  String toString() => message;
}
