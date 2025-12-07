class VerifyOtpRequest {
  final String otp;
  final int citizenId;

  VerifyOtpRequest({required this.otp, required this.citizenId});

  Map<String, dynamic> toJson() {
    return {'otp': otp, 'citizen_id': citizenId};
  }
}
