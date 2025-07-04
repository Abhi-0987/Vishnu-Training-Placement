import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
<<<<<<< HEAD
=======
import 'package:vishnu_training_and_placements/screens/admin_profile_screen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
void main() async{
   WidgetsFlutterBinding.ensureInitialized();
>>>>>>> deb136f (added hive to cache data)

  // // Initialize Hive & get storage directory
  // final appDocDir = await getApplicationDocumentsDirectory();
  // await Hive.initFlutter(appDocDir.path);
   if (!kIsWeb) {
    // Only run this on mobile/desktop platforms
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);
  } else {
    // On web, Hive.initFlutter() uses default values
    await Hive.initFlutter();
  }

  // Open a common box for all roles
  await Hive.openBox('infoBox');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      //home: AdminProfileScreen(),
    );
  }
}
