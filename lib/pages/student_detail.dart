import 'package:examen/pages/add_edit_student.dart';
import 'package:flutter/material.dart';
import 'package:examen/services/db_helper.dart';
import 'package:examen/models/student.dart';
import 'dart:io';
import 'bottom_nav_page.dart';

class StudentDetailPage extends StatelessWidget {
  final String? studentId;

  const StudentDetailPage({super.key, this.studentId});

  Future<Student?> _getStudent() async {
    if (studentId == null) return null;
    return await DBHelper().getStudentById(studentId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Détails des étudiants")),
      body: FutureBuilder<Student?>(
        future: _getStudent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final student = snapshot.data;
          if (student == null) {
            return const Center(child: Text('Aucun Étudiant trouvé'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: student.photo.isNotEmpty
                      ? ClipOval(
                          child: Image.file(
                            File(student.photo),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100),
                          ),
                        )
                      : const CircleAvatar(
                          radius: 60,
                          child: Icon(Icons.person, size: 60),
                        ),
                ),
                const SizedBox(height: 24),
                Text(
                  '${student.nom} ${student.prenom}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text('📧 Email : ${student.email}'),
                const SizedBox(height: 8),
                Text('🎂 Date de naissance : ${student.dateNaissance}'),
                const SizedBox(height: 8),
                Text('🏫 Classe : ${student.classe}'),
                const SizedBox(height: 8),
                Text('📞 Téléphone : ${student.telephone}'),
              ],
            ),
          );
        },
      ),

      /// 🔽 FAB pour ajouter un nouvel étudiant
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditStudentPage()),
          );
        },
        backgroundColor: Colors.green,
        tooltip: 'Ajouter un étudiant',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNav(indexSelection: 2),
    );
  }
}
