import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:goverment_complaints/app/services/network_service.dart';

class ApiService {
  final Dio _dio;
  final NetworkService _network;
  String? _token;

  ApiService({required String baseUrl, required NetworkService networkService})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ),
      _network = networkService {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('REQ ${options.method} ${options.uri}');
          print('HEADERS: ${options.headers}');
          if (_token != null && _token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
          } else {
            options.headers.remove('Authorization');
          }
          return handler.next(options);
        },
        onError: (DioError e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _token = token;
    if (token.isEmpty) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  void clearAuthToken() {
    _token = null;
    _dio.options.headers.remove('Authorization');
  }

  Future<void> _ensureConnection() async {
    final ok = await _network.hasConnection();
    if (!ok) {
      throw ApiException('No internet connection');
    }
  }

  Map<String, dynamic> _mergeHeaders([Map<String, dynamic>? extra]) {
    final base = <String, dynamic>{};
    if (_dio.options.headers != null)
      base.addAll(_dio.options.headers! as Map<String, dynamic>);
    if (extra != null) base.addAll(extra);
    return base;
  }

  Future<Response> upload(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
    Map<String, dynamic>? extraHeaders,
  }) async {
    await _ensureConnection();

    try {
      final options = Options(
        headers: _mergeHeaders(extraHeaders),
        contentType: 'multipart/form-data',
      );

      final response = await _dio.post(
        path,
        data: formData,
        options: options,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioError catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? extraHeaders,
    Options? options,
  }) async {
    await _ensureConnection();

    try {
      final requestOptions = options ?? Options();
      requestOptions.headers = _mergeHeaders(extraHeaders);

      if (data != null) {
        requestOptions.method = 'GET';
        final response = await _dio.request(
          path,
          data: data,
          options: requestOptions,
          queryParameters: queryParameters,
        );
        return response;
      } else {
        final response = await _dio.get(
          path,
          queryParameters: queryParameters,
          options: requestOptions,
        );
        return response;
      }
    } on DioError catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? extraHeaders,
    Options? options,
  }) async {
    await _ensureConnection();

    try {
      final requestOptions = options ?? Options();
      requestOptions.headers = _mergeHeaders(extraHeaders);
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
      );
      return response;
    } on DioError catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Uint8List> downloadFileBytes(
    String url, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    await _ensureConnection();

    try {
      final lower = url.toLowerCase();
      final isPdf = lower.endsWith('.pdf');
      final isImage =
          lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.gif');

      final headers = {...?_dio.options.headers};

      if (isPdf) {
        headers['Accept'] = 'application/pdf';
      } else if (isImage) {
        headers['Accept'] = 'image/*';
      } else {
        headers['Accept'] = '*/*';
      }

      headers.remove('content-type');

      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes, headers: headers),
        onReceiveProgress: onReceiveProgress,
      );

      final data = response.data;
      if (data == null) {
        throw ApiException('Empty response while downloading file');
      }
      return Uint8List.fromList(data);
    } on DioError catch (e) {
      throw _handleDioError(e);
    }
  }
  // Future<Uint8List> downloadFileBytes(
  //   String url, {
  //   void Function(int, int)? onReceiveProgress,
  // }) async {
  //   await _ensureConnection();

  //   try {
  //     final headers = {
  //       ...?_dio.options.headers,
  //       if (_dio.options.headers != null) ..._dio.options.headers!,
  //     }..remove('content-type');

  //     headers['Accept'] = '*/*';

  //     final response = await _dio.get<List<int>>(
  //       url,
  //       options: Options(responseType: ResponseType.bytes, headers: headers),
  //       onReceiveProgress: onReceiveProgress,
  //     );

  //     final data = response.data;
  //     if (data == null)
  //       throw ApiException('Empty response while downloading file');
  //     return Uint8List.fromList(data);
  //   } on DioError catch (e) {
  //     throw _handleDioError(e);
  //   }
  // }

  ApiException _handleDioError(DioError e) {
    if (e.type == DioErrorType.connectionTimeout ||
        e.type == DioErrorType.sendTimeout ||
        e.type == DioErrorType.receiveTimeout) {
      return ApiException('Connection timed out');
    }

    if (e.type == DioErrorType.badResponse && e.response != null) {
      final statusCode = e.response!.statusCode;
      final serverData = e.response!.data;
      String message = 'Received invalid status: $statusCode';
      if (serverData is Map && serverData['message'] != null) {
        message = serverData['message'].toString();
      }
      return ApiException(message, statusCode: statusCode);
    }

    if (e.type == DioErrorType.unknown) {
      return ApiException('Network error: ${e.message}');
    }

    return ApiException(e.message ?? 'Unexpected error');
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}
