# Football AI Flutter starter

This is a working UI starter using explicitly labeled demo matches. No live scores, AI predictions, Firebase, or AdMob are connected yet.

## GitHub build
1. Create a new GitHub repository.
2. Upload `pubspec.yaml`, `lib/main.dart`, and `.github/workflows/android-build.yml` preserving their paths.
3. Go to Actions > Build Android APK > Run workflow (or push to main).
4. Download `football-ai-debug-apk` from the completed workflow's Artifacts section.

The workflow creates Android platform files if they are not committed. This is a debug APK for testing, not a Play Store release. Production requires a fixed Android application ID, release signing, Firebase configuration, AdMob configuration, and privacy/consent setup.

## Next milestone
- Add immutable fixture models, a sports repository, HTTP client, cache and error handling.
- Implement authenticated backend API for football data and grounded analysis.
- Configure Firebase and security rules, then ads and notifications.
