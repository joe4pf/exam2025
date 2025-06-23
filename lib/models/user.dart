// models/user.dart

class User {
  final String uid;
  final String nom;
  final String prenom;
  final String email;

  User({
    required this.uid,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  // Convertir l'objet User en Map pour stockage (ex: Firestore)
  Map<String, dynamic> toMap() {
    return {'uid': uid, 'nom': nom, 'prenom': prenom, 'email': email};
  }

  // Créer une instance User depuis un Map (ex: Firestore document snapshot)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
