// lib/services/auth_service.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn signIn = GoogleSignIn.instance;

  /// 🔹 Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      await signIn.initialize();
      await signIn.authenticate();

      final completer = Completer<GoogleSignInAccount?>();
      late StreamSubscription sub;
      sub = signIn.authenticationEvents.listen((event) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          completer.complete(event.user);
        } else if (event is GoogleSignInAuthenticationEventSignOut) {
          completer.complete(null);
        }
      });

      final GoogleSignInAccount? account = await completer.future;
      await sub.cancel();

      if (account == null) return null;

      final GoogleSignInClientAuthorization? authorization =
          await account.authorizationClient.authorizationForScopes(
        <String>['email', 'profile', 'openid'],
      );

      if (authorization == null || authorization.accessToken == null) {
        print("⚠️ Failed to get Google authorization");
        return null;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  /// 🔹 Sign in with Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Email Sign-In Error: $e");
      rethrow;
    }
  }

  /// 🔹 Register with Email & Password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Email Registration Error: $e");
      rethrow;
    }
  }

  /// 🔹 Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await signIn.disconnect();
    } catch (_) {}
  }

  /// 🔹 Auth state listener
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
