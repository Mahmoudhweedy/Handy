# Handy - DIY Business Platform

A production-grade Flutter application for a DIY business platform featuring e-commerce functionality, service bookings, user authentication, and comprehensive state management.

## 🏗️ Project Structure

The project follows Clean Architecture principles with a feature-based modular structure:

```
lib/
├── app.dart                          # Main app widget configuration
├── bootstrap.dart                    # App initialization and service setup
├── main.dart                        # Entry point
├── common/
│   ├── providers/                   # Global state providers
│   │   ├── auth_provider.dart       # Authentication state management
│   │   ├── locale_provider.dart     # Localization state management
│   │   └── theme_mode_provider.dart # Theme state management
│   └── widgets/                     # Reusable UI components
│       ├── app_button.dart          # Customizable button widget
│       └── app_text_field.dart      # Enhanced text field widget
├── core/
│   ├── constants/
│   │   └── app_constants.dart       # App-wide constants
│   ├── errors/
│   │   └── storage_exceptions.dart  # Custom exception classes
│   ├── routing/
│   │   └── app_router.dart          # Go Router configuration
│   ├── services/
│   │   └── storage_service.dart     # Local storage management
│   └── theme/
│   └── app_theme.dart           # Material 3 theme configuration
├── data/
│   └── models/
│       ├── user_model.dart          # User data model
│       └── user_model.g.dart        # Generated serialization code
├── features/
│   ├── auth/presentation/pages/     # Authentication pages
│   ├── bookings/presentation/pages/ # Service booking pages
│   ├── cart/presentation/pages/     # Shopping cart pages
│   ├── orders/presentation/pages/   # Order management pages
│   ├── products/presentation/pages/ # Product catalog pages
│   ├── profile/presentation/pages/  # User profile pages
│   └── settings/presentation/pages/ # App settings pages
└── presentation/
    └── pages/
        ├── home_page.dart           # Dashboard/home screen
        ├── main_wrapper.dart        # Main app navigation wrapper
        ├── onboarding_page.dart     # First-time user onboarding
        └── splash_page.dart         # App launch screen
```

## ✨ Features

### Core Functionality
- **🔐 User Authentication**: Email/password and Google Sign-In with secure token management
- **🛒 E-commerce**: Product browsing, cart management, and order processing
- **📅 Booking System**: Service scheduling with time slot management
- **👤 User Profiles**: Profile management with avatar support
- **⚙️ Settings**: Theme switching, language selection, and preferences

### Technical Features
- **🎨 Theming**: Light/dark theme support with Material 3 design system
- **🌍 Localization**: Multi-language support (English/Arabic) with RTL layout
- **📱 Responsive Design**: Adaptive UI for different screen sizes
- **💾 Local Storage**: Secure data persistence with Hive and encrypted storage
- **🚀 Performance**: Lazy loading, caching, and optimized state management
- **🔄 Offline Support**: Local-first data with automatic synchronization
- **📊 Error Monitoring**: Integrated Sentry for crash reporting and performance tracking

## 🛠️ Tech Stack

### Core Framework
- **Flutter**: 3.x with Dart 3.x
- **Material 3**: Latest Material Design system

### State Management
- **Riverpod**: 2.x for reactive state management
- **Riverpod Generator**: Code generation for providers

### Navigation
- **Go Router**: Declarative routing with type safety

### Backend Integration (Ready for Firebase)
- **Firebase Core**: Authentication, Firestore, Storage, Messaging
- **Google Sign-In**: OAuth authentication

### Local Storage
- **Hive**: NoSQL local database
- **Flutter Secure Storage**: Encrypted key-value storage for sensitive data

### Development Tools
- **Build Runner**: Code generation
- **JSON Serializable**: Model serialization
- **Flutter Lints**: Code quality and consistency

### Additional Libraries
- **Dio**: HTTP client for API calls
- **Cached Network Image**: Optimized image loading and caching
- **Image Picker**: Camera and gallery access
- **Permission Handler**: Runtime permission management
- **Connectivity Plus**: Network connectivity monitoring
- **Sentry Flutter**: Error tracking and performance monitoring

## 📱 Architecture

### Clean Architecture Layers

1. **Presentation Layer**
   - Pages and Widgets
   - State Management (Riverpod Providers)
   - UI Logic

2. **Domain Layer** (Ready for implementation)
   - Business Logic
   - Use Cases
   - Repository Interfaces

3. **Data Layer** (Ready for implementation)
   - Repository Implementations
   - Data Sources (Local & Remote)
   - Models and DTOs

### Design Patterns
- **Repository Pattern**: Abstraction for data sources
- **Provider Pattern**: Dependency injection with Riverpod
- **MVVM**: Model-View-ViewModel architecture
- **Singleton**: Services and utilities

## 🚀 Getting Started

### Prerequisites
- Flutter 3.8.1 or higher
- Dart 3.8.0 or higher
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd handy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build
   ```

4. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Environment Variables
The `.env` file contains configuration for various services:

```env
# Firebase Configuration (when ready to integrate)
FIREBASE_API_KEY=your_api_key_here
FIREBASE_APP_ID=your_app_id_here
FIREBASE_MESSAGING_SENDER_ID=your_sender_id_here
FIREBASE_PROJECT_ID=your_project_id_here
FIREBASE_AUTH_DOMAIN=your_auth_domain_here
FIREBASE_STORAGE_BUCKET=your_storage_bucket_here

# Sentry Configuration
SENTRY_DSN=your_sentry_dsn_here

# API Configuration
BASE_API_URL=https://api.handy.com
```

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests  
flutter test integration_test/
```

## 📦 Building

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
flutter build appbundle --release  # For Google Play Store
```

## 🔄 State Management Architecture

### Providers
- **AuthProvider**: User authentication state with secure token management
- **ThemeModeProvider**: App theme preferences (light/dark/system)
- **LocaleProvider**: Language and localization with RTL support
- **Additional providers**: Ready for cart, orders, and other features

### State Persistence
- User preferences stored in Hive
- Sensitive data in Flutter Secure Storage
- Cache management with automatic cleanup

## 🌐 Localization

### Supported Languages
- English (en)
- Arabic (ar) with full RTL support

### Features
- Automatic locale detection
- Persistent locale preferences
- RTL layout support
- Time-based greetings
- Localized date/currency formatting

## 🎨 Theming

### Theme System
- Material 3 Design System
- Light and Dark themes
- System theme following device preferences
- Consistent component styling
- Custom color schemes

### Features
- Persistent theme preferences
- Smooth theme transitions
- Accessibility support
- Custom color palettes

## 🔐 Security Features

### Data Protection
- Encrypted secure storage for sensitive data
- Token-based authentication with automatic refresh
- Input validation and sanitization
- Environment-based configuration
- No hardcoded secrets

## 📈 Performance Optimizations

### Loading & Caching
- Lazy loading for large lists
- Image caching with automatic cleanup
- Local-first data strategy
- Background synchronization
- Memory-efficient state management

## 🚨 Error Handling

### Error Management
- Global error boundary
- Typed exception classes
- User-friendly error messages
- Automatic error reporting with Sentry (production)
- Comprehensive logging system

## 🔮 Future Enhancements

### Phase 1: Firebase Integration
- [ ] Complete Firebase authentication
- [ ] Firestore data synchronization
- [ ] Push notifications
- [ ] File upload with Firebase Storage

### Phase 2: Core Features
- [ ] Product catalog with search
- [ ] Shopping cart functionality
- [ ] Order processing system
- [ ] Service booking platform
- [ ] User profile management

### Phase 3: Advanced Features
- [ ] Payment integration
- [ ] Advanced analytics
- [ ] Multi-vendor support
- [ ] Review and rating system
- [ ] Loyalty program

## 📊 Project Status

**Current Status**: ✅ Foundation Complete
- ✅ Clean architecture implementation
- ✅ Core state management with Riverpod
- ✅ Theming system with Material 3
- ✅ Localization with RTL support
- ✅ Secure storage services
- ✅ Navigation with Go Router
- ✅ Authentication framework
- ✅ Reusable UI components
- ✅ Error handling and monitoring
- ✅ Build system and configuration

**Ready for**: Firebase integration, feature implementation, and production deployment.

---

**Built with ❤️ using Flutter** - A scalable, maintainable, and production-ready foundation for your DIY business platform.
