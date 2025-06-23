import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:examen/models/student.dart';
import 'package:examen/services/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class AddEditStudentPage extends StatefulWidget {
  final String? studentId;

  const AddEditStudentPage({super.key, this.studentId});

  @override
  _AddEditStudentPageState createState() => _AddEditStudentPageState();
}

class _AddEditStudentPageState extends State<AddEditStudentPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _classeController = TextEditingController();
  final _telephoneController = TextEditingController();

  File? _photoFile; // fichier photo sélectionné
  bool _loading = false;
  String? selectedSexe;

  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    if (widget.studentId != null) {
      _loadStudent();
    }
  }

  Future<void> _loadStudent() async {
    setState(() => _loading = true);
    try {
      final student = await _dbHelper.getStudentById(widget.studentId!);
      if (student != null) {
        _nomController.text = student.nom;
        _prenomController.text = student.prenom;
        _emailController.text = student.email;
        _dateNaissanceController.text = student.dateNaissance;
        _classeController.text = student.classe;
        _telephoneController.text = student.telephone;
        selectedSexe = student.sexe;
        if (student.photo.isNotEmpty) {
          _photoFile = File(student.photo);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur chargement étudiant')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
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
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final id = widget.studentId ?? const Uuid().v4();
    final photoPath = _photoFile?.path ?? '';

    final student = Student(
      id: id,
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      email: _emailController.text.trim(),
      dateNaissance: _dateNaissanceController.text.trim(),
      classe: _classeController.text.trim(),
      telephone: _telephoneController.text.trim(),
      photo: photoPath,
      sexe: selectedSexe!,
    );

    try {
      final db = await _dbHelper.database;
      final exists = await _dbHelper.getStudentById(id) != null;

      if (exists) {
        await db.update(
          'students',
          student.toMap(),
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        await db.insert(
          'students',
          student.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Succès'),
          content: Text(
            widget.studentId == null
                ? 'Étudiant ajouté avec succès.'
                : 'Étudiant modifié avec succès.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                Navigator.of(context).pop(true); // Revenir à la liste
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur sauvegarde étudiant')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _dateNaissanceController.dispose();
    _classeController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.studentId == null
              ? 'Ajouter un étudiant'
              : 'Modifier l’étudiant',
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
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _photoFile != null
                              ? FileImage(_photoFile!)
                              : null,
                          child: _photoFile == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Cliquez sur l\'avatar pour changer la photo',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Entrez un nom'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _prenomController,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Entrez un prénom'
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Sexe',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedSexe,
                      items: ['Homme', 'Femme'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedSexe = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Veuillez choisir un sexe' : null,
                    ),
                    const SizedBox(height: 16),

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Entrez un email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dateNaissanceController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date de naissance',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _selectDate(_dateNaissanceController),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Entrez une date'
                          : null,
                    ),

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _classeController,
                      decoration: const InputDecoration(labelText: 'Classe'),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Entrez une classe'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _telephoneController,
                      decoration: const InputDecoration(labelText: 'Téléphone'),
                      keyboardType: TextInputType.phone,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Entrez un téléphone'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _saveStudent,
                      child: Text(
                        widget.studentId == null ? 'Ajouter' : 'Enregistrer',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
