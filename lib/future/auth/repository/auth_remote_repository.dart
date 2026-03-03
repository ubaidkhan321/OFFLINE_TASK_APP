import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as htpp;
import 'package:offline_app/core/constants/global.url.dart';
import 'package:offline_app/core/services/sp_services.dart';
import 'package:offline_app/future/auth/repository/local_auth_remote_repository.dart';
import 'package:offline_app/model/user_model.dart';

class AuthRemoteRepo {
  static String signupurl = Globals.SIGNUP;
  static String loginurl = Globals.LOGIN;
  static String isValidToken = Globals.ISVALIDTOKEN;
  final String auth = Globals.AUTHENTICATE_USER;
  final authlocalRepository = AuthLocalRepository();
  final _service = SpServices();
  Future<UserModel> signUp(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final response = await htpp.post(Uri.parse(signupurl),
          headers: {
            'Content-Type': 'application/json',
          },
          body:
              jsonEncode({'name': name, 'email': email, 'password': password}));
      if (response.statusCode != 201) {
        throw jsonDecode(response.body)['error'];
      }

      return UserModel.fromJson(response.body);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw e.toString();
    }
  }

  Future<UserModel> login(
      {required String email, required String password}) async {
    try {
      final response = await htpp.post(Uri.parse(loginurl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"email": email, "password": password}));
      if (response.statusCode != 200) {
        throw jsonDecode(response.body)['message'];
      }
      return UserModel.fromJson(response.body);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final token = await _service.getToken();

      if (token == null) {
        return null;
      }
      final response = await htpp.post(Uri.parse(isValidToken), headers: {
        "x-auth-token": token,
        'Content-Type': 'application/json',
      });

      if (response.statusCode != 200 || jsonDecode(response.body) == false) {
        return null;
      }
      final userResponse = await htpp.get(Uri.parse(auth), headers: {
        "x-auth-token": token,
        'Content-Type': 'application/json',
      });
      if (userResponse.statusCode != 200) {
        throw jsonDecode(userResponse.body)['error'];
      }
      return UserModel.fromJson(userResponse.body);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      final user = await authlocalRepository.getUser();
      return user;
    }
  }
}
