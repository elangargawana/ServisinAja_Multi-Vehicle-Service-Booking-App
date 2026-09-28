// lib/core/errors/app_exception.dart

/// Base exception class for all ServisinAja domain errors.
sealed class AppException implements Exception {
  const AppException({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a network request fails.
final class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Koneksi bermasalah. Periksa internet Anda.',
    super.cause,
  });
}

/// Thrown when the selected slot is no longer available.
final class SlotUnavailableException extends AppException {
  const SlotUnavailableException({
    super.message = 'Slot yang dipilih sudah tidak tersedia.',
    super.cause,
  });
}

/// Thrown when a booking validation fails.
final class BookingValidationException extends AppException {
  const BookingValidationException({
    required super.message,
    super.cause,
  });
}

/// Thrown when a requested resource is not found.
final class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.cause,
  });
}

/// Thrown for unexpected server-side errors.
final class ServerException extends AppException {
  const ServerException({
    super.message = 'Terjadi kesalahan pada server. Coba lagi nanti.',
    super.cause,
  });
}

/// Thrown when attempting to add duplicate items.
final class DuplicateException extends AppException {
  const DuplicateException({required super.message, super.cause});
}

/// Thrown when business rules are violated (e.g., max vehicles exceeded).
final class BusinessRuleException extends AppException {
  const BusinessRuleException({required super.message, super.cause});
}
