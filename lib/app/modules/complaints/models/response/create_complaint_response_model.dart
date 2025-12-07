class ComplaintSubmitResponse {
  final String status;
  final String message;
  final ComplaintData? data;

  ComplaintSubmitResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ComplaintSubmitResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintSubmitResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data:
          json['data'] != null
              ? ComplaintData.fromJson(Map<String, dynamic>.from(json['data']))
              : null,
    );
  }
}

class ComplaintData {
  final String? referenceNumber;
  final int? complaintId;

  ComplaintData({this.referenceNumber, this.complaintId});

  factory ComplaintData.fromJson(Map<String, dynamic> json) {
    return ComplaintData(
      referenceNumber: json['reference_number']?.toString(),
      complaintId:
          json['complaint_id'] != null
              ? int.tryParse(json['complaint_id'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'reference_number': referenceNumber,
    'complaint_id': complaintId,
  };
}
