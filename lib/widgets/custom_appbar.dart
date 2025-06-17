import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.showProfileIcon = true,
    this.isProfileScreen = false,
  });

  final bool showProfileIcon;
  final bool isProfileScreen;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40);
  Future<void> _handleProfileIconTap(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? 'student';
    if (context.mounted) {
      if (role == 'admin') {
        Navigator.pushNamed(context, AppRoutes.adminProfileScreen);
      } else if (role == 'coordinator') {
        Navigator.pushNamed(context, AppRoutes.coordinatorProfileScreen);
      } else {
        Navigator.pushNamed(context, AppRoutes.studentProfileScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;
    final double width = screenSize.width;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: height * 0.08,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Image.asset('assets/logo.png', height: height * 0.06),
              ),
              SizedBox(width: width * 0.15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vishnu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Alata',
                    ),
                  ),
                  SizedBox(width: width * 0.02),
                  Column(
                    children: [
                      Text(
                        'Training and',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.035,
                          fontFamily: 'Alata',
                        ),
                      ),
                      Text(
                        'Placements',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.035,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (showProfileIcon)
            IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(
                  isProfileScreen ? Icons.settings : Icons.person,
                  color: Colors.white,
                ),
              ),
              onPressed: () => _handleProfileIconTap(context),
            ),
        ],
      ),
    );
  }
}
