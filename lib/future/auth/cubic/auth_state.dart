part of "auth_cubit.dart";

sealed class AuthState {}

final class AuthInitialState extends AuthState {}

final class AuthloadingState extends AuthState {}

final class AuthLoggedIn extends AuthState {
  final UserModel user;
  AuthLoggedIn(this.user);
}

final class AuthSignUp extends AuthState {}

final class AuthErrorState extends AuthState {
  final String error;
  AuthErrorState(this.error);
}
