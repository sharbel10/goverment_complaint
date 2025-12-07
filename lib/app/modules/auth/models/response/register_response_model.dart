class RegisterResponse {
  final String status;
  final String message;
  final RegisterData? data;

  RegisterResponse({required this.status, required this.message, this.data});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'].toString(),
      message: json['message']?.toString() ?? '',
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
    );
  }
}

class RegisterData {
  final int citizenId;
  final String email;
  final bool otpSent;

  RegisterData({
    required this.citizenId,
    required this.email,
    required this.otpSent,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      citizenId: int.parse(json['citizen_id'].toString()),
      email: json['email'].toString(),
      otpSent: json['otp_sent'] == true || json['otp_sent'].toString() == '1',
    );
  }
}
