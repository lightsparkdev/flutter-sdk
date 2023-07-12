import '../lightspark_exception.dart';

class LightsparkAuthException extends LightsparkException {
  LightsparkAuthException(String message) : super('AuthException', message);
}
