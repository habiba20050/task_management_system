import '../model/team_model.dart';

abstract class TeamsState {}

class TeamsInitial extends TeamsState {}
class TeamsLoading extends TeamsState {}
class TeamsLoaded extends TeamsState {
  final List<TeamModel> teams;
  TeamsLoaded(this.teams);
}
class TeamsError extends TeamsState {
  final String message;
  TeamsError(this.message);
}