class Book {
  final int id;
  final String titre;
  final String auteur;
  final String description;
  final double prixParJour;
  final int statisticNbrEmpruntTotal;
  final String catalogueNom;

  Book({
    required this.id,
    required this.titre,
    required this.auteur,
    required this.description,
    required this.prixParJour,
    required this.statisticNbrEmpruntTotal,
    required this.catalogueNom,
  });


  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      titre: json['titre'],
      auteur: json['auteur'],
      description: json['description'],
      prixParJour: json['prixParJour'],
      statisticNbrEmpruntTotal: json['statisticNbrEmpruntTotal'],
      catalogueNom: json['catalogue']['nom'],
    );
  }
}
