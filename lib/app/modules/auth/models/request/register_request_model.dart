class RegisterRequest {
  final String email;
  final String name;
  final String pass;
  final String passConfirm;
  final String idNumber;

  RegisterRequest({
    required this.email,
    required this.name,
    required this.pass,
    required this.passConfirm,
    required this.idNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'password': pass,
      'password_confirmation': passConfirm,
      'id_number': idNumber,
    };
  }
}
