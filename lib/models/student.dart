class Student {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String dateNaissance;
  final String classe;
  final String telephone;
  final String photo;
  final String sexe; // 🔥 Ajout de la photo de profil

  Student({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.dateNaissance,
    required this.classe,
    required this.telephone,
    required this.photo,
    required this.sexe, // ✅ Ajout ici
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'].toString(),
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      email: map['email'] ?? '',
      dateNaissance: map['dateNaissance'] ?? '',
      classe: map['classe'] ?? '',
      telephone: map['telephone'] ?? '',
      photo: map['photo'] ?? '', // ✅ Ajout ici
      sexe: map['sexe'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'dateNaissance': dateNaissance,
      'classe': classe,
      'telephone': telephone,
      'photo': photo, // ✅ Ajout ici
      'sexe': sexe, // <-- AJOUTE ICI
    };
  }
}
