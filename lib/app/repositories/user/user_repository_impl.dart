// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  @override
  Future<User?> login(String email, String password) async {
    try {
      var userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on PlatformException catch (e, s) {
      log(e.toString());
      log(s.toString());
      throw AuthException(message: e.message ?? 'Erro ao realizar login');
    } on FirebaseAuthException catch (e, s) {
      log(e.toString());
      log(s.toString());
      if (e.code == 'invalid-credential') {
        throw AuthException(message: 'Login ou senha inválido');
      }
      throw AuthException(message: e.message ?? 'Erro ao realizar login');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      if (e.code == 'user-not-found') {
        throw AuthException(message: 'E-mail não cadastrado');
      } else if (e.code == 'invalid-email') {
        throw AuthException(message: 'E-mail inválido');
      } else if (e.code == 'wrong-password') {
        throw AuthException(message: 'Senha incorreta');
      } else if (e.code == 'user-disabled') {
        throw AuthException(message: 'Usuário desativado');
      } else {
        throw AuthException(message: e.message ?? 'Erro ao resetar senha');
      }
    } catch (e) {
      log(e.toString());
      throw AuthException(message: 'Erro inesperado ao resetar senha');
    }
  }

  @override
  Future<User?> googleLogin() async {
    List<String>? loginMethods;
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        loginMethods = await _firebaseAuth.fetchSignInMethodsForEmail(googleUser.email);
        if (loginMethods.contains('password')) {
          throw AuthException(message: 'Você utilizou o e-mail para cadastro');
        } else {
          final googleAuth = await googleUser.authentication;
          final firebaseCredential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
          var userCredential = await _firebaseAuth.signInWithCredential(firebaseCredential);
          return userCredential.user;
        }
      }
    } on FirebaseAuthException catch (e, s) {
      log(e.toString());
      log(s.toString());
      if (e.code == 'account-exists-with-different-credential') {
        throw AuthException(
            message:
                'Login inválido, você se registrou no TodoList com os seguintes provedores: ${loginMethods?.join(',')}');
      } else {
        throw AuthException(message: 'Erro ao realizar login');
      }
    }
    return null;
  }

  @override
  Future<void> logout() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> updateDisplayName(String name) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      user.reload();
    }
  }
}

bool isEmailPasswordUser(User user) {
  return user.providerData.any((info) => info.providerId == 'password');
}

bool isGoogleUser(User user) {
  return user.providerData.any((info) => info.providerId == 'google.com');
}
