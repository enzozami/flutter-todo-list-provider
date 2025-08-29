import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_list_provider/app/exception/auth_exception.dart';
import 'package:todo_list_provider/app/repositories/user/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuth _firebaseAuth;

  UserRepositoryImpl({required FirebaseAuth firebaseAuth}) : _firebaseAuth = firebaseAuth;

  @override
  Future<User?> register(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e, s) {
      log(e.toString());
      log(s.toString());
      if (e.code == 'email-already-in-use') {
        log('The account already exists for that email.');
        throw AuthException(message: 'E-mail já utilizado, por favor escolha outro e-mail');
      }
    } catch (e) {
      log(e.toString());
      throw AuthException(message: 'Erro inesperado ao registrar usuário');
    }
    return null;
  }
}

bool isEmailPasswordUser(User user) {
  return user.providerData.any((info) => info.providerId == 'password');
}

bool isGoogleUser(User user) {
  return user.providerData.any((info) => info.providerId == 'google.com');
}
