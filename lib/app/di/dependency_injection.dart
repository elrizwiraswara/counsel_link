import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watch_it/watch_it.dart';

import '../../core/services/logger/error_logger_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/room_repository.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/service_type_repository.dart';
import '../../data/repositories/storage_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../presentation/view_model/auth_view_model.dart';
import '../../presentation/view_model/home_admin_view_model.dart';
import '../../presentation/view_model/home_client_view_model.dart';
import '../../presentation/view_model/home_counselor_view_model.dart';
import '../../presentation/view_model/profile_view_model.dart';
import '../../presentation/view_model/room_view_model.dart';
import '../routes/app_routes.dart';

/// Setup dependency injection
Future<void> setupDependencyInjection() async {
  // Third parties
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  sl.registerSingleton<FirebaseCrashlytics>(FirebaseCrashlytics.instance);
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<ImagePicker>(ImagePicker());

  // Services
  sl.registerSingleton<ErrorLoggerService>(ErrorLoggerService(sl<FirebaseCrashlytics>()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl<FirebaseAuth>()));
  sl.registerLazySingleton<RoomRepository>(() => RoomRepositoryImpl(sl<FirebaseFirestore>()));
  sl.registerLazySingleton<ScheduleRepository>(() => ScheduleRepositoryImpl(sl<FirebaseFirestore>()));
  sl.registerLazySingleton<ServiceTypeRepository>(() => ServiceTypeRepositoryImpl(sl<FirebaseFirestore>()));
  sl.registerLazySingleton<StorageRepository>(() => StorageRepositoryImpl(sl<FirebaseStorage>()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl<FirebaseFirestore>()));

  // View models
  sl.registerLazySingleton<AuthViewModel>(
    () => AuthViewModel(
      authRepository: sl<AuthRepository>(),
      userRepository: sl<UserRepository>(),
    ),
  );
  sl.registerLazySingleton<ProfileViewModel>(
    () => ProfileViewModel(
      authViewModel: sl<AuthViewModel>(),
      storageRepository: sl<StorageRepository>(),
      userRepository: sl<UserRepository>(),
    ),
  );
  sl.registerLazySingleton<HomeClientViewModel>(
    () => HomeClientViewModel(
      serviceTypeRepository: sl<ServiceTypeRepository>(),
      scheduleRepository: sl<ScheduleRepository>(),
      authViewModel: sl<AuthViewModel>(),
    ),
  );
  sl.registerLazySingleton<HomeCounselorViewModel>(
    () => HomeCounselorViewModel(
      serviceTypeRepository: sl<ServiceTypeRepository>(),
      scheduleRepository: sl<ScheduleRepository>(),
      authViewModel: sl<AuthViewModel>(),
    ),
  );
  sl.registerLazySingleton<HomeAdminViewModel>(
    () => HomeAdminViewModel(
      userRepository: sl<UserRepository>(),
      serviceTypeRepository: sl<ServiceTypeRepository>(),
      scheduleRepository: sl<ScheduleRepository>(),
    ),
  );
  sl.registerLazySingleton<RoomViewModel>(
    () => RoomViewModel(
      scheduleRepository: sl<ScheduleRepository>(),
      roomRepository: sl<RoomRepository>(),
      authViewModel: sl<AuthViewModel>(),
    ),
  );

   // Routes
  di.registerSingleton<AppRoutes>(AppRoutes(di<AuthViewModel>()));
}
