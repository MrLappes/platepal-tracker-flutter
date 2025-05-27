# PlatePal Tracker

A comprehensive Flutter nutrition tracking application that helps users log meals, track nutrition intake, and achieve their fitness goals through AI-powered insights and personalized recommendations.

## 🌟 Features

### Core Functionality
- **Meal Logging**: Easy-to-use interface for logging breakfast, lunch, dinner, and snacks
- **Nutrition Tracking**: Track calories, proteins, carbs, fats, and micronutrients
- **Barcode Scanning**: Quickly add food items by scanning product barcodes
- **AI Chat Assistant**: Get meal suggestions and nutrition advice through ChatGPT integration
- **Calendar View**: Visual representation of your meal history and nutrition trends
- **Goal Setting**: Set and track personalized fitness and nutrition goals

### User Experience
- **Multi-language Support**: Available in English, Spanish, and German
- **Dark/Light Theme**: Automatic theme switching based on system preferences
- **Offline Support**: Continue tracking even without internet connection
- **Data Export/Import**: Backup and restore your nutrition data
- **Profile Management**: Customize your dietary preferences and restrictions

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.7.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- Android Studio / VS Code with Flutter extensions
- A physical device or emulator for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/platepal-tracker-flutter.git
   cd platepal-tracker-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate localization files**
   ```bash
   flutter gen-l10n
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── components/          # Reusable UI components
│   ├── animations/      # Custom animations and transitions
│   ├── calendar/        # Calendar-specific components
│   ├── chat/           # Chat interface components
│   ├── dishes/         # Meal and dish related components
│   ├── onboarding/     # User onboarding components
│   ├── scanner/        # Barcode scanning components
│   └── ui/             # Generic UI components
├── constants/          # App-wide constants and configuration
├── models/             # Data models and classes
├── providers/          # State management (Provider pattern)
├── repositories/       # Data access layer
├── screens/            # Application screens
│   ├── onboarding/     # Initial user setup screens
│   └── tabs/           # Main tab navigation screens
├── services/           # Business logic and external services
│   ├── api/            # API integration (GPT, nutrition databases)
│   ├── auth/           # Authentication services
│   ├── chat/           # AI chat functionality
│   └── storage/        # Local data storage
├── themes/             # App theming and styling
├── types/              # Type definitions and interfaces
└── utils/              # Helper functions and utilities
```

## 🔧 Development

### Code Organization
- **Models**: Define data structures using Dart classes with JSON serialization
- **Providers**: Manage application state using the Provider pattern
- **Services**: Handle business logic, API calls, and data processing
- **Components**: Build reusable UI components following Material Design principles
- **Screens**: Implement full-screen views with proper navigation handling

### State Management
This project uses the **Provider** pattern for state management:
- `MealProvider`: Manages meal logging and dish data
- `LocaleProvider`: Handles language and localization settings
- Additional providers for user profile, settings, and chat functionality

### Localization
The app supports multiple languages using Flutter's built-in internationalization:
- ARB files located in `lib/l10n/`
- Generated localization code in `.dart_tool/flutter_gen/gen_l10n/`
- Language switching available in settings

### Navigation
Uses **GoRouter** for declarative routing:
- Type-safe navigation
- Deep linking support
- Nested routing for complex navigation structures

## 🔐 Configuration

### API Keys
For full functionality, you'll need to configure API keys:

1. **OpenAI API Key** (for AI chat features)
   - Get your API key from [OpenAI Platform](https://platform.openai.com/api-keys)
   - Add to your app's settings or environment configuration

2. **Open Food Facts API** (for barcode scanning)
   - Free API for food product information
   - No API key required for basic usage

### Environment Setup
Create a `.env` file in the project root (not included in version control):
```
OPENAI_API_KEY=your_openai_api_key_here
```

## 🧪 Testing

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/models/dish_test.dart
```

### Test Structure
- **Unit Tests**: Test business logic and data models
- **Widget Tests**: Test UI components in isolation
- **Integration Tests**: Test complete user workflows

## 📱 Platform Support

| Platform | Status | Notes |
|----------|---------|--------|
| Android | ✅ Full Support | Minimum SDK: API 21 (Android 5.0) |
| iOS | ✅ Full Support | Minimum Version: iOS 12.0 |
| Web | ⚠️ Limited | Basic functionality, some features may be limited |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow the existing code style and architecture
- Add tests for new functionality
- Update documentation as needed
- Ensure all tests pass before submitting PR
- Use meaningful commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- OpenAI for AI-powered features
- Open Food Facts for nutrition database
- Material Design for UI/UX guidelines
- Community contributors and testers

## 📞 Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check the documentation
- Join our community discussions

---

**Happy tracking! 🥗📊**
