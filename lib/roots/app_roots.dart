import 'package:vishnu_training_and_placements/screens/AdminAttendanceScreen.dart';
import 'package:vishnu_training_and_placements/screens/admin_profile_screen.dart';
import 'package:vishnu_training_and_placements/screens/event_venue.dart';
import 'package:vishnu_training_and_placements/screens/login_screen.dart';
import 'package:vishnu_training_and_placements/screens/mark_attendance.dart';
import 'package:vishnu_training_and_placements/screens/splash_screen.dart';
import 'package:vishnu_training_and_placements/screens/student_change_password.dart';
import 'package:vishnu_training_and_placements/screens/student_homescreen.dart';
import 'package:vishnu_training_and_placements/screens/student_profile.dart';
import 'package:vishnu_training_and_placements/screens/welcome_screen.dart';

class AppRoutes {
  // Route names as static constants
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String adminLogin = '/admin-login';
  static const String studentLogin = '/student-login';
  static const String markAttendanceAdmin = '/mark-attendance-admin';
  static const String markAttendanceStudent = '/mark-attendance-student';
  static const String studentHomeScreen = '/home-screen-student';
  static const String studentProfileScreen = '/profile-screen-student';
  static const String adminProfileScreen = '/profile-screen-admin';
  static const String event_venue = '/event-venue-screen';
  static const String changePasswordScreen = '/change-password-screen';

  // Define route map
  static final routes = {
    splash: (context) => const SplashScreen(),
    welcome: (context) => const WelcomeScreen(),
    adminLogin: (context) => const StudentLoginScreen(isAdmin: true),
    studentLogin: (context) => const StudentLoginScreen(isAdmin: false),
    markAttendanceAdmin: (context) => const AdminMarkAttendence(),
    markAttendanceStudent: (context) => const MarkAttendancePage(),
    studentHomeScreen: (context) => StudentHomeScreen(),
    studentProfileScreen: (context) => const StudentProfileScreen(),
    adminProfileScreen: (context) => const AdminProfileScreen(),
    event_venue: (context) => const EventVenueScreen(),
    changePasswordScreen: (_) => const ChangePasswordScreen(),
  };
}
