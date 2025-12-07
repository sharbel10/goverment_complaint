class GetUserComplaintsResponse {
  final String status;
  final String message;
  final List<ComplaintModel> complaints;

  GetUserComplaintsResponse({
    required this.status,
    required this.message,
    required this.complaints,
  });

  factory GetUserComplaintsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    final complaintsJson = data?['complaints'] as List<dynamic>? ?? [];

    final complaints =
        complaintsJson.map((e) {
          return ComplaintModel.fromJson(Map<String, dynamic>.from(e as Map));
        }).toList();

    return GetUserComplaintsResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      complaints: complaints,
    );
  }
}

class ComplaintModel {
  final int id;
  final int citizenId;
  final String type;
  final String entity;
  final String location;
  final String description;
  final String referenceNumber;
  final List<String> attachments;
  final String status;
  final String createdAt;
  final String updatedAt;

  ComplaintModel({
    required this.id,
    required this.citizenId,
    required this.type,
    required this.entity,
    required this.location,
    required this.description,
    required this.referenceNumber,
    required this.attachments,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    final attachmentsRaw = json['attachments'];
    List<String> attachments = [];
    if (attachmentsRaw is List) {
      attachments =
          attachmentsRaw
              .map((a) => a?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
    }

    return ComplaintModel(
      id: int.parse(json['id'].toString()),
      citizenId: int.parse(json['citizen_id'].toString()),
      type: json['type']?.toString() ?? '',
      entity: json['entity']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      referenceNumber: json['reference_number']?.toString() ?? '',
      attachments: attachments,
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
