import 'package:vishnu_training_and_placements/screens/admin_attendance_screen.dart';
import 'package:vishnu_training_and_placements/screens/admin_homescreen.dart';
import 'package:vishnu_training_and_placements/screens/admin_profile_screen.dart';
import 'package:vishnu_training_and_placements/screens/all_schedules_screen.dart';
import 'package:vishnu_training_and_placements/screens/coordinator_profile_screen.dart';
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

enum UserRole { admin, coordinator, student }

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String adminLogin = '/admin-login';
  static const String coordinatorLogin = '/coordinator-login';
  static const String studentLogin = '/student-login';
  static const String markAttendanceAdmin = '/mark-attendance-admin';
  static const String markAttendanceStudent = '/mark-attendance-student';
  static const String studentHomeScreen = '/home-screen-student';
  static const String studentProfileScreen = '/profile-screen-student';
  static const String adminProfileScreen = '/profile-screen-admin';
  static const String coordinatorProfileScreen = '/profile-screen-coordinator';
  static const String eventVenue = '/event-venue-screen';
  static const String changePasswordScreen = '/change-password-screen';
  static const String adminHomeScreen = '/home-screen-admin';
  static const String allSchedulesScreen = '/all-schedules-screen';
  static const String scheduleScreen = '/schedule-screen';
  static const String studentScheduleScreen = '/student-schedule-screen';

  //routes
  static final routes = {
    splash: (context) => const SplashScreen(),
    welcome: (context) => const WelcomeScreen(),
    adminLogin: (context) => const LoginScreen(role: UserRole.admin),
    coordinatorLogin:
        (context) => const LoginScreen(role: UserRole.coordinator),
    studentLogin: (context) => const LoginScreen(role: UserRole.student),
    markAttendanceAdmin: (context) => const AdminMarkAttendence(),
    markAttendanceStudent: (context) => const MarkAttendancePage(),
    studentHomeScreen: (context) => StudentHomeScreen(),
    adminHomeScreen: (context) => AdminHomeScreen(),
    studentProfileScreen: (context) => const StudentProfileScreen(schedule: {},),// Pass an empty map for now
    adminProfileScreen: (context) => const AdminProfileScreen(),
    coordinatorProfileScreen: (context) => const CoordinatorProfileScreen(),
    eventVenue: (context) => const EventVenueScreen(),
    changePasswordScreen: (context) => const ChangePasswordScreen(),
    allSchedulesScreen: (context) => const AllSchedulesScreen(),
    scheduleScreen: (context) => const ScheduleDetailsScreen(schedule: {}),
    studentScheduleScreen: (context) => const StudentSchedulesScreen(),
  };
}
