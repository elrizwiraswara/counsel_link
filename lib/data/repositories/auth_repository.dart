import 'package:firebase_auth/firebase_auth.dart';

import '../../core/common/result.dart';

abstract class AuthRepository {
  Future<Result<String>> verifyPhoneNumber(String phone);
  Future<Result<AuthCredential>> submitOtp(String otpCode, String verificationId);
  Future<Result<User>> signIn(AuthCredential authCredential);
  Future<Result<void>> signOut();
  Stream<User?> authStateChanges();
  User? get currentUser;
}

class AuthRepositoryImpl extends AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<Result<String>> verifyPhoneNumber(String phone) async {
    try {
      String? verificationId;
      Exception? error;

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential authCredential) async {
          // Auto-verification completed, you can handle auto sign-in here if needed
        },
        verificationFailed: (FirebaseAuthException authException) {
          error = authException;
        },
        codeSent: (String verId, int? forceResendingToken) {
          verificationId = verId;
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId ??= verId;
        },
      );

      // Wait a bit for the callbacks to complete
      await Future.delayed(const Duration(seconds: 1));

      if (error != null) {
        return Result.failure(error: error!);
      }

      if (verificationId != null) {
        return Result.success(data: verificationId!);
      }

      return Result.failure(error: Exception('Verification failed: No verification ID received'));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<AuthCredential>> submitOtp(String otpCode, String verificationId) async {
    try {
      final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otpCode);
      return Result.success(data: credential);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<User>> signIn(AuthCredential authCredential) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(authCredential);

      if (userCredential.user == null) {
        return Result.failure(error: Exception('Sign in failed: No user returned'));
      }

      return Result.success(data: userCredential.user!);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  @override
  User? get currentUser => _firebaseAuth.currentUser;
}
