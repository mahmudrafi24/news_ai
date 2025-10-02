import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoaded extends ProfileEvent {}

class ProfileUpdated extends ProfileEvent {
  final User user;
  final String token;
  const ProfileUpdated(this.user, this.token);
  @override
  List<Object?> get props => [user, token];
}

class ProfileHistoryLoaded extends ProfileEvent {}

class ProfileHistoryCleared extends ProfileEvent {}

class ProfileSessionDeleted extends ProfileEvent {
  final String sessionId;
  const ProfileSessionDeleted(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoadSuccess extends ProfileState {
  final User user;
  final List<ChatSession> sessions;
  const ProfileLoadSuccess(this.user, this.sessions);
  @override
  List<Object?> get props => [user, sessions];
}

class ProfileUpdateSuccess extends ProfileState {
  final User user;
  const ProfileUpdateSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileHistoryLoadSuccess extends ProfileState {
  final List<ChatSession> sessions;
  const ProfileHistoryLoadSuccess(this.sessions);
  @override
  List<Object?> get props => [sessions];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiService _apiService;
  final DatabaseService _databaseService;

  ProfileBloc({
    required ApiService apiService,
    required DatabaseService databaseService,
  })  : _apiService = apiService,
        _databaseService = databaseService,
        super(ProfileInitial()) {
    on<ProfileLoaded>(_onProfileLoaded);
    on<ProfileUpdated>(_onProfileUpdated);
    on<ProfileHistoryLoaded>(_onHistoryLoaded);
    on<ProfileHistoryCleared>(_onHistoryCleared);
    on<ProfileSessionDeleted>(_onSessionDeleted);
  }

  Future<void> _onProfileLoaded(
    ProfileLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await _databaseService.getUser();
      final sessions = await _databaseService.getAllChatSessions();
      
      if (user != null) {
        emit(ProfileLoadSuccess(user, sessions));
      } else {
        emit(const ProfileError('User not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onProfileUpdated(
    ProfileUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final updatedUser = await _apiService.updateProfile(event.user, event.token);
      await _databaseService.updateUser(updatedUser);
      emit(ProfileUpdateSuccess(updatedUser));
      
      // Reload full profile
      final sessions = await _databaseService.getAllChatSessions();
      emit(ProfileLoadSuccess(updatedUser, sessions));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onHistoryLoaded(
    ProfileHistoryLoaded event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final sessions = await _databaseService.getAllChatSessions();
      emit(ProfileHistoryLoadSuccess(sessions));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onHistoryCleared(
    ProfileHistoryCleared event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _databaseService.deleteAllChatSessions();
      emit(const ProfileHistoryLoadSuccess([]));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onSessionDeleted(
    ProfileSessionDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await _databaseService.deleteChatSession(event.sessionId);
      final sessions = await _databaseService.getAllChatSessions();
      emit(ProfileHistoryLoadSuccess(sessions));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}