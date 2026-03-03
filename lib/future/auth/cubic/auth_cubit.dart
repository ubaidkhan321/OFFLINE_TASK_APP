import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:offline_app/core/services/sp_services.dart';
import 'package:offline_app/future/auth/repository/auth_remote_repository.dart';
import 'package:offline_app/future/auth/repository/local_auth_remote_repository.dart';
import 'package:offline_app/model/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitialState());
  final remoteRepository = AuthRemoteRepo();
  final authlocalRepository = AuthLocalRepository();
  final _services = SpServices();

  void getUserData() async {
    try {
      emit(AuthloadingState());
      final userModel = await remoteRepository.getUserData();
      if (userModel != null) {
        await authlocalRepository.insertUser(userModel);
        emit(AuthLoggedIn(userModel));
      } else {
        emit(AuthInitialState());
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  void signUp(
      {required String name,
      required String email,
      required String password}) async {
    try {
      emit(AuthloadingState());
      await remoteRepository.signUp(
          name: name, email: email, password: password);
      emit(AuthSignUp());
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  void login({required String email, required String password}) async {
    try {
      emit(AuthloadingState());
      UserModel result =
          await remoteRepository.login(email: email, password: password);
      if (result.token.isNotEmpty) {
        await _services.setToken(result.token.toString());
      }
      await authlocalRepository.insertUser(result);
      emit(AuthLoggedIn(result));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
}
