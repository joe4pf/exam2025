import 'dart:io';
import 'package:flutter/material.dart';
import 'package:examen/models/course.dart';
import 'package:examen/services/db_helper.dart';
import 'package:examen/pages/add_edit_course.dart';

class CoursesListPage extends StatefulWidget {
  const CoursesListPage({super.key});

  @override
  State<CoursesListPage> createState() => _CoursesListPageState();
}

class _CoursesListPageState extends State<CoursesListPage> {
  List<Course> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final dbHelper = DBHelper();
    final coursesList = await dbHelper.getAllCourses();

    setState(() {
      _courses = coursesList;
      _isLoading = false;
    });
  }

  Future<void> _deleteCourse(int id) async {
    final dbHelper = DBHelper();
    await dbHelper.deleteCourse(id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Cours supprimé")));
    _loadCourses();
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: course.photo.isNotEmpty && File(course.photo).existsSync()
              ? Image.file(
                  File(course.photo),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 30),
                ),
        ),
        title: Text(
          course.nom,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('👨‍🏫 Enseignant : ${course.enseignant}'),
              Text('📅 Du ${course.dateDebut} au ${course.dateFin}'),
              Text('👥 Max étudiants : ${course.maxEtudiants}'),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddEditCoursePage(courseId: course.id),
                  ),
                );
                if (result == true) {
                  _loadCourses();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmer la suppression'),
                    content: Text('Supprimer le cours "${course.nom}" ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Supprimer'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  _deleteCourse(course.id);
                }
              },
            ),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditCoursePage(courseId: course.id),
            ),
          );
          if (result == true) {
            _loadCourses();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des cours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditCoursePage(),
                ),
              );
              if (result == true) {
                _loadCourses();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
          ? const Center(child: Text('Aucun cours disponible'))
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) =>
                  _buildCourseCard(_courses[index]),
            ),
    );
  }
}
