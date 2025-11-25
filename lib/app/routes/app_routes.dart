import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/models/user/user_model.dart';
import '../../presentation/view/auth/otp_verif_view.dart';
import '../../presentation/view/auth/sign_in_view.dart';
import '../../presentation/view/auth/sign_up_view.dart';
import '../../presentation/view/error/error_view.dart';
import '../../presentation/view/home/home_view_admin.dart';
import '../../presentation/view/home/home_view_client.dart';
import '../../presentation/view/home/home_view_counselor.dart';
import '../../presentation/view/profile/edit_profile_view.dart';
import '../../presentation/view/room/room_view.dart';
import '../../presentation/view/splash/splash_view.dart';
import '../../presentation/view/welcome/welcome_view.dart';
import '../../presentation/view_model/auth_view_model.dart';
import 'params/error_view_param.dart';
import 'params/room_view_param.dart';

class AppRoutes {
  AppRoutes._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  static final authViewModel = di<AuthViewModel>();

  static final router = GoRouter(
    initialLocation: '/',
    navigatorKey: rootNavigatorKey,
    refreshListenable: authViewModel.isAuthenticated,
    errorBuilder: (context, state) => ErrorView(param: ErrorViewParam(error: state.error)),
    routes: [_splash],
  );

  static final _splash = GoRoute(
    path: '/',
    builder: (context, state) => const SplashView(),
    redirect: (context, state) {
      final isChecking = authViewModel.isChecking.value;
      final isAuthenticated = authViewModel.isAuthenticated.value;
      final isSplashRoute = state.fullPath == '/';
      final isAuthRoute = state.fullPath?.startsWith('/auth') ?? false;

      if (isChecking) {
        return '/';
      }

      if (!isAuthenticated && !isAuthRoute) {
        return '/welcome';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/home';
      }

      return isSplashRoute ? '/home' : null;
    },
    routes: [
      _error,
      _welcome,
      _auth,
      _editProfile,
      _home,
      _room,
    ],
  );

  static final _error = GoRoute(
    path: '/error',
    builder: (context, state) {
      if (state.extra == null || state.extra! is! ErrorViewParam) {
        throw Exception('Required param is not provided!');
      }

      return ErrorView(param: state.extra as ErrorViewParam);
    },
  );

  static final _welcome = GoRoute(
    path: '/welcome',
    builder: (context, state) {
      return const WelcomeView();
    },
  );

  static final _auth = GoRoute(
    path: '/auth',
    builder: (context, state) {
      return const SplashView();
    },
    routes: [
      _signIn,
      _signUp,
      _otpVerify,
    ],
  );

  static final _signIn = GoRoute(
    path: 'sign-in',
    builder: (context, state) {
      return SignInView();
    },
  );

  static final _signUp = GoRoute(
    path: 'sign-up',
    builder: (context, state) {
      return SignUpView();
    },
  );

  static final _otpVerify = GoRoute(
    path: 'otp-verify',
    builder: (context, state) {
      return OtpVerifView();
    },
  );

  static final _editProfile = GoRoute(
    path: '/edit-profile',
    builder: (context, state) {
      if (state.extra == null || state.extra! is! bool) {
        throw Exception('Required param is not provided!');
      }

      return EditProfileView(isNewUser: state.extra as bool);
    },
  );

  static final _home = GoRoute(
    path: '/home',
    builder: (context, state) {
      if (authViewModel.user == null) throw Exception('Unauthenticated!');

      switch (authViewModel.user?.role) {
        case UserRole.counselor:
          return HomeViewCounselor();
        case UserRole.admin:
          return HomeViewAdmin();
        case UserRole.client:
          return HomeViewClient();
        case null:
          throw Exception('Unauthenticated!');
      }
    },
  );

  static final _room = GoRoute(
    path: '/room',
    builder: (context, state) {
      if (state.extra == null || state.extra! is! RoomViewParam) {
        throw Exception('Required param is not provided!');
      }

      return RoomView(param: state.extra as RoomViewParam);
    },
  );
}
