import 'dart:async';
import 'package:dio/dio.dart';
import 'package:n7bluetooth/services/remote/error_type.dart';
import 'package:n7bluetooth/utils/app_log.dart';

mixin ApiError {
  /// This function was called when trigger safeCallApi
  /// and apiError = true as default
  Future<void> onApiError(dynamic error);

  /// Call api safety with error handling.
  /// Required:
  /// - dioApi: call async dio function
  /// Optional:
  /// - onStart: the function executed before api, can be null
  /// - onError: the function executed in case api crashed, can be null
  /// - onCompleted: the function executed after api or before crashing, can be null
  /// - onFinally: the function executed end of function, can be null
  /// - apiError: true as default if you want to forward the error to onApiError
  Future<T> safeCallApi<T>(
    Future<T> Function() dioApi, {
    Future<void> Function() onStart,
    Future<void> Function(dynamic error) onError,
    Future<void> Function(bool status, T res) onCompleted,
    Future<void> Function() onFinally,
    bool apiError = true,
  }) async {
    try {
      // On start, use for show loading
      if (onStart != null) {
        await onStart();
      }

      // Execute api
      final T res = await dioApi();

      // On completed, use for hide loading
      if (onCompleted != null) {
        await onCompleted(true, res);
      }
      // Return api response
      return res;
    } catch (error) {
      // In case error:
      // On completed, use for hide loading
      if (onCompleted != null) {
        await onCompleted(false, null);
      }

      // On inline error
      if (onError != null) {
        await onError(error);
      }

      // Call onApiError if apiError's enabled
      if (apiError) {
        onApiError(error);
      }

      return null;
    } finally {
      // Call finally function
      if (onFinally != null) {
        await onFinally();
      }
    }
  }

  // Parsing error to ErrorType
  ErrorType parseErrorType(dynamic error) {
    logger.d(error);
    if (error is DioError && error.type == DioErrorType.RESPONSE) {
      ErrorCode errorCode = ErrorCode.unknown;
      if (error.response?.statusCode == 401) {
        errorCode = ErrorCode.unauthorized;
      }
      return ErrorType(code: errorCode, message: error.message);
    }
    return ErrorType();
  }
}
