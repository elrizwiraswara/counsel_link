import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/common/result.dart';
import '../../core/const/constants.dart';
import '../../data/models/user/area_model.dart';
import '../../data/models/user/gender_model.dart';
import '../../data/models/user/user_model.dart';
import '../../data/repositories/storage_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_view_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthViewModel authViewModel;
  final StorageRepository storageRepository;
  final UserRepository userRepository;

  ProfileViewModel({
    required this.authViewModel,
    required this.storageRepository,
    required this.userRepository,
  });

  UserModel? user;

  String? imageUrl;
  MenuItemModel selectedGender = genderMenuItems.first;
  MenuItemModel selectedReligion = religionMenuItems.first;
  Map<String, dynamic> city = locationData.first;
  Map<String, dynamic> district = locationData[0]['district'][0];
  Map<String, dynamic> village = locationData[0]['district'][0]['village'][0];

  void initProfileView() {
    user = authViewModel.user;
    if (user == null) throw Exception('Unauthenticated!');

    imageUrl = user!.imageUrl;
    selectedGender = genderMenuItems.firstWhere((e) => e.id == (user!.gender ?? genderMenuItems.first.id));
    selectedReligion = religionMenuItems.firstWhere((e) => e.id == (user!.religion ?? religionMenuItems.first.id));
    city = user!.city?.toJson() ?? city;
    district = user!.district?.toJson() ?? district;
    village = user!.village?.toJson() ?? village;
    notifyListeners();
  }

  void onTapEditPhoto() async {}

  Future<Result<void>> uploadImage(XFile file) async {
    if (user == null) initProfileView();

    Uint8List imageData = await file.readAsBytes();

    final res = await storageRepository.uploadUserPhoto(user!.phone!, imageData);
    if (res.isFailure) return Result.failure(error: res.error!);

    user?.imageUrl = res.data;

    final updateRes = await createOrUpdateUser(isCreateNewUser: false);
    if (updateRes.isFailure) return Result.failure(error: updateRes.error!);

    await authViewModel.refreshUser();

    return Result.success(data: null);
  }

  Future<Result<void>> createOrUpdateUser({required bool isCreateNewUser}) async {
    if (user == null || user?.phone == null) {
      return Result.failure(error: 'user or phone null');
    }

    final now = DateTime.now().toIso8601String();

    if (isCreateNewUser) {
      user?.dateCreated = now;
    } else {
      user?.dateUpdated = now;
    }

    final res = await userRepository.createOrUpdateUser(user!);
    if (res.isFailure) return Result.failure(error: res.error!);

    notifyListeners();

    return Result.success(data: null);
  }

  void onChangedName(String value) {
    user?.name = value;
    notifyListeners();
  }

  void onChangedGender(String? value) {
    selectedGender = genderMenuItems.firstWhere((e) => e.id == value);
    user?.gender = selectedGender.id;
    notifyListeners();
  }

  void onChangedBirthPlace(String value) {
    user?.birthPlace = value;
    notifyListeners();
  }

  void onChangedAddress(String value) {
    user?.address = value;
    notifyListeners();
  }

  void onChangedReligion(String? value) {
    selectedReligion = religionMenuItems.firstWhere((e) => e.id == value);
    user?.religion = selectedReligion.id;
    notifyListeners();
  }

  void onChangedBirthdate(String formattedDate) async {
    user?.birthDate = formattedDate;
    notifyListeners();
  }

  void onChangedCity(Map<String, dynamic>? value) {
    if (value == null) return;
    city = value;
    district = value['district'][0];
    village = value['district'][0]['village'][0];
    user?.city = AreaModel.fromJson(city);
    notifyListeners();
  }

  void onChangedDistrict(Map<String, dynamic>? value) {
    if (value == null) return;
    district = value;
    village = value['village'][0];
    user?.district = AreaModel.fromJson(district);
    notifyListeners();
  }

  void onChangedVillage(Map<String, dynamic>? value) {
    if (value == null) return;
    village = value;
    user?.village = AreaModel.fromJson(village);
    notifyListeners();
  }
}
