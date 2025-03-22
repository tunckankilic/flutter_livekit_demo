import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthController extends GetxController {
  final Rx<String?> _userId = Rx<String?>(null);
  final Rx<String?> _userName = Rx<String?>(null);

  String? get userId => _userId.value;
  String? get userName => _userName.value;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId.value = prefs.getString('userId');
    _userName.value = prefs.getString('userName');
  }

  Future<void> signIn(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = const Uuid().v4();

    await prefs.setString('userId', uuid);
    await prefs.setString('userName', name);

    _userId.value = uuid;
    _userName.value = name;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName');

    _userId.value = null;
    _userName.value = null;
  }

  bool get isSignedIn => _userId.value != null && _userName.value != null;
}
