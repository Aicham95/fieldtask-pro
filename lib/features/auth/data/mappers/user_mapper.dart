import '../../domain/entities/user.dart';
import '../models/user_model.dart';

extension UserModelMapper on UserModel {
  User toEntity() => User(id: id, name: name, email: email, team: team);
}
