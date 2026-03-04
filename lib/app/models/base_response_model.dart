/// Base for all API response models. Subclasses add [data] and parsing.
abstract class BaseResponseModel<T> {
  const BaseResponseModel({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;

  /// Create from raw JSON (map or list). Override in subclasses.
  static BaseResponseModel<T> fromJson<T>(dynamic json) {
    throw UnimplementedError('Subclasses must implement fromJson');
  }
}
