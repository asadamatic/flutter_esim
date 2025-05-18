import 'flutter_esim_platform_interface.dart';

class FlutterEsim {

  /// Check support eSIM.
  Future<bool> isSupportESim() async {
    return FlutterEsimPlatform.instance.isSupportESim();
  }

  /// Install eSIM.
  Future<String> installEsimProfile(String profile) async {
    return FlutterEsimPlatform.instance.installEsimProfile(profile);
  }

  /// Instructions setup eSIM.
  Future<String> instructions() async {
    return FlutterEsimPlatform.instance.instructions();
  }

  Stream<dynamic> get onEvent => FlutterEsimPlatform.instance.onEvent;
}
