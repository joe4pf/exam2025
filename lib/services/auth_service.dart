import 'package:firebase_auth/firebase_auth.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Récupère l'utilisateur actuellement connecté
  User? get currentUser => _auth.currentUser;

  /// Écoute les changements d'état de l'authentification (utile pour les streamBuilder)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Connexion avec email et mot de passe
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Inscription avec email et mot de passe
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
