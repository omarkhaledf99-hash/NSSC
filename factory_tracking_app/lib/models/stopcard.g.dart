// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stopcard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StopCard _$StopCardFromJson(Map<String, dynamic> json) => StopCard(
  id: json['id'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  status: $enumDecode(_$StopCardStatusEnumMap, json['status']),
  priority: $enumDecode(_$StopCardPriorityEnumMap, json['priority']),
  imageUrls: (json['imageUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$StopCardToJson(StopCard instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'description': instance.description,
  'status': _$StopCardStatusEnumMap[instance.status]!,
  'priority': _$StopCardPriorityEnumMap[instance.priority]!,
  'imageUrls': instance.imageUrls,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$StopCardStatusEnumMap = {
  StopCardStatus.open: 0,
  StopCardStatus.inProgress: 1,
  StopCardStatus.resolved: 2,
  StopCardStatus.closed: 3,
};

const _$StopCardPriorityEnumMap = {
  StopCardPriority.low: 0,
  StopCardPriority.medium: 1,
  StopCardPriority.high: 2,
  StopCardPriority.critical: 3,
};

CreateStopCardRequest _$CreateStopCardRequestFromJson(
  Map<String, dynamic> json,
) => CreateStopCardRequest(
  title: json['title'] as String,
  description: json['description'] as String,
  priority: $enumDecode(_$StopCardPriorityEnumMap, json['priority']),
  imageUrls: (json['imageUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CreateStopCardRequestToJson(
  CreateStopCardRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'priority': _$StopCardPriorityEnumMap[instance.priority]!,
  'imageUrls': instance.imageUrls,
};

StopCardDto _$StopCardDtoFromJson(Map<String, dynamic> json) => StopCardDto(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  priority: json['priority'] as String,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$StopCardDtoToJson(StopCardDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'priority': instance.priority,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };

StopCardDetailDto _$StopCardDetailDtoFromJson(Map<String, dynamic> json) =>
    StopCardDetailDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$StopCardDetailDtoToJson(StopCardDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'priority': instance.priority,
      'status': instance.status,
      'imageUrls': instance.imageUrls,
      'createdAt': instance.createdAt.toIso8601String(),
    };

AdminStopCardDto _$AdminStopCardDtoFromJson(Map<String, dynamic> json) =>
    AdminStopCardDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AdminStopCardDtoToJson(AdminStopCardDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'priority': instance.priority,
      'status': instance.status,
      'userName': instance.userName,
      'userEmail': instance.userEmail,
      'imageUrls': instance.imageUrls,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

AdminStopCardsResponse _$AdminStopCardsResponseFromJson(
  Map<String, dynamic> json,
) => AdminStopCardsResponse(
  stopCards: (json['stopCards'] as List<dynamic>)
      .map((e) => AdminStopCardDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
);

Map<String, dynamic> _$AdminStopCardsResponseToJson(
  AdminStopCardsResponse instance,
) => <String, dynamic>{
  'stopCards': instance.stopCards,
  'totalCount': instance.totalCount,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalPages': instance.totalPages,
};
