import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import '../models/models.dart';

class ApiService {
  // Mock AI responses based on keywords
  static const Map<String, String> _mockResponses = {
    'ai': 'Recent AI developments include breakthroughs in large language models, with new techniques improving reasoning capabilities and reducing hallucinations. Companies are focusing on making AI more accessible and cost-effective.',
    'technology': 'The tech industry is seeing rapid advancements in quantum computing, edge computing, and sustainable technology. Major companies are investing heavily in green data centers and renewable energy.',
    'politics': 'Political landscapes are shifting globally with elections and policy changes. Focus areas include climate policy, economic reforms, and international relations.',
    'sports': 'Sports news highlights include major tournaments, record-breaking performances, and new technological innovations in training and analytics.',
    'health': 'Health sector innovations include new treatments, telemedicine expansion, and breakthroughs in personalized medicine and gene therapy.',
    'default': 'I found some interesting news articles for you. The latest updates cover various topics including technology advancements, global events, and trending stories. What specific area would you like to know more about?',
  };

  /// Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (AppConfig.IS_MOCK_MODE) {
      return _mockLogin(email, password);
    }
    return _realLogin(email, password);
  }

  Future<Map<String, dynamic>> _mockLogin(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.MOCK_DELAY));
    
    if (email == AppConfig.MOCK_EMAIL && password == AppConfig.MOCK_PASSWORD) {
      return {
        'success': true,
        'user': {
          'id': 'user_001',
          'email': email,
          'name': 'Test User',
          'joinDate': DateTime.now().toIso8601String(),
          'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        },
      };
    }
    throw Exception('Invalid credentials');
  }

  Future<Map<String, dynamic>> _realLogin(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.BASE_URL}${AppConfig.LOGIN_ENDPOINT}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Login failed: ${response.body}');
  }

  /// Signup user
  Future<Map<String, dynamic>> signup(String email, String password) async {
    if (AppConfig.IS_MOCK_MODE) {
      return _mockSignup(email, password);
    }
    return _realSignup(email, password);
  }

  Future<Map<String, dynamic>> _mockSignup(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.MOCK_DELAY));
    
    // Mock: Check if email already exists (simple check)
    if (email == AppConfig.MOCK_EMAIL) {
      throw Exception('Email already exists');
    }
    
    return {
      'success': true,
      'user': {
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'email': email,
        'name': email.split('@')[0],
        'joinDate': DateTime.now().toIso8601String(),
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      },
    };
  }

  Future<Map<String, dynamic>> _realSignup(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.BASE_URL}${AppConfig.SIGNUP_ENDPOINT}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Signup failed: ${response.body}');
  }

  /// Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    if (AppConfig.IS_MOCK_MODE) {
      return _mockForgotPassword(email);
    }
    return _realForgotPassword(email);
  }

  Future<Map<String, dynamic>> _mockForgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.MOCK_DELAY));
    
    if (email == AppConfig.MOCK_EMAIL) {
      return {
        'success': true,
        'message': 'Password reset link sent to $email',
      };
    }
    throw Exception('Email not found');
  }

  Future<Map<String, dynamic>> _realForgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('${AppConfig.BASE_URL}${AppConfig.FORGOT_PASSWORD_ENDPOINT}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Request failed: ${response.body}');
  }

  /// Verify email
  Future<Map<String, dynamic>> verifyEmail(String code) async {
    if (AppConfig.IS_MOCK_MODE) {
      return _mockVerifyEmail(code);
    }
    return _realVerifyEmail(code);
  }

  Future<Map<String, dynamic>> _mockVerifyEmail(String code) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.MOCK_DELAY));
    
    if (code == AppConfig.MOCK_OTP) {
      return {
        'success': true,
        'message': 'Email verified successfully',
      };
    }
    throw Exception('Invalid verification code');
  }

  Future<Map<String, dynamic>> _realVerifyEmail(String code) async {
    final response = await http.post(
      Uri.parse('${AppConfig.BASE_URL}${AppConfig.VERIFY_EMAIL_ENDPOINT}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Verification failed: ${response.body}');
  }

  /// Chat with AI
  Future<String> sendChatMessage(String message, String token) async {
    if (AppConfig.IS_MOCK_MODE) {
      return _mockChat(message);
    }
    return _realChat(message, token);
  }

  Future<String> _mockChat(String message) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.MOCK_DELAY));
    
    final lowerMessage = message.toLowerCase();
    
    for (final keyword in _mockResponses.keys) {
      if (lowerMessage.contains(keyword)) {
        return _mockResponses[keyword]!;
      }
    }
    
    return _mockResponses['default']!;
  }

  Future<String> _realChat(String message, String token) async {
    // Example: Using OpenAI-style API
    final response = await http.post(
      Uri.parse('${AppConfig.BASE_URL}${AppConfig.CHAT_ENDPOINT}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'query': message,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] as String;
    }
    throw Exception('Chat request failed: ${response.body}');
  }

  /// Update profile
  Future<User> updateProfile(User user, String token) async {
    if (AppConfig.IS_MOCK_MODE) {
      return _mockUpdateProfile(user);
    }
    return _realUpdateProfile(user, token);
  }

  Future<User> _mockUpdateProfile(User user) async {
    await Future.delayed(const Duration(milliseconds: AppConfig.MOCK_DELAY));
    return user;
  }

  Future<User> _realUpdateProfile(User user, String token) async {
    final response = await http.patch(
      Uri.parse('${AppConfig.BASE_URL}${AppConfig.PROFILE_ENDPOINT}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': user.name,
        'email': user.email,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    }
    throw Exception('Profile update failed: ${response.body}');
  }
}