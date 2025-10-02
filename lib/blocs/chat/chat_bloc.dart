import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/database_service.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatMessageSent extends ChatEvent {
  final String message;
  final String token;
  const ChatMessageSent(this.message, this.token);
  @override
  List<Object?> get props => [message, token];
}

class ChatHistoryLoaded extends ChatEvent {
  final String sessionId;
  const ChatHistoryLoaded(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}

class ChatSessionCreated extends ChatEvent {}

// States
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {
  final List<Message> messages;
  const ChatLoading(this.messages);
  @override
  List<Object?> get props => [messages];
}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final String sessionId;
  const ChatLoaded(this.messages, this.sessionId);
  @override
  List<Object?> get props => [messages, sessionId];
}

class ChatTyping extends ChatState {
  final List<Message> messages;
  const ChatTyping(this.messages);
  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String message;
  final List<Message> messages;
  const ChatError(this.message, this.messages);
  @override
  List<Object?> get props => [message, messages];
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ApiService _apiService;
  final DatabaseService _databaseService;
  String _currentSessionId = '';

  ChatBloc({
    required ApiService apiService,
    required DatabaseService databaseService,
  })  : _apiService = apiService,
        _databaseService = databaseService,
        super(ChatInitial()) {
    on<ChatSessionCreated>(_onSessionCreated);
    on<ChatMessageSent>(_onMessageSent);
    on<ChatHistoryLoaded>(_onHistoryLoaded);
  }

  Future<void> _onSessionCreated(
    ChatSessionCreated event,
    Emitter<ChatState> emit,
  ) async {
    _currentSessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final session = ChatSession(
      id: _currentSessionId,
      title: 'New Chat',
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
    );
    await _databaseService.insertChatSession(session);
    emit(ChatLoaded(const [], _currentSessionId));
  }

  Future<void> _onMessageSent(
    ChatMessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final currentMessages = _getCurrentMessages();
    
    // Add user message
    final userMessage = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      content: event.message,
      isUser: true,
      timestamp: DateTime.now(),
      sessionId: _currentSessionId,
    );
    
    final updatedMessages = [...currentMessages, userMessage];
    await _databaseService.insertMessage(userMessage);
    
    // Show typing indicator
    emit(ChatTyping(updatedMessages));
    
    try {
      // Get AI response
      final response = await _apiService.sendChatMessage(event.message, event.token);
      
      // Add AI message
      final aiMessage = Message(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        sessionId: _currentSessionId,
      );
      
      final finalMessages = [...updatedMessages, aiMessage];
      await _databaseService.insertMessage(aiMessage);
      
      // Update session last message time
      final session = await _databaseService.getChatSession(_currentSessionId);
      if (session != null) {
        final updatedSession = session.copyWith(
          lastMessageAt: DateTime.now(),
          title: userMessage.content.length > 50 
              ? '${userMessage.content.substring(0, 50)}...'
              : userMessage.content,
        );
        await _databaseService.insertChatSession(updatedSession);
      }
      
      emit(ChatLoaded(finalMessages, _currentSessionId));
    } catch (e) {
      emit(ChatError(e.toString(), updatedMessages));
      emit(ChatLoaded(updatedMessages, _currentSessionId));
    }
  }

  Future<void> _onHistoryLoaded(
    ChatHistoryLoaded event,
    Emitter<ChatState> emit,
  ) async {
    try {
      _currentSessionId = event.sessionId;
      final messages = await _databaseService.getMessagesForSession(event.sessionId);
      emit(ChatLoaded(messages, event.sessionId));
    } catch (e) {
      emit(ChatError(e.toString(), const []));
    }
  }

  List<Message> _getCurrentMessages() {
    if (state is ChatLoaded) {
      return (state as ChatLoaded).messages;
    } else if (state is ChatTyping) {
      return (state as ChatTyping).messages;
    } else if (state is ChatError) {
      return (state as ChatError).messages;
    }
    return [];
  }
}