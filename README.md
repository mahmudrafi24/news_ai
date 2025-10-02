# News AI - Flutter Practice App

A complete Flutter mobile application demonstrating AI-driven news interactions with authentication, chat functionality, profile management, and theme switching. Built with BLoC state management, Sqflite for local storage, and smooth animations throughout.

## 🚀 Features

### Authentication Flow
- **Login Screen**: Email/password authentication with validation and animations
- **Signup Screen**: User registration with password strength indicator
- **Forgot Password**: Password reset email flow
- **Email Verification**: OTP-based email verification (6-digit code)
- All auth screens include smooth animations (fade, slide, shake on error)

### Main Chat Interface
- AI-powered chat with typing indicators
- Real-time message display with animated bubbles
- Auto-scroll to latest message
- Persistent chat history in Sqflite database
- Support for multiple chat sessions

### Profile Management
- View and edit user profile information
- Chat history viewer with session list
- Individual chat session details
- Clear history functionality
- Theme toggle (Light/Dark mode)
- Logout functionality

### Animations
- **Login/Signup**: Field focus animations, button press effects, error shake
- **Chat**: Message slide-in, typing indicator bouncing dots, smooth scrolling
- **Navigation**: Page transitions with fade/slide effects
- **Profile**: Edit mode expansion, list item fade-in (staggered)
- **Theme**: Cross-fade transition when switching themes

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point with BLoC providers
├── blocs/                    # State management
│   ├── auth/
│   │   └── auth_bloc.dart   # Authentication logic
│   ├── chat/
│   │   └── chat_bloc.dart   # Chat functionality
│   ├── profile/
│   │   └── profile_bloc.dart # Profile & history management
│   └── theme/
│       └── theme_bloc.dart   # Theme switching
├── models/
│   └── models.dart           # User, Message, ChatSession models
├── screens/                  # UI screens
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── forgot_password_screen.dart
│   ├── email_verification_screen.dart
│   ├── home_screen.dart      # Bottom navigation container
│   ├── chat_screen.dart      # Main chat interface
│   ├── profile_screen.dart   # User profile
│   ├── history_screen.dart   # Chat history list
│   └── chat_detail_screen.dart # Individual chat view
├── services/
│   ├── api_service.dart      # API calls (mock/real switch)
│   └── database_service.dart # Sqflite operations
├── widgets/                  # Reusable components
│   ├── chat_widgets.dart     # ChatBubble, TypingIndicator
│   ├── animated_form_field.dart # Form field with animations
│   └── animated_button.dart  # Button with press animation
└── utils/
    └── config.dart           # App configuration & constants
```

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android/iOS emulator or physical device

### Installation

1. **Clone or create the project:**
   ```bash
   flutter create news_ai
   cd news_ai
   ```

2. **Copy all the provided code files** into their respective locations as shown in the project structure above.

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Mock Mode (Default)
The app runs in **mock mode** by default for testing without external APIs.

**Mock Credentials:**
- Email: `test@example.com`
- Password: `password123`
- OTP Code: `123456`

**Mock AI Responses:**
The app provides keyword-based responses for:
- AI, technology, politics, sports, health, etc.

### Switching to Real API

To integrate a real backend API:

1. **Open `lib/utils/config.dart`**

2. **Update configuration:**
   ```dart
   class AppConfig {
     // Set to false to use real API
     static const bool IS_MOCK_MODE = false;
     
     // Update with your API base URL
     static const String BASE_URL = 'https://your-api.com';
     
     // Add your API keys
     static const String NEWS_API_KEY = 'your_newsapi_key';
     static const String OPENAI_API_KEY = 'your_openai_key';
   }
   ```

3. **API Endpoints:**
   The app expects these endpoints:
   - `POST /auth/login` - Login with email/password
   - `POST /auth/signup` - Register new user
   - `POST /auth/forgot-password` - Request password reset
   - `POST /auth/verify` - Verify email with OTP
   - `POST /chat` - Send message and get AI response
   - `PATCH /profile` - Update user profile

4. **Expected API Response Format:**

   **Login/Signup:**
   ```json
   {
     "success": true,
     "user": {
       "id": "user_123",
       "email": "user@example.com",
       "name": "John Doe",
       "joinDate": "2024-01-15T10:30:00Z",
       "token": "jwt_token_here"
     }
   }
   ```

   **Chat:**
   ```json
   {
     "response": "AI generated response text here..."
   }
   ```

### Integrating with Real AI Services

**Option 1: OpenAI GPT**
```dart
// In api_service.dart _realChat method
Future<String> _realChat(String message, String token) async {
  final response = await http.post(
    Uri.parse('https://api.openai.com/v1/chat/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AppConfig.OPENAI_API_KEY}',
    },
    body: jsonEncode({
      'model': 'gpt-4',
      'messages': [
        {'role': 'user', 'content': message}
      ],
    }),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }
  throw Exception('Chat request failed');
}
```

**Option 2: NewsAPI.org**
```dart
Future<String> _realChat(String message, String token) async {
  final query = Uri.encodeComponent(message);
  final response = await http.get(
    Uri.parse('https://newsapi.org/v2/everything?q=$query&apiKey=${AppConfig.NEWS_API_KEY}'),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final articles = data['articles'] as List;
    // Format articles into readable response
    return _formatNewsResponse(articles);
  }
  throw Exception('News fetch failed');
}
```

## 🎨 Customization

### Themes
Modify themes in `lib/blocs/theme/theme_bloc.dart`:
```dart
static final ThemeData _lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Change primary color
    brightness: Brightness.light,
  ),
  // ... other theme properties
);
```

### Animation Durations
Adjust in `lib/utils/config.dart`:
```dart
static const int SHORT_ANIMATION = 200;   // milliseconds
static const int MEDIUM_ANIMATION = 300;
static const int LONG_ANIMATION = 400;
```

### Mock Responses
Add more AI responses in `lib/services/api_service.dart`:
```dart
static const Map<String, String> _mockResponses = {
  'your_keyword': 'Your custom response...',
  // Add more keywords
};
```

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

### Test Mock vs Real Mode
1. Set `IS_MOCK_MODE = true` in config.dart
2. Run app and test with mock credentials
3. Set `IS_MOCK_MODE = false`
4. Configure real API endpoints
5. Test with actual backend

## 📱 Platform-Specific Notes

### Android
- Minimum SDK: 21 (Android 5.0)
- Permissions: Internet access (already in manifest)

### iOS
- Minimum iOS: 11.0
- Update `Info.plist` for network requests if needed

## 🔍 Key Features Implementation

### BLoC Pattern
- Separation of business logic and UI
- Reactive state management
- Easy testing and maintainability

### Sqflite Database
- Local storage for chat history
- User data persistence
- Offline functionality

### Animations
- 60 FPS smooth animations
- Material Design motion
- Custom animation controllers

### Error Handling
- Form validation with visual feedback
- Network error handling
- Graceful degradation

## 📝 Common Issues & Solutions

### Issue: Database not initializing
**Solution:** Ensure `WidgetsFlutterBinding.ensureInitialized()` is called in main()

### Issue: Animations stuttering
**Solution:** Use `TickerProviderStateMixin` and dispose controllers properly

### Issue: API calls failing
**Solution:** Check `IS_MOCK_MODE` setting and verify API endpoints

### Issue: Theme not persisting
**Solution:** Ensure SharedPreferences is properly initialized

## 🚀 Future Enhancements

- [ ] Push notifications for new messages
- [ ] Voice input for chat
- [ ] Image sharing in chat
- [ ] Multi-language support
- [ ] Biometric authentication
- [ ] Message search functionality
- [ ] Export chat history
- [ ] Dark mode auto-switch based on system

## 📄 License

This is a practice project. Feel free to use and modify as needed.

## 🤝 Contributing

This is an educational project. Suggestions and improvements are welcome!

## 📧 Support

For issues or questions about this implementation, refer to:
- Flutter documentation: https://flutter.dev/docs
- BLoC pattern: https://bloclibrary.dev
- Sqflite: https://pub.dev/packages/sqflite

---

**Built with ❤️ using Flutter**