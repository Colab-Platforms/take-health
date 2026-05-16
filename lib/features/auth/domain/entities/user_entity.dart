import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? email;
  final String? name;
  final String? authProvider;

  const UserEntity({
    this.email,
    this.name,
    this.authProvider,
  });

  UserEntity copyWith({
    String? email,
    String? name,
    String? authProvider,
  }) {
    return UserEntity(
      email: email ?? this.email,
      name: name ?? this.name,
      authProvider: authProvider ?? this.authProvider,
    );
  }

  @override
  List<Object?> get props => [email, name, authProvider];
}
