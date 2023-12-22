import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:lets_talk/features/auth/repository/auth_repository.dart';
import 'package:lets_talk/models/user_model.dart';
import 'package:riverpod/riverpod.dart';

final authConterollerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

final userDataAuthProvider = FutureProvider((ref) {
  final authControllr = ref.watch(authConterollerProvider);
  return authControllr.getUserData();
});

class AuthController {
  final AuthRepository authRepository;
  final ProviderRef ref;
  AuthController({required this.authRepository, required this.ref});

  Future<UserModel?> getUserData() async {
    UserModel? user = await authRepository.getCurrentUserData();
    return user;
  }

  void signInWithPhone(BuildContext context, String phoneNumber) {
    authRepository.signInWithPhone(context, phoneNumber);
  }

  void verifyOtp(BuildContext context, String verificationId, String userOtp) {
    authRepository.verifyOtp(
        context: context, verificationId: verificationId, userOtp: userOtp);
  }
  
  void saveUserDataToFirebase(
      BuildContext context, 
      String name, 
      File? profilePic
      ) {
    authRepository.saveUserDataToFirebase(
        name: name, 
        profilePic: profilePic, 
        ref: ref, 
        context: context
    );
  }

  Stream<UserModel> userDataById(String userId) {
    return authRepository.userData(userId);
  }

  void setUserState(bool isOnline) {
    authRepository.setUserState(isOnline);
  }
}
