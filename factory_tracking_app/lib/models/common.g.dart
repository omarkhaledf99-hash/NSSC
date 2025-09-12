// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ApiResponse<T>(
  success: json['success'] as bool,
  message: json['message'] as String?,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  statusCode: (json['statusCode'] as num?)?.toInt(),
  error: json['error'] as String?,
);

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'statusCode': instance.statusCode,
  'error': instance.error,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

ImageUploadResponse _$ImageUploadResponseFromJson(Map<String, dynamic> json) =>
    ImageUploadResponse(
      url: json['url'] as String,
      fileName: json['fileName'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      contentType: json['contentType'] as String,
    );

Map<String, dynamic> _$ImageUploadResponseToJson(
  ImageUploadResponse instance,
) => <String, dynamic>{
  'url': instance.url,
  'fileName': instance.fileName,
  'fileSize': instance.fileSize,
  'contentType': instance.contentType,
};

MultipleImageUploadResponse _$MultipleImageUploadResponseFromJson(
  Map<String, dynamic> json,
) => MultipleImageUploadResponse(
  images: (json['images'] as List<dynamic>)
      .map((e) => ImageUploadResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  errors: (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$MultipleImageUploadResponseToJson(
  MultipleImageUploadResponse instance,
) => <String, dynamic>{
  'images': instance.images,
  'totalCount': instance.totalCount,
  'errors': instance.errors,
};

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PaginatedResponse<T>(
  data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  hasNextPage: json['hasNextPage'] as bool,
  hasPreviousPage: json['hasPreviousPage'] as bool,
);

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'data': instance.data.map(toJsonT).toList(),
  'totalCount': instance.totalCount,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalPages': instance.totalPages,
  'hasNextPage': instance.hasNextPage,
  'hasPreviousPage': instance.hasPreviousPage,
};

NetworkStatus _$NetworkStatusFromJson(Map<String, dynamic> json) =>
    NetworkStatus(
      isConnected: json['isConnected'] as bool,
      connectionType: json['connectionType'] as String,
      speed: json['speed'] as String,
      lastChecked: DateTime.parse(json['lastChecked'] as String),
    );

Map<String, dynamic> _$NetworkStatusToJson(NetworkStatus instance) =>
    <String, dynamic>{
      'isConnected': instance.isConnected,
      'connectionType': instance.connectionType,
      'speed': instance.speed,
      'lastChecked': instance.lastChecked.toIso8601String(),
    };
