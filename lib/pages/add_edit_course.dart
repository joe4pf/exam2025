import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:examen/models/course.dart';
import 'package:examen/services/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class AddEditCoursePage extends StatefulWidget {
  final int? courseId;

  const AddEditCoursePage({super.key, this.courseId});

  @override
  _AddEditCoursePageState createState() => _AddEditCoursePageState();
}

class _AddEditCoursePageState extends State<AddEditCoursePage> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _enseignantController = TextEditingController();
  final _dateDebutController = TextEditingController();
  final _dateFinController = TextEditingController();
  final _maxEtudiantsController = TextEditingController();

  File? _photoFile;
  bool _loading = false;
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    if (widget.courseId != null) {
      _loadCourse();
    }
  }

  Future<void> _loadCourse() async {
    setState(() => _loading = true);
    try {
      final course = await _dbHelper.getCourseById(widget.courseId!);
      if (course != null) {
        _nomController.text = course.nom;
        _descriptionController.text = course.description;
        _enseignantController.text = course.enseignant;
        _dateDebutController.text = course.dateDebut;
        _dateFinController.text = course.dateFin;
        _maxEtudiantsController.text = course.maxEtudiants.toString();
        if (course.photo.isNotEmpty) {
          _photoFile = File(course.photo);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erreur chargement cours')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickCourseImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final course = Course(
      id: widget.courseId ?? DateTime.now().millisecondsSinceEpoch,
      nom: _nomController.text.trim(),
      photo: _photoFile?.path ?? '',
      description: _descriptionController.text.trim(),
      enseignant: _enseignantController.text.trim(),
      dateDebut: _dateDebutController.text.trim(),
      dateFin: _dateFinController.text.trim(),
      maxEtudiants: int.tryParse(_maxEtudiantsController.text.trim()) ?? 0,
    );

    try {
      final db = await _dbHelper.database;
      final exists = widget.courseId != null;

      if (exists) {
        await db.update(
          'courses',
          course.toMap(),
          where: 'id = ?',
          whereArgs: [widget.courseId],
        );
      } else {
        await db.insert(
          'courses',
          course.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Succès'),
          content: Text(
            widget.courseId == null
                ? 'Le cours a été ajouté avec succès.'
                : 'Le cours a été modifié avec succès.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erreur sauvegarde cours')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _enseignantController.dispose();
    _dateDebutController.dispose();
    _dateFinController.dispose();
    _maxEtudiantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.courseId == null ? 'Ajouter un cours' : 'Modifier le cours',
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    GestureDetector(
                      onTap: _pickCourseImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                          image: _photoFile != null
                              ? DecorationImage(
                                  image: FileImage(_photoFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _photoFile == null
                            ? const Center(
                                child: Text('Cliquer pour ajouter une photo'),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du cours',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Champ requis'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Champ requis'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _enseignantController,
                      decoration: const InputDecoration(
                        labelText: 'Enseignant',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Champ requis'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dateDebutController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date de début',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _selectDate(_dateDebutController),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Champ requis'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dateFinController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date de fin',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _selectDate(_dateFinController),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Champ requis'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _maxEtudiantsController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre max d\'étudiants',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Champ requis';
                        if (int.tryParse(value) == null)
                          return 'Entrez un nombre valide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _saveCourse,
                      child: Text(
                        widget.courseId == null ? 'Ajouter' : 'Enregistrer',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
