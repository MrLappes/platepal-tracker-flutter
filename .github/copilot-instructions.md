# Copilot Instructions for PlatePal Tracker

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

## Project Overview
This is a Flutter nutrition tracking application that helps users log meals, track nutrition, and achieve their fitness goals. It's a port from a React Native application with similar functionality.

## Architecture Guidelines
- **State Management**: Use Provider pattern for state management
- **Navigation**: Use GoRouter for navigation between screens
- **Localization**: Use Flutter's built-in internationalization with ARB files
- **Storage**: Use SharedPreferences for local data storage
- **API Integration**: Prepare for GPT API integration for meal analysis
- **Code Organization**: Follow the established folder structure with clear separation of concerns

## Code Style Preferences
- Use modern Dart syntax and null safety
- Follow Flutter naming conventions (camelCase for variables, PascalCase for classes)
- Prefer const constructors when possible
- Use meaningful variable and function names
- Add proper documentation for public APIs
- Handle errors gracefully with try-catch blocks

## Key Features to Maintain
- Meal logging and tracking
- Nutrition analysis and visualization
- User profile and preferences management
- Multi-language support (English, Spanish, German)
- Barcode scanning for food products
- AI-powered meal suggestions via chat interface
- Calendar view for meal history
- Export/import functionality for user data

## Directory Structure
- `lib/screens/`: All UI screens organized by feature
- `lib/components/`: Reusable UI components
- `lib/models/`: Data models and classes
- `lib/providers/`: State management providers
- `lib/services/`: Business logic and API services
- `lib/repositories/`: Data access layer
- `lib/utils/`: Helper functions and utilities
- `lib/constants/`: App-wide constants and configuration

## Testing Guidelines
- Write unit tests for business logic
- Write widget tests for UI components
- Use mock data for testing
- Test localization functionality
- Test state management providers

## Dependencies
- Provider for state management
- GoRouter for navigation
- SharedPreferences for local storage
- HTTP for API calls
- flutter_gen for localization
- CachedNetworkImage for image handling
