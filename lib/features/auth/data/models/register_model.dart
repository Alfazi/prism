import 'package:equatable/equatable.dart';
import 'user_model.dart';

class RegisterRequest extends Equatable {
  final String name;
  final String username;
  final String email;
  final String password;
  final String passwordRepeat;
  final String? profilePictureUrl;
  final String? phoneNumber;
  final String? bio;
  final String? website;

  const RegisterRequest({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.passwordRepeat,
    this.profilePictureUrl,
    this.phoneNumber,
    this.bio,
    this.website,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'passwordRepeat': passwordRepeat,
      'profilePictureUrl': profilePictureUrl ?? '',
      'phoneNumber': phoneNumber ?? '',
      'bio': bio ?? '',
      'website': website ?? '',
    };
  }

  @override
  List<Object?> get props => [
    name,
    username,
    email,
    password,
    passwordRepeat,
    profilePictureUrl,
    phoneNumber,
    bio,
    website,
  ];
}

class RegisterResponse extends Equatable {
  final String code;
  final String status;
  final String message;
  final UserModel data;

  const RegisterResponse({
    required this.code,
    required this.status,
    required this.message,
    required this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      code: json['code'] as String? ?? '200',
      status: json['status'] as String? ?? 'OK',
      message: json['message'] as String? ?? '',
      data: UserModel.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  List<Object?> get props => [code, status, message, data];
}
