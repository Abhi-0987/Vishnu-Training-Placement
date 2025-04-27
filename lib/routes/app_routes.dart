import 'package:vishnu_training_and_placements/screens/AdminAttendanceScreen.dart';
import 'package:vishnu_training_and_placements/screens/admin_homescreen.dart';
import 'package:vishnu_training_and_placements/screens/admin_profile_screen.dart';
import 'package:vishnu_training_and_placements/screens/all_schedules_screen.dart';
import 'package:vishnu_training_and_placements/screens/event_venue.dart';
import 'package:vishnu_training_and_placements/screens/login_screen.dart';
import 'package:vishnu_training_and_placements/screens/mark_attendance.dart';
import 'package:vishnu_training_and_placements/screens/schedule_details_screen.dart';
import 'package:vishnu_training_and_placements/screens/splash_screen.dart';
import 'package:vishnu_training_and_placements/screens/student_change_password_screen.dart';
import 'package:vishnu_training_and_placements/screens/student_homescreen.dart';
import 'package:vishnu_training_and_placements/screens/student_profile.dart';
import 'package:vishnu_training_and_placements/screens/student_schedule_screen.dart';
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
  static const String eventVenue = '/event-venue-screen';
  static const String changePasswordScreen = '/change-password-screen';
  static const String adminHomeScreen = '/home-screen-admin';
  static const String allSchedulesScreen = '/all-schedules-screen';
  static const String scheduleScreen = '/schedule-screen';
  static const String studentScheduleScreen='/student-schedule-screen';

  static final routes = {
    splash: (context) => const SplashScreen(),
    welcome: (context) => const WelcomeScreen(),
    adminLogin: (context) => const StudentLoginScreen(isAdmin: true),
    studentLogin: (context) => const StudentLoginScreen(isAdmin: false),
    markAttendanceAdmin: (context) => const AdminMarkAttendence(),
    markAttendanceStudent: (context) => const MarkAttendancePage(),
    studentHomeScreen: (context) => StudentHomeScreen(),
    adminHomeScreen: (context) => AdminHomeScreen(),
    studentProfileScreen: (context) => const StudentProfileScreen(),
    adminProfileScreen: (context) => const AdminProfileScreen(),
    eventVenue: (context) => const EventVenueScreen(),
    changePasswordScreen: (_) => const ChangePasswordScreen(),
    allSchedulesScreen: (context) => const AllSchedulesScreen(),
    scheduleScreen: (context) => const ScheduleDetailsScreen(schedule: {},),
    studentScheduleScreen: (context) => const StudentSchedulesScreen(),
  };
}
