import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/core.dart';
import 'view/view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controllers
  Get.put(AuthController());
  Get.put(MeetingController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Meet Clone',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomeScreen()),
        GetPage(name: '/meeting', page: () => const MeetingScreen()),
        GetPage(
          name: '/preview',
          page: () => PreviewScreen(meetingId: '', isNewMeeting: false),
        ),
      ],
    );
  }
}
