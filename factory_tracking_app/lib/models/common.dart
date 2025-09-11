import 'package:json_annotation/json_annotation.dart';

part 'common.g.dart';

@JsonSerializable()
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final String? error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.error,
  });

  factory ApiResponse.success(T? data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, error: $error)';
  }
}

@JsonSerializable()
class ImageUploadResponse {
  final String url;
  final String fileName;
  final int fileSize;
  final String contentType;

  ImageUploadResponse({
    required this.url,
    required this.fileName,
    required this.fileSize,
    required this.contentType,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) => _$ImageUploadResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ImageUploadResponseToJson(this);

  @override
  String toString() {
    return 'ImageUploadResponse(url: $url, fileName: $fileName, fileSize: $fileSize)';
  }
}

@JsonSerializable()
class MultipleImageUploadResponse {
  final List<ImageUploadResponse> images;
  final int totalCount;
  final List<String> errors;

  MultipleImageUploadResponse({
    required this.images,
    required this.totalCount,
    required this.errors,
  });

  factory MultipleImageUploadResponse.fromJson(Map<String, dynamic> json) => _$MultipleImageUploadResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MultipleImageUploadResponseToJson(this);

  bool get hasErrors => errors.isNotEmpty;
  bool get allSuccessful => errors.isEmpty && images.length == totalCount;

  @override
  String toString() {
    return 'MultipleImageUploadResponse(totalCount: $totalCount, successful: ${images.length}, errors: ${errors.length})';
  }
}

@JsonSerializable()
class PaginatedResponse<T> {
  final List<T> data;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResponse({
    required this.data,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);

  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
  int get itemCount => data.length;

  @override
  String toString() {
    return 'PaginatedResponse(page: $page/$totalPages, items: ${data.length}/$totalCount)';
  }
}

// Loading states for UI
enum LoadingState {
  idle,
  loading,
  success,
  error,
}

extension LoadingStateExtension on LoadingState {
  bool get isIdle => this == LoadingState.idle;
  bool get isLoading => this == LoadingState.loading;
  bool get isSuccess => this == LoadingState.success;
  bool get isError => this == LoadingState.error;
  bool get isNotLoading => this != LoadingState.loading;
}

// Generic result class for operations
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result.success(this.data)
      : error = null,
        isSuccess = true;

  Result.error(this.error)
      : data = null,
        isSuccess = false;

  bool get isError => !isSuccess;
  bool get hasData => data != null;

  @override
  String toString() {
    return isSuccess ? 'Result.success($data)' : 'Result.error($error)';
  }
}

// Network connectivity status
@JsonSerializable()
class NetworkStatus {
  final bool isConnected;
  final String connectionType;
  final String speed;
  final DateTime lastChecked;

  NetworkStatus({
    required this.isConnected,
    required this.connectionType,
    required this.speed,
    required this.lastChecked,
  });

  factory NetworkStatus.fromJson(Map<String, dynamic> json) => _$NetworkStatusFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkStatusToJson(this);

  factory NetworkStatus.disconnected() {
    return NetworkStatus(
      isConnected: false,
      connectionType: 'none',
      speed: 'unknown',
      lastChecked: DateTime.now(),
    );
  }

  factory NetworkStatus.connected({
    String connectionType = 'unknown',
    String speed = 'unknown',
  }) {
    return NetworkStatus(
      isConnected: true,
      connectionType: connectionType,
      speed: speed,
      lastChecked: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'NetworkStatus(isConnected: $isConnected, type: $connectionType, speed: $speed)';
  }
}