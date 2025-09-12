import 'package:json_annotation/json_annotation.dart';

part 'checkpoint.g.dart';

@JsonSerializable()
class CheckPoint {
  final String id;
  final String name;
  final String qrCode;
  final String? location;
  final bool isActive;
  final DateTime? createdAt;

  CheckPoint({
    required this.id,
    required this.name,
    required this.qrCode,
    this.location,
    required this.isActive,
    this.createdAt,
  });

  factory CheckPoint.fromJson(Map<String, dynamic> json) => _$CheckPointFromJson(json);
  Map<String, dynamic> toJson() => _$CheckPointToJson(this);

  CheckPoint copyWith({
    String? id,
    String? name,
    String? qrCode,
    String? location,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CheckPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      qrCode: qrCode ?? this.qrCode,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CheckPoint(id: $id, name: $name, qrCode: $qrCode, location: $location, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckPoint && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@JsonSerializable()
class CheckPointDto {
  final String id;
  final String name;
  final String qrCode;
  final String? location;
  final bool isActive;

  CheckPointDto({
    required this.id,
    required this.name,
    required this.qrCode,
    this.location,
    required this.isActive,
  });

  factory CheckPointDto.fromJson(Map<String, dynamic> json) => _$CheckPointDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CheckPointDtoToJson(this);
}

@JsonSerializable()
class CheckPointScanRequest {
  final CheckPointStatus status;
  final String? description;
  final List<String>? imageUrls;

  CheckPointScanRequest({
    required this.status,
    this.description,
    this.imageUrls,
  });

  factory CheckPointScanRequest.fromJson(Map<String, dynamic> json) => _$CheckPointScanRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CheckPointScanRequestToJson(this);
}

@JsonSerializable()
class CheckPointLog {
  final String id;
  final String checkPointName;
  final String status;
  final String? description;
  final DateTime createdAt;

  CheckPointLog({
    required this.id,
    required this.checkPointName,
    required this.status,
    this.description,
    required this.createdAt,
  });

  factory CheckPointLog.fromJson(Map<String, dynamic> json) => _$CheckPointLogFromJson(json);
  Map<String, dynamic> toJson() => _$CheckPointLogToJson(this);

  CheckPointLog copyWith({
    String? id,
    String? checkPointName,
    String? status,
    String? description,
    DateTime? createdAt,
  }) {
    return CheckPointLog(
      id: id ?? this.id,
      checkPointName: checkPointName ?? this.checkPointName,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CheckPointLog(id: $id, checkPointName: $checkPointName, status: $status)';
  }
}

@JsonSerializable()
class AdminCheckPointLog {
  final String id;
  final String checkPointName;
  final String userName;
  final String userEmail;
  final String status;
  final String? description;
  final List<String> imageUrls;
  final DateTime createdAt;

  AdminCheckPointLog({
    required this.id,
    required this.checkPointName,
    required this.userName,
    required this.userEmail,
    required this.status,
    this.description,
    required this.imageUrls,
    required this.createdAt,
  });

  factory AdminCheckPointLog.fromJson(Map<String, dynamic> json) => _$AdminCheckPointLogFromJson(json);
  Map<String, dynamic> toJson() => _$AdminCheckPointLogToJson(this);
}

@JsonSerializable()
class AdminCheckPointLogsResponse {
  final List<AdminCheckPointLog> logs;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  AdminCheckPointLogsResponse({
    required this.logs,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory AdminCheckPointLogsResponse.fromJson(Map<String, dynamic> json) => _$AdminCheckPointLogsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AdminCheckPointLogsResponseToJson(this);
}

enum CheckPointStatus {
  @JsonValue(0)
  ok,
  @JsonValue(1)
  issue,
  @JsonValue(2)
  critical,
}

extension CheckPointStatusExtension on CheckPointStatus {
  String get displayName {
    switch (this) {
      case CheckPointStatus.ok:
        return 'OK';
      case CheckPointStatus.issue:
        return 'Issue';
      case CheckPointStatus.critical:
        return 'Critical';
    }
  }

  String get description {
    switch (this) {
      case CheckPointStatus.ok:
        return 'Everything is working normally';
      case CheckPointStatus.issue:
        return 'Minor issue detected';
      case CheckPointStatus.critical:
        return 'Critical issue requires immediate attention';
    }
  }

  bool get isOk => this == CheckPointStatus.ok;
  bool get hasIssue => this == CheckPointStatus.issue || this == CheckPointStatus.critical;
  bool get isCritical => this == CheckPointStatus.critical;
}