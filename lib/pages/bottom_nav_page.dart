import 'package:flutter/material.dart';
import 'package:examen/pages/dashboard.dart';
import 'package:examen/pages/course_detail.dart';
import 'package:examen/pages/student_detail.dart';

class BottomNav extends StatelessWidget {
  final int indexSelection;

  const BottomNav({super.key, required this.indexSelection});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: indexSelection,
      selectedItemColor: Colors.blue[800],
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      onTap: (newIndex) {
        if (newIndex != indexSelection) {
          switch (newIndex) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CourseDetailPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const StudentDetailPage()),
              );
              break;
          }
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Cours'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Étudiants'),
      ],
    );
  }
}
