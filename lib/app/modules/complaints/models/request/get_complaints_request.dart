// modules/complaints/models/request/get_user_complaints_request.dart
class GetUserComplaintsRequest {
  final int citizenId;

  GetUserComplaintsRequest({required this.citizenId});

  Map<String, dynamic> toJson() {
    return {'citizen_id': citizenId};
  }
}
