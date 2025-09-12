// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckPoint _$CheckPointFromJson(Map<String, dynamic> json) => CheckPoint(
  id: json['id'] as String,
  name: json['name'] as String,
  qrCode: json['qrCode'] as String,
  location: json['location'] as String?,
  isActive: json['isActive'] as bool,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CheckPointToJson(CheckPoint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'qrCode': instance.qrCode,
      'location': instance.location,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

CheckPointDto _$CheckPointDtoFromJson(Map<String, dynamic> json) =>
    CheckPointDto(
      id: json['id'] as String,
      name: json['name'] as String,
      qrCode: json['qrCode'] as String,
      location: json['location'] as String?,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$CheckPointDtoToJson(CheckPointDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'qrCode': instance.qrCode,
      'location': instance.location,
      'isActive': instance.isActive,
    };

CheckPointScanRequest _$CheckPointScanRequestFromJson(
  Map<String, dynamic> json,
) => CheckPointScanRequest(
  status: $enumDecode(_$CheckPointStatusEnumMap, json['status']),
  description: json['description'] as String?,
  imageUrls: (json['imageUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CheckPointScanRequestToJson(
  CheckPointScanRequest instance,
) => <String, dynamic>{
  'status': _$CheckPointStatusEnumMap[instance.status]!,
  'description': instance.description,
  'imageUrls': instance.imageUrls,
};

const _$CheckPointStatusEnumMap = {
  CheckPointStatus.ok: 0,
  CheckPointStatus.issue: 1,
  CheckPointStatus.critical: 2,
};

CheckPointLog _$CheckPointLogFromJson(Map<String, dynamic> json) =>
    CheckPointLog(
      id: json['id'] as String,
      checkPointName: json['checkPointName'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CheckPointLogToJson(CheckPointLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'checkPointName': instance.checkPointName,
      'status': instance.status,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
    };

AdminCheckPointLog _$AdminCheckPointLogFromJson(Map<String, dynamic> json) =>
    AdminCheckPointLog(
      id: json['id'] as String,
      checkPointName: json['checkPointName'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AdminCheckPointLogToJson(AdminCheckPointLog instance) =>
    <String, dynamic>{
      'id': instance.id,
      'checkPointName': instance.checkPointName,
      'userName': instance.userName,
      'userEmail': instance.userEmail,
      'status': instance.status,
      'description': instance.description,
      'imageUrls': instance.imageUrls,
      'createdAt': instance.createdAt.toIso8601String(),
    };

AdminCheckPointLogsResponse _$AdminCheckPointLogsResponseFromJson(
  Map<String, dynamic> json,
) => AdminCheckPointLogsResponse(
  logs: (json['logs'] as List<dynamic>)
      .map((e) => AdminCheckPointLog.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$AdminCheckPointLogsResponseToJson(
  AdminCheckPointLogsResponse instance,
) => <String, dynamic>{
  'logs': instance.logs,
  'totalCount': instance.totalCount,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalPages': instance.totalPages,
};
