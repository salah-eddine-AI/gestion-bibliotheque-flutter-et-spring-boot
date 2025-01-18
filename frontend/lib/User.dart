class User {
  final int id;
  final String nom;
  final String email;
  final int nbrEmpruntRetarder;
  final int statisticNbrEmpruntTotal;
  final String role;

  User({
    required this.id,
    required this.nom,
    required this.email,
    required this.nbrEmpruntRetarder,
    required this.statisticNbrEmpruntTotal,
    required this.role,
  });


  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      nbrEmpruntRetarder: json['nbrEmpruntRetarder'],
      statisticNbrEmpruntTotal: json['statisticNbrEmpruntTotal'],
      role: json['role'],
    );
  }
}
