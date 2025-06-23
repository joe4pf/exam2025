import 'dart:io';
import 'package:flutter/material.dart';
import 'package:examen/models/student.dart';
import 'package:examen/services/db_helper.dart';
import 'package:examen/pages/add_edit_student.dart';

class StudentsListPage extends StatefulWidget {
  const StudentsListPage({super.key});

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  TextEditingController _searchController = TextEditingController();
  List<Student> _allStudents = [];

  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _searchStudents(String query) {
    final filtered = _allStudents.where((student) {
      final fullName = '${student.prenom} ${student.nom}'.toLowerCase();
      return fullName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _students = filtered;
    });
  }

  Future<void> _loadStudents() async {
    final dbHelper = DBHelper();
    final studentsList = await dbHelper.getAllStudents();

    setState(() {
      _allStudents = studentsList;
      _students = studentsList;
      _isLoading = false;
    });
  }

  Future<void> _deleteStudent(String id) async {
    final dbHelper = DBHelper();
    await dbHelper.deleteStudent(id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Étudiant supprimé")));
    _loadStudents();
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: student.photo.isNotEmpty && File(student.photo).existsSync()
            ? CircleAvatar(
                backgroundImage: FileImage(File(student.photo)),
                radius: 30,
              )
            : const CircleAvatar(radius: 30, child: Icon(Icons.person)),
        title: Text(
          '${student.prenom} ${student.nom}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${student.classe}  Tel.: ${student.telephone}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirmer la suppression'),
                content: Text('Supprimer ${student.prenom} ${student.nom} ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await _deleteStudent(student.id);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des étudiants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditStudentPage(),
                ),
              );
              if (result == true) {
                _loadStudents();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchStudents,
                    decoration: InputDecoration(
                      labelText: 'Rechercher un étudiant',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _students.isEmpty
                      ? const Center(child: Text('Aucun étudiant trouvé'))
                      : ListView.builder(
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            return _buildStudentCard(_students[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
