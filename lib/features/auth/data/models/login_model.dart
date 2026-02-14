import 'package:equatable/equatable.dart';
import 'user_model.dart';

class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }

  @override
  List<Object?> get props => [email, password];
}

class LoginResponse extends Equatable {
  final String code;
  final String status;
  final String message;
  final UserModel user;
  final String token;

  const LoginResponse({
    required this.code,
    required this.status,
    required this.message,
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      code: json['code'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  @override
  List<Object?> get props => [code, status, message, user, token];
}
