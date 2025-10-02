import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/chat/chat_bloc.dart';
import '../models/models.dart';
import '../widgets/chat_widgets.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatSession session;

  const ChatDetailScreen({super.key, required this.session});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatHistoryLoaded(widget.session.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChatLoaded) {
            if (state.messages.isEmpty) {
              return const Center(
                child: Text('No messages in this chat'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(
                  message: state.messages[index],
                  animate: false,
                );
              },
            );
          }

          return const Center(
            child: Text('Unable to load chat history'),
          );
        },
      ),
    );
  }
}