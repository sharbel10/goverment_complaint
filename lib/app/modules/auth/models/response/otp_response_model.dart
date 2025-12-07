class VerifyOtpResponse {
  final String status;
  final String message;
  final VerifyOtpData? data;

  VerifyOtpResponse({required this.status, required this.message, this.data});

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data:
          json['data'] != null
              ? VerifyOtpData.fromJson(Map<String, dynamic>.from(json['data']))
              : null,
    );
  }
}

class VerifyOtpData {
  final Citizen? citizen;
  final String? token;

  VerifyOtpData({this.citizen, this.token});

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyOtpData(
      citizen:
          json['citizen'] != null
              ? Citizen.fromJson(Map<String, dynamic>.from(json['citizen']))
              : null,
      token: json['token']?.toString(),
    );
  }
}

class Citizen {
  final int id;
  final String? name;
  final String? phone;
  final String? email;

  Citizen({required this.id, this.name, this.phone, this.email});

  factory Citizen.fromJson(Map<String, dynamic> json) {
    return Citizen(
      id: int.parse(json['id'].toString()),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'phone': phone, 'email': email};
  }
}
