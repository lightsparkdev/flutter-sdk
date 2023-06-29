class LightsparkException extends Error {
  final String type;
  final String message;
  final String? details;

  LightsparkException(this.type, this.message, [this.details]);

  @override
  String toString() {
    return 'LightsparkException{type: $type, message: $message, details: $details}';
  }
}
