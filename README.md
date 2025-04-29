# kamui_app

[![Codemagic build status](https://api.codemagic.io/apps/67fceb0d241de569069cf9c5/67fceb0d241de569069cf9c4/status_badge.svg)](https://codemagic.io/app/67fceb0d241de569069cf9c5/67fceb0d241de569069cf9c4/latest_build)

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Directory Structure
lib/
│── core/                  # Core modules (constants, helpers, etc.)
│   ├── config/            # App-wide configurations (e.g., theme, routes, env)
│   ├── errors/            # Custom error handling classes
│   ├── network/           # API services, Dio/http client, interceptors
│   ├── usecases/          # Business logic (domain layer)
│   ├── utils/             # Utility functions/helpers
│
│── data/                  # Data layer (repositories & models)
│   ├── datasources/       # API calls & local database handling
│   │   ├── remote/        # Remote APIs (Dio, GraphQL, Firebase, etc.)
│   │   ├── local/         # Local storage (Hive, SharedPreferences, SQLite)
│   ├── models/            # Data models (JSON serialization, Freezed, etc.)
│   ├── repositories/      # Repository implementations
│
│── domain/                # Domain layer (independent of Flutter)
│   ├── entities/          # Core business entities (e.g., User, Product)
│   ├── repositories/      # Abstract repository definitions
│   ├── usecases/          # Business logic use cases
│
│── presentation/          # UI layer (Widgets & BLoC)
│   ├── blocs/             # BLoC logic (one per feature)
│   │   ├── authentication/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   ├── auth_state.dart
│   │   ├── user_profile/
│   │   │   ├── profile_bloc.dart
│   │   │   ├── profile_event.dart
│   │   │   ├── profile_state.dart
│   ├── screens/           # Screens/pages grouped by features
│   │   ├── auth/          # Authentication screens (login, signup, etc.)
│   │   ├── home/          # Home screen UI
│   │   ├── settings/      # Settings page
│   ├── widgets/           # Reusable UI components (buttons, cards, etc.)
│
│── app.dart               # Root widget (MaterialApp)
│── main.dart              # Entry point
│── injection.dart         # Dependency Injection (GetIt)
│── routes.dart            # App-wide navigation routes
│── theme.dart             # Global themes


- privacy policy
- after limit time 30 minutes, showing ads
- iklan belum bisa di klik. [Done]
- 30-day money-back guarantee di hapus. [Done]
- click contiue di onboarding di hilangkan atau di ganti. [Done]
- di bawah description di tambah info untuk restore package. [Done]
- auto connect di awal feature nya di hilangkan.
- countdown belum jalan.
- Ijo untuk connected, untuk disconnected merah, untuk proses connecting dan disconnecting warna nya abu-abu.
- selected server di list server checklist nya hilang
- if premium user not get ads and button get premium being gone. [Done]
- premium user totally ads, tidak muncul [Done]


  # build-ios:
  #   needs: validate-version
  #   runs-on: macos-latest
  #   steps:
  #     - uses: actions/checkout@v4
      
  #     - name: Setup Flutter
  #       id: flutter-setup
  #       uses: subosito/flutter-action@v2
  #       with:
  #         channel: 'stable'
  #         flutter-version-file: pubspec.yaml
  #         cache: true
  #         cache-key: 'flutter-:os:-:channel:-:version:-:arch:-:hash:'
  #         pub-cache-key: 'flutter-pub:os:-:channel:-:version:-:arch:-:hash:'
      
  #     - name: Create .env file
  #       run: |
  #         echo "SECRET_KEY=${{ secrets.SECRET_KEY }}" > .env
  #         echo "BASE_URL=${{ secrets.BASE_URL }}" >> .env
  #         echo "API_KEY=${{ secrets.API_KEY }}" >> .env
  #         echo "NETWORK_LOGGER=false" >> .env
      
  #     - name: Install dependencies
  #       run: flutter pub get
      
  #     - name: Generate release notes
  #       id: release_notes
  #       run: |
  #         git fetch --prune --unshallow || true
  #         COMMITS=$(git log --pretty=format:"- %s" -n 5)
  #         echo "RELEASE_NOTES<<EOF" >> $GITHUB_ENV
  #         echo "Release ${{ github.ref_name }}" >> $GITHUB_ENV
  #         echo "" >> $GITHUB_ENV
  #         echo "Recent changes:" >> $GITHUB_ENV
  #         echo "$COMMITS" >> $GITHUB_ENV
  #         echo "EOF" >> $GITHUB_ENV
      
  #     - name: Setup iOS build environment
  #       run: |
  #         cd ios
  #         pod repo update
  #         pod install --repo-update
  #         cd ..
      
  #     - name: Build iOS IPA
  #       run: |
  #         flutter build ipa --no-codesign
  #         if [ $? -ne 0 ]; then
  #           echo "Build failed, showing stacktrace..."
  #           cd ios
  #           xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug -sdk iphoneos -verbose
  #           exit 1
  #         fi
      
  #     - name: Verify IPA Exists
  #       run: |
  #         # First try the standard location
  #         IPA_PATH=$(find build/ios/archive -name "*.ipa" | head -n 1)
          
  #         # If not found, try alternative locations
  #         if [ -z "$IPA_PATH" ]; then
  #           echo "IPA not found in standard location, searching alternatives..."
  #           IPA_PATH=$(find build/ios/ipa -name "*.ipa" | head -n 1)
  #         fi
          
  #         if [ -z "$IPA_PATH" ]; then
  #           echo "Error: IPA file not found in any standard locations"
  #           echo "Searching for IPA files in all locations..."
  #           find . -name "*.ipa" -type f
  #           exit 1
  #         fi
          
  #         echo "Found IPA at: $IPA_PATH"
  #         echo "IPA_PATH=$IPA_PATH" >> $GITHUB_ENV
      
  #     - name: Upload iOS IPA
  #       uses: actions/upload-artifact@v4
  #       with:
  #         name: debug-ipa
  #         path: ${{ env.IPA_PATH }}
      
  #     - name: Firebase App Distribution - iOS
  #       uses: wzieba/Firebase-Distribution-Github-Action@v1
  #       with:
  #         appId: ${{ secrets.FIREBASE_IOS_APP_ID }}
  #         groups: qa-testers
  #         file: ${{ env.IPA_PATH }}
  #         serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
  #         releaseNotes: ${{ env.RELEASE_NOTES }} 