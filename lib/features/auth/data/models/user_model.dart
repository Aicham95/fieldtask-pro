class UserModel {
  final String id;
  final String name;
  final String email;
  final String team;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.team,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'].toString(),
        name: (j['name'] as String?) ?? '',
        email: (j['email'] as String?) ?? '',
        team: (j['team'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'email': email, 'team': team};
}
