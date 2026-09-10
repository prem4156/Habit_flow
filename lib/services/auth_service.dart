import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../firebase_options.dart';
import '../models/auth_user_model.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  static const String _webClientId =
      '942937562811-2tsq8qhgp10m8u187b3ria37mlef1b38.apps.googleusercontent.com';

  GoogleSignIn? _googleSignIn;
  GoogleSignIn get _activeGoogleSignIn {
    return _googleSignIn ??= GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: kIsWeb ? _webClientId : null,
      serverClientId: _webClientId,
    );
  }

  bool _initialized = false;
  bool _firebaseAvailable = false;

  bool get isFirebaseAvailable => _firebaseAvailable;

  /// Stream of AuthUser changes (real-time stream)
  final StreamController<AuthUser?> _userStreamController =
      StreamController<AuthUser?>.broadcast();

  Stream<AuthUser?> get authStateChanges => _userStreamController.stream;

  User? get currentFirebaseUser {
    if (!_firebaseAvailable) return null;
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  AuthUser? get currentUser {
    final fbUser = currentFirebaseUser;
    if (fbUser != null) {
      return AuthUser.fromFirebaseUser(fbUser);
    }
    return null;
  }

  /// Initialize Firebase safely with platform options
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _firebaseAvailable = true;
      debugPrint('⚡ [AUTH] Firebase successfully initialized.');

      // Listen to Firebase auth state changes and pipe to stream
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          _userStreamController.add(AuthUser.fromFirebaseUser(user));
        } else {
          _userStreamController.add(null);
        }
      });
    } catch (e) {
      _firebaseAvailable = false;
      debugPrint('ℹ️ [AUTH] Firebase init note (running local/fallback auth until configured): $e');
    }
    _initialized = true;
  }

  /// Sign in with real Google Account
  Future<AuthUser?> signInWithGoogle({
    String? email,
    String? displayName,
    String? photoUrl,
    bool tryDeviceAuth = true,
  }) async {
    try {
      GoogleSignInAccount? googleAccount;

      // 1. On Web: If Firebase Auth is ready, try Firebase Web popup flow directly
      if (kIsWeb && _firebaseAvailable && tryDeviceAuth && email == null) {
        try {
          debugPrint('🌐 [AUTH] Triggering Web Firebase signInWithPopup...');
          final GoogleAuthProvider provider = GoogleAuthProvider();
          provider.addScope('email');
          provider.addScope('profile');
          final UserCredential userCredential = await _auth.signInWithPopup(provider);
          final User? user = userCredential.user;
          if (user != null) {
            final authUser = AuthUser.fromFirebaseUser(user);
            _userStreamController.add(authUser);
            return authUser;
          }
        } catch (e) {
          debugPrint('ℹ️ [AUTH] Web Firebase popup note: $e');
        }
      }

      if (tryDeviceAuth && email == null) {
        debugPrint('🌐 [AUTH] Triggering Google Sign-In client...');
        try {
          googleAccount = await _activeGoogleSignIn.signIn();
        } catch (e) {
          debugPrint('ℹ️ [AUTH] Native GoogleSignIn call note: $e');
        }

        if (googleAccount != null) {
          if (_firebaseAvailable) {
            try {
              final GoogleSignInAuthentication googleAuth =
                  await googleAccount.authentication;
              final OAuthCredential credential = GoogleAuthProvider.credential(
                accessToken: googleAuth.accessToken,
                idToken: googleAuth.idToken,
              );

              final UserCredential userCredential =
                  await _auth.signInWithCredential(credential);

              final User? user = userCredential.user;
              if (user != null) {
                final authUser = AuthUser.fromFirebaseUser(user);
                _userStreamController.add(authUser);
                return authUser;
              }
            } catch (e) {
              debugPrint('⚠️ [AUTH] Firebase credential exchange note: $e');
            }
          }

          // Real Google account obtained from native picker
          final accEmail = googleAccount.email.trim().toLowerCase();
          final accName = googleAccount.displayName?.trim().isNotEmpty == true
              ? googleAccount.displayName!.trim()
              : (accEmail.contains('@') ? accEmail.split('@').first : 'Hunter');

          final realUser = AuthUser(
            id: googleAccount.id.isNotEmpty
                ? 'goog_${googleAccount.id}'
                : 'goog_${DateTime.now().millisecondsSinceEpoch}',
            email: accEmail,
            displayName: accName,
            photoUrl: googleAccount.photoUrl,
            provider: AuthProviderType.google,
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );

          _userStreamController.add(realUser);
          return realUser;
        }
      }

      // If direct email/displayName were provided (e.g. testing or explicit parameters)
      if (email != null && email.isNotEmpty) {
        final directUser = AuthUser(
          id: 'goog_${DateTime.now().millisecondsSinceEpoch}',
          email: email.trim().toLowerCase(),
          displayName: displayName?.trim().isNotEmpty == true ? displayName!.trim() : 'Hunter',
          photoUrl: photoUrl,
          provider: AuthProviderType.google,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        _userStreamController.add(directUser);
        return directUser;
      }

      return null;
    } catch (e) {
      debugPrint('❌ [AUTH] Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Sign in with Email and Passcode
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    if (_firebaseAvailable) {
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: cleanEmail,
          password: cleanPass,
        );
        if (credential.user != null) {
          final authUser = AuthUser.fromFirebaseUser(credential.user!);
          _userStreamController.add(authUser);
          return authUser;
        }
      } on FirebaseAuthException catch (e) {
        debugPrint('❌ [AUTH] Firebase Email Sign-In failed: ${e.code}');
        rethrow;
      } catch (e) {
        debugPrint('⚠️ [AUTH] Firebase Email Sign-In error: $e');
      }
    }

    return null;
  }

  /// Register new Hunter with Email, Passcode, and Display Name
  Future<AuthUser?> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();
    final cleanName = displayName.trim().isEmpty ? 'Hunter' : displayName.trim();

    if (_firebaseAvailable) {
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: cleanPass,
        );
        if (credential.user != null) {
          await credential.user!.updateDisplayName(cleanName);
          await credential.user!.reload();
          final updatedUser = _auth.currentUser ?? credential.user!;
          final authUser = AuthUser.fromFirebaseUser(updatedUser);
          _userStreamController.add(authUser);
          return authUser;
        }
      } on FirebaseAuthException catch (e) {
        debugPrint('❌ [AUTH] Firebase Email Sign-Up failed: ${e.code}');
        rethrow;
      } catch (e) {
        debugPrint('⚠️ [AUTH] Firebase Email Sign-Up error: $e');
      }
    }

    return null;
  }

  /// Sign in as Guest / Anonymous Hunter
  Future<AuthUser?> signInAsGuest() async {
    if (_firebaseAvailable) {
      try {
        final credential = await _auth.signInAnonymously();
        if (credential.user != null) {
          final authUser = AuthUser.fromFirebaseUser(credential.user!);
          _userStreamController.add(authUser);
          return authUser;
        }
      } catch (e) {
        debugPrint('⚠️ [AUTH] Anonymous Firebase Sign-In fallback: $e');
      }
    }

    final randId = DateTime.now().millisecondsSinceEpoch % 9000 + 1000;
    final guestUser = AuthUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest_$randId@monarch.system',
      displayName: 'Shadow Recruit #$randId',
      provider: AuthProviderType.guest,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    _userStreamController.add(guestUser);
    return guestUser;
  }

  /// Sign out completely from Firebase and Google
  Future<void> signOut() async {
    try {
      if (_firebaseAvailable) {
        try {
          await _auth.signOut();
        } catch (_) {}
      }
      try {
        if (_googleSignIn != null) {
          await _googleSignIn!.signOut();
        }
      } catch (_) {}
      _userStreamController.add(null);
    } catch (e) {
      debugPrint('❌ [AUTH] Sign out error: $e');
    }
  }
}
