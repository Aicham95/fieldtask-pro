import 'package:equatable/equatable.dart';

/// Technicien connecté. [id] sert à télécharger ses interventions.
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String team;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.team,
  });

  @override
  List<Object?> get props => [id, name, email, team];
}
