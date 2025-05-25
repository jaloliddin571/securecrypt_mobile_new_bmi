import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    final bool canCheckBiometrics = await auth.canCheckBiometrics;
    final bool isDeviceSupported = await auth.isDeviceSupported();

    if (canCheckBiometrics && isDeviceSupported) {
      try {
        return await auth.authenticate(
          localizedReason: 'Ilovaga kirish uchun Face ID yoki Fingerprint kiriting',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
      } catch (e) {
        print("Biometric error: $e");
        return false;
      }
    }
    return false;
  }
}
