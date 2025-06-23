import 'dart:io'; // nécessaire pour File
import 'package:examen/pages/add_edit_course.dart';
import 'package:flutter/material.dart';
import 'package:examen/models/course.dart';
import 'package:examen/services/db_helper.dart';
import 'bottom_nav_page.dart';

class CourseDetailPage extends StatelessWidget {
  final int? courseId;

  const CourseDetailPage({super.key, this.courseId});

  Future<Course?> _fetchCourse() async {
    if (courseId == null) return null;
    final db = DBHelper();
    return await db.getCourseById(courseId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail des cours')),
      body: courseId == null
          ? const Center(child: Text('Aucun cours sélectionné.'))
          : FutureBuilder<Course?>(
              future: _fetchCourse(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Cours non trouvé'));
                }

                final cours = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Text(
                        cours.nom,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),

                      if (cours.photo.isNotEmpty &&
                          File(cours.photo).existsSync())
                        Image.file(
                          File(cours.photo),
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      else
                        const Icon(Icons.image_not_supported, size: 100),

                      const SizedBox(height: 12),
                      Text(
                        cours.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Text('Enseignant : ${cours.enseignant}'),
                      const SizedBox(height: 8),
                      Text('Date de début : ${cours.dateDebut}'),
                      Text('Date de fin : ${cours.dateFin}'),
                      const SizedBox(height: 8),
                      Text('Nombre max d’étudiants : ${cours.maxEtudiants}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Retour'),
                      ),
                    ],
                  ),
                );
              },
            ),

      /// ✅ FloatingActionButton pour ajouter un cours
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditCoursePage(courseId: courseId),
            ),
          );

          // Revenir en arrière en signalant que des changements ont eu lieu
          if (result == true) {
            Navigator.pop(context, true);
          }
        },
      ),

      bottomNavigationBar: const BottomNav(indexSelection: 1),
    );
  }
}
