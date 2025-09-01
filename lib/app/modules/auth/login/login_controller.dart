import 'package:todo_list_provider/app/core/notifier/default_change_notifier.dart';
import 'package:todo_list_provider/app/exception/auth_exception.dart';

import 'package:todo_list_provider/app/services/user/user_service.dart';

class LoginController extends DefaultChangeNotifier {
  final UserService _userService;
  String? infoMessage;
  LoginController({
    required UserService userService,
  }) : _userService = userService;

  bool get hasInfo => infoMessage != null;

  Future<void> login(String email, String password) async {
    try {
      showLoadingAndResetState();
      infoMessage = null;
      notifyListeners();

      final user = await _userService.login(email, password);
      if (user != null) {
        success();
      } else {
        setError(error);
      }
    } on AuthException catch (e) {
      setError(e.message);
    } finally {
      hideLoading();
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      showLoadingAndResetState();
      infoMessage = null;
      notifyListeners();
      await _userService.forgotPassword(email);
      infoMessage = 'Se existir uma conta com este e-mail, enviaremos um link para resetar a senha';
    } on AuthException catch (e) {
      setError(e.message);
    } catch (e) {
      setError('Erro');
    } finally {
      hideLoading();
      notifyListeners();
    }
  }
}
