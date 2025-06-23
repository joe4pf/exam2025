import 'package:examen/pages/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:examen/services/db_helper.dart';
import 'bottom_nav_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalEtudiants = 0;
  int hommes = 0;
  int femmes = 0;
  int totalCours = 0;
  Map<String, int> inscriptionsParCours = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = DBHelper();

    final etudiants = await db.getAllStudents();
    final cours = await db.getAllCourses();

    int h = 0, f = 0;
    for (var e in etudiants) {
      if (e.sexe == 'Homme') h++;
      if (e.sexe == 'Femme') f++;
    }

    Map<String, int> parCours = {};
    for (var c in cours) {
      final count = await db.getEtudiantCountByCourseId(c.id);
      parCours[c.nom] = count;
    }

    setState(() {
      totalEtudiants = etudiants.length;
      hommes = h;
      femmes = f;
      totalCours = cours.length;
      inscriptionsParCours = parCours;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        backgroundColor: Colors.blue,
      ),
      drawer: const MenuDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Statistiques Générales',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: ListTile(
                title: const Text('Étudiants inscrits'),
                trailing: Text('$totalEtudiants'),
              ),
            ),
            Card(
              elevation: 4,
              child: ListTile(
                title: const Text('Hommes'),
                trailing: Text('$hommes'),
              ),
            ),
            Card(
              elevation: 4,
              child: ListTile(
                title: const Text('Femmes'),
                trailing: Text('$femmes'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Répartition Hommes / Femmes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: (hommes + femmes == 0)
                      ? [
                          PieChartSectionData(
                            color: Colors.blue,
                            value: 1,
                            title: 'Hommes (0)',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.pink,
                            value: 1,
                            title: 'Femmes (0)',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ]
                      : [
                          PieChartSectionData(
                            color: Colors.blue,
                            value: hommes.toDouble(),
                            title: 'Hommes ($hommes)',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.pink,
                            value: femmes.toDouble(),
                            title: 'Femmes ($femmes)',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],

                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  // facultatif pour éviter erreurs de touch
                ),
              ),
            ),

            const SizedBox(height: 20),
            Card(
              elevation: 4,
              child: ListTile(
                title: const Text('Total des cours créés'),
                trailing: Text('$totalCours'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Étudiants par cours',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...inscriptionsParCours.entries.map(
              (entry) => ListTile(
                leading: const Icon(Icons.book),
                title: Text(entry.key),
                trailing: Text('${entry.value} inscrits'),
              ),
            ),

            // 🔽 Ajout de matières par défaut avec 0 inscrits
            const Divider(),
            const ListTile(
              leading: Icon(Icons.book),
              title: Text('Math'),
              trailing: Text('0 inscrits'),
            ),
            const ListTile(
              leading: Icon(Icons.book),
              title: Text('Français'),
              trailing: Text('0 inscrits'),
            ),
            const ListTile(
              leading: Icon(Icons.book),
              title: Text('Anglais'),
              trailing: Text('0 inscrits'),
            ),
            const ListTile(
              leading: Icon(Icons.book),
              title: Text('Histoire'),
              trailing: Text('0 inscrits'),
            ),
            const ListTile(
              leading: Icon(Icons.book),
              title: Text('Géographie'),
              trailing: Text('0 inscrits'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(indexSelection: 0),
    );
  }
}
