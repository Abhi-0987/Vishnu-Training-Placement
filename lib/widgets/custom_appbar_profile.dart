import 'package:flutter/material.dart';

class CustomAppBarProfile extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomAppBarProfile({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 40);

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
              Image.asset('assets/logo.png', height: height * 0.06),
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
          IconButton(
            icon: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/profile-screen-student');
            },
          ),
        ],
      ),
    );
  }
}