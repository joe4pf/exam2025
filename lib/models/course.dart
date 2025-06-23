class Course {
  final int id;
  final String nom;
  final String photo; // Chemin de l'image ou URL
  final String description;
  final String enseignant;
  final String dateDebut; // Format ISO : "2025-06-11"
  final String dateFin;
  final int maxEtudiants;

  Course({
    required this.id,
    required this.nom,
    required this.photo,
    required this.description,
    required this.enseignant,
    required this.dateDebut,
    required this.dateFin,
    required this.maxEtudiants,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'photo': photo,
      'description': description,
      'enseignant': enseignant,
      'dateDebut': dateDebut,
      'dateFin': dateFin,
      'maxEtudiants': maxEtudiants,
    };
  }

  static Course fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      nom: map['nom'],
      photo: map['photo'],
      description: map['description'],
      enseignant: map['enseignant'],
      dateDebut: map['dateDebut'],
      dateFin: map['dateFin'],
      maxEtudiants: map['maxEtudiants'],
    );
  }
}
