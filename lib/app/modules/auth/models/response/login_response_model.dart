class LoginResponse {
  final String status;
  final String message;
  final LoginData? data;

  LoginResponse({required this.status, required this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data:
          json['data'] != null
              ? LoginData.fromJson(Map<String, dynamic>.from(json['data']))
              : null,
    );
  }
}

class LoginData {
  final Citizen? citizen;
  final String? token;

  LoginData({this.citizen, this.token});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
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
  final String? email;
  final String? idNumber;
  final String? phone;
  final int? isVerified;
  final String? createdAt;
  final String? updatedAt;

  Citizen({
    required this.id,
    this.name,
    this.email,
    this.idNumber,
    this.phone,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory Citizen.fromJson(Map<String, dynamic> json) {
    return Citizen(
      id: int.parse(json['id'].toString()),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      idNumber: json['id_number']?.toString(),
      phone: json['phone']?.toString(),
      isVerified:
          json['is_verified'] != null
              ? int.tryParse(json['is_verified'].toString())
              : null,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'id_number': idNumber,
      'phone': phone,
      'is_verified': isVerified,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
