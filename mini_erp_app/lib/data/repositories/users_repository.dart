import '../providers/users_provider.dart';

class UsersRepository {
  UsersRepository(this._provider);

  final UsersProvider _provider;

  Future<void> updateFcmToken(String fcmToken) =>
      _provider.updateFcmToken(fcmToken);

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return _provider.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
