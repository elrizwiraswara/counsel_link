import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/common/result.dart';
import '../../data/models/user/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../widgets/app_dialog.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthViewModel({
    required this.authRepository,
    required this.userRepository,
  }) {
    initialize();
  }

  String? _phoneNumber;
  String? _verificationId;

  Timer? _timer;
  int resendOtpTime = 60;

  UserModel? user;

  final isAuthenticated = ValueNotifier<bool>(false);
  final isChecking = ValueNotifier<bool>(true);

  Future<void> initialize() async {
    try {
      isChecking.value = true;

      final currentUser = authRepository.currentUser;

      if (currentUser == null) {
        user = null;
        return;
      }

      final res = await userRepository.getUserByPhone(currentUser.phoneNumber!);

      user = res.data;
    } finally {
      isChecking.value = false;
      isAuthenticated.value = user != null;
    }
  }

  Future<void> refreshUser() async {
    if (user == null) return;
    final res = await userRepository.getUserByPhone(user!.phone!);
    user = res.data;
    notifyListeners();
  }

  bool enableButton(String text, int minLength) {
    if (text.isNotEmpty && text.length >= minLength) {
      return true;
    } else {
      return false;
    }
  }

  Future<Result<void>> onTapSignInButton(String phone) async {
    if (!phone.startsWith('+')) {
      return Result.failure(
        title: 'Phone Number Not Valid',
        message: 'Please enter a valid phone number with country code. e.g. +62xxx',
        error: 'phone number format is not valid',
      );
    }

    _phoneNumber = phone;

    // Check is user has been added into firestore
    final res = await userRepository.getUserByPhone(phone);

    if (res.data == null) {
      return Result.failure(
        title: 'Phone Number Not Registered',
        message: 'The phone number you entered is not registered. Please sign up first.',
        error: "user not found",
      );
    }

    return await verifyPhoneNumber(phone);
  }

  Future<Result<void>> onTapSignUpButton(String phone) async {
    if (!phone.startsWith('+')) {
      return Result.failure(
        title: 'Phone Number Not Valid',
        message: 'Please enter a valid phone number with country code. e.g. +62xxx',
        error: 'phone number format is not valid',
      );
    }

    // Check is user has been added into firestore
    final res = await userRepository.getUserByPhone(phone);

    if (res.data != null) {
      return Result.failure(
        title: 'Phone Number Already Registered',
        message: 'The phone number you entered is already registered. Please sign in to continue.',
        error: "user already registered",
      );
    }

    return await verifyPhoneNumber(phone);
  }

  Future<Result<void>> verifyPhoneNumber(String phone) async {
    if (!phone.startsWith('+')) {
      return Result.failure(
        title: 'Phone Number Not Valid',
        message: 'Please enter a valid phone number with country code. e.g. +62xxx',
        error: 'phone number format is not valid',
      );
    }

    _phoneNumber = phone;

    startOtpTimer();

    final verRes = await authRepository.verifyPhoneNumber(phone);

    if (verRes.isSuccess) {
      _verificationId = verRes.data;
      return Result.success(data: null);
    } else {
      return Result.failure(
        title: 'Verification Failed',
        message: 'Failed to send verification code. Please try again.',
        error: verRes.error!,
      );
    }
  }

  void resendOtp() {
    if (_phoneNumber == null) throw Exception('Phone number is null');

    AppDialog.showProgress(() async {
      await authRepository.verifyPhoneNumber(_phoneNumber!);
      startOtpTimer();
    });
  }

  Future<Result<UserModel?>> submitOtp(String otp) async {
    if (_verificationId == null) throw Exception('Please perform sign in first');

    final submitRes = await authRepository.submitOtp(otp, _verificationId!);
    if (submitRes.isFailure) return Result.failure(error: submitRes.error!);

    final signInRes = await authRepository.signIn(submitRes.data!);
    if (signInRes.isFailure) return Result.failure(error: signInRes.error!);

    final userRes = await userRepository.getUserByPhone(signInRes.data!.phoneNumber!);
    if (userRes.isFailure) return Result.failure(error: userRes.error!);

    if (userRes.data == null) {
      final user = UserModel(
        id: signInRes.data!.uid,
        role: UserRole.client,
        phone: signInRes.data!.phoneNumber,
      );

      final createRes = await userRepository.createOrUpdateUser(user);
      if (createRes.isFailure) return Result.failure(error: createRes.error!);
    }

    await initialize();

    return Result.success(data: user);
  }

  void startOtpTimer() {
    resetOtpTimer();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (resendOtpTime == 0) {
        timer.cancel();
      } else {
        resendOtpTime--;
        notifyListeners();
      }
    });
  }

  void resetOtpTimer() {
    _timer?.cancel();
    _timer = null;
    resendOtpTime = 60;
  }

  Future<Result<void>> signOut() async {
    final res = await authRepository.signOut();
    if (res.isFailure) return Result.failure(error: res.error!);

    await initialize();

    return Result.success(data: null);
  }
}
