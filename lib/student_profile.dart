import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vishnu_training_and_placements/widgets/background.dart';
import 'package:vishnu_training_and_placements/widgets/card.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PlacementProProfile(),
  ));
}

class PlacementProProfile extends StatelessWidget {
  const PlacementProProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset('assets/logo.png', height: size.height * 0.08),
                Text(
                  'Vishnu',
                  style: TextStyle(
                      fontSize: size.width * 0.08,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Alanta',
                      color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Training and", style: TextStyle(fontSize: size.width * 0.035, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("Placements", style: TextStyle(fontSize: size.width * 0.035, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Background(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Text("Profile", style: TextStyle(fontSize: size.width * 0.06, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 16),
                _buildProfileCard(size),
                const SizedBox(height: 16),
                Text("Statistics", style: TextStyle(fontSize: size.width * 0.07, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Center(child: buildPieChart(size)),
                
                Row(
                  children: [
                    SizedBox(width: size.width * 0.20),
                    _buildLegend(const Color(0xFF18B0C1), "Present"),
                    const SizedBox(width: 16),
                    _buildLegend(const Color(0xFFB45AA8), "Absent"),
                  ],
                ),
                
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildInfoCard("Total Sessions", "8", Colors.white, size),
                    const SizedBox(width: 16),
                    _buildInfoCard("Longest Streak", "1 day", Colors.white, size),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Account"),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Size size) {
    return BlurredCard(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Row(
          children: [
            CircleAvatar(
              radius: size.width * 0.12,
              backgroundImage: const AssetImage('assets/profile.png'),
            ),
            SizedBox(width: size.width * 0.04),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("N.V Dheeraj", style: TextStyle(fontSize: size.width * 0.045, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("22211A1277", style: TextStyle(fontSize: size.width * 0.035, color: Colors.white)),
                Text("Information Technology", style: TextStyle(fontSize: size.width * 0.035, color: Colors.white)),
                Text("Section B", style: TextStyle(fontSize: size.width * 0.035, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.white)),
      ],
    );
  }

  Widget buildPieChart(Size size) {
    return SizedBox(
      height: size.height * 0.30,
      width: size.width * 0.50,
      child: PieChart(
        PieChartData(
          centerSpaceRadius: size.width * 0.10,
          sections: [
            PieChartSectionData(value: 60, color: const Color(0xFF18B0C1), title: '60%', radius: size.width * 0.20, titleStyle: TextStyle(fontSize: size.width * 0.04, fontWeight: FontWeight.bold, color: Colors.white)),
            PieChartSectionData(value: 40, color: const Color(0xFFB45AA8), title: '40%', radius: size.width * 0.20, titleStyle: TextStyle(fontSize: size.width * 0.04, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color, Size size) {
    return Expanded(
      child: BlurredCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: size.width * 0.10, height: 4, color: Colors.yellow, margin: EdgeInsets.only(bottom: size.height * 0.01)),
            Text(title, style: TextStyle(fontSize: size.width * 0.04, color: Colors.yellow[50])),
            SizedBox(height: size.height * 0.01),
            Text(value, style: TextStyle(fontSize: size.width * 0.07, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
