import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/chat/chat_bloc.dart';
import 'blocs/profile/profile_bloc.dart';
import 'blocs/theme/theme_bloc.dart';
import 'services/api_service.dart';
import 'services/database_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseService.instance.database;
  
  runApp(const NewsAIApp());
}

class NewsAIApp extends StatelessWidget {
  const NewsAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(

      providers: [
        BlocProvider(
          create: (context) => ThemeBloc()..add(ThemeLoaded()),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            apiService: ApiService(),
            databaseService: DatabaseService.instance,
          )..add(AuthCheckStatus()),
        ),
        BlocProvider(
          create: (context) => ChatBloc(
            apiService: ApiService(),
            databaseService: DatabaseService.instance,
          ),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(
            apiService: ApiService(),
            databaseService: DatabaseService.instance,
          ),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'News AI',
            debugShowCheckedModeBanner: false,
            theme: themeState.themeData,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  return const HomeScreen();
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}