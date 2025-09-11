import 'package:json_annotation/json_annotation.dart';

part 'stopcard.g.dart';

@JsonSerializable()
class StopCard {
  final String id;
  final String userId;
  final String title;
  final String description;
  final StopCardStatus status;
  final StopCardPriority priority;
  final List<String>? imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  StopCard({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StopCard.fromJson(Map<String, dynamic> json) => _$StopCardFromJson(json);
  Map<String, dynamic> toJson() => _$StopCardToJson(this);

  StopCard copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    StopCardStatus? status,
    StopCardPriority? priority,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StopCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'StopCard(id: $id, title: $title, status: $status, priority: $priority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StopCard && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class CreateStopCardRequest {
  final String title;
  final String description;
  final StopCardPriority priority;
  final List<String>? imageUrls;

  CreateStopCardRequest({
    required this.title,
    required this.description,
    required this.priority,
    this.imageUrls,
  });

  factory CreateStopCardRequest.fromJson(Map<String, dynamic> json) => _$CreateStopCardRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateStopCardRequestToJson(this);
}

@JsonSerializable()
class StopCardDto {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final DateTime createdAt;

  StopCardDto({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  factory StopCardDto.fromJson(Map<String, dynamic> json) => _$StopCardDtoFromJson(json);
  Map<String, dynamic> toJson() => _$StopCardDtoToJson(this);
}

@JsonSerializable()
class StopCardDetailDto {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final List<String> imageUrls;
  final DateTime createdAt;

  StopCardDetailDto({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.imageUrls,
    required this.createdAt,
  });

  factory StopCardDetailDto.fromJson(Map<String, dynamic> json) => _$StopCardDetailDtoFromJson(json);
  Map<String, dynamic> toJson() => _$StopCardDetailDtoToJson(this);
}

@JsonSerializable()
class AdminStopCardDto {
  final String id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String userName;
  final String userEmail;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AdminStopCardDto({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.userName,
    required this.userEmail,
    required this.imageUrls,
    required this.createdAt,
    this.updatedAt,
  });

  factory AdminStopCardDto.fromJson(Map<String, dynamic> json) => _$AdminStopCardDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdminStopCardDtoToJson(this);
}

@JsonSerializable()
class AdminStopCardsResponse {
  final List<AdminStopCardDto> stopCards;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  AdminStopCardsResponse({
    required this.stopCards,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory AdminStopCardsResponse.fromJson(Map<String, dynamic> json) => _$AdminStopCardsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AdminStopCardsResponseToJson(this);
}

enum StopCardStatus {
  @JsonValue(0)
  open,
  @JsonValue(1)
  inProgress,
  @JsonValue(2)
  resolved,
  @JsonValue(3)
  closed,
}

enum StopCardPriority {
  @JsonValue(0)
  low,
  @JsonValue(1)
  medium,
  @JsonValue(2)
  high,
  @JsonValue(3)
  critical,
}

extension StopCardStatusExtension on StopCardStatus {
  String get displayName {
    switch (this) {
      case StopCardStatus.open:
        return 'Open';
      case StopCardStatus.inProgress:
        return 'In Progress';
      case StopCardStatus.resolved:
        return 'Resolved';
      case StopCardStatus.closed:
        return 'Closed';
    }
  }

  String get description {
    switch (this) {
      case StopCardStatus.open:
        return 'Issue has been reported and is awaiting action';
      case StopCardStatus.inProgress:
        return 'Issue is currently being worked on';
      case StopCardStatus.resolved:
        return 'Issue has been resolved and is awaiting verification';
      case StopCardStatus.closed:
        return 'Issue has been completed and verified';
    }
  }

  bool get isOpen => this == StopCardStatus.open;
  bool get isInProgress => this == StopCardStatus.inProgress;
  bool get isResolved => this == StopCardStatus.resolved;
  bool get isClosed => this == StopCardStatus.closed;
  bool get isActive => this == StopCardStatus.open || this == StopCardStatus.inProgress;
}

extension StopCardPriorityExtension on StopCardPriority {
  String get displayName {
    switch (this) {
      case StopCardPriority.low:
        return 'Low';
      case StopCardPriority.medium:
        return 'Medium';
      case StopCardPriority.high:
        return 'High';
      case StopCardPriority.critical:
        return 'Critical';
    }
  }

  String get description {
    switch (this) {
      case StopCardPriority.low:
        return 'Low priority - can be addressed when convenient';
      case StopCardPriority.medium:
        return 'Medium priority - should be addressed soon';
      case StopCardPriority.high:
        return 'High priority - requires prompt attention';
      case StopCardPriority.critical:
        return 'Critical priority - requires immediate action';
    }
  }

  bool get isLow => this == StopCardPriority.low;
  bool get isMedium => this == StopCardPriority.medium;
  bool get isHigh => this == StopCardPriority.high;
  bool get isCritical => this == StopCardPriority.critical;
  bool get isUrgent => this == StopCardPriority.high || this == StopCardPriority.critical;
}