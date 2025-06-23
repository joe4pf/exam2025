import 'package:examen/models/course.dart';
import 'package:examen/models/student.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(
      path,
      version: 2, // version mise à jour
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Migration vers la version 2
          await db.execute('ALTER TABLE students ADD COLUMN photo TEXT');
          await db.execute('ALTER TABLE students ADD COLUMN sexe TEXT');
        }
      },
    );
  }

  Future<int> getEtudiantCountByCourseId(int courseId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM inscriptions WHERE courseId = ?',
      [courseId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users(
        uid TEXT PRIMARY KEY,
        nom TEXT,
        prenom TEXT,
        email TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE students(
        id TEXT PRIMARY KEY,
        nom TEXT,
        prenom TEXT,
        email TEXT,
        dateNaissance TEXT,
        classe TEXT,
        telephone TEXT,
        sexe TEXT,
        photo TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY,
        nom TEXT,
        photo TEXT,
        description TEXT,
        enseignant TEXT,
        dateDebut TEXT,
        dateFin TEXT,
        maxEtudiants INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE inscriptions(
        courseId INTEGER,
        studentId TEXT,
        PRIMARY KEY(courseId, studentId)
      )
    ''');
  }

  Future<void> saveUserData({
    required String uid,
    required String nom,
    required String prenom,
    required String email,
  }) async {
    final db = await database;
    await db.insert('users', {
      'uid': uid,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );

    return results.isNotEmpty ? results.first : null;
  }

  Future<Student?> getStudentById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );

    return maps.isNotEmpty ? Student.fromMap(maps.first) : null;
  }

  Future<Course?> getCourseById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );

    return result.isNotEmpty ? Course.fromMap(result.first) : null;
  }

  Future<List<Course>> getAllCourses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('courses');
    return maps.map((map) => Course.fromMap(map)).toList();
  }

  Future<int> insertCourse(Course course) async {
    final db = await database;
    return await db.insert(
      'courses',
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateCourse(Course course) async {
    final db = await database;
    return await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<int> deleteCourse(int id) async {
    final db = await database;
    return await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  // Inscription d’un étudiant à un cours avec vérification
  Future<bool> inscrireEtudiant(int courseId, String studentId) async {
    final db = await database;

    // Vérifie le nombre actuel d’inscriptions
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM inscriptions WHERE courseId = ?',
      [courseId],
    );
    int inscrits = Sqflite.firstIntValue(countResult) ?? 0;

    // Vérifie le max
    final course = await getCourseById(courseId);
    if (course == null || inscrits >= course.maxEtudiants) {
      return false;
    }

    // Enregistrer l'inscription
    await db.insert('inscriptions', {
      'courseId': courseId,
      'studentId': studentId,
    });
    return true;
  }

  Future<List<Student>> getStudentsByCourse(int courseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT s.* FROM students s
      INNER JOIN inscriptions i ON s.id = i.studentId
      WHERE i.courseId = ?
    ''',
      [courseId],
    );

    return maps.map((map) => Student.fromMap(map)).toList();
  }

  // Gestion des étudiants
  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert(
      'students',
      student.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(String id) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('students');

    return List.generate(maps.length, (i) {
      return Student.fromMap(maps[i]);
    });
  }
}
