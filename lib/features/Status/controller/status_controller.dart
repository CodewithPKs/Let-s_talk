import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_talk/features/Status/reposetory/status_reposetory.dart';
import 'package:lets_talk/features/auth/controller/auth_controller.dart';


final statusControllerProvider = Provider(
      (ref) {
        final statusRepository = ref.read(statusRepositoryProvider);
        return StatusController(
          statusRepository: statusRepository,
          ref: ref
        );
      }
);

class StatusController {
  final StatusRepository statusRepository;
  final ProviderRef ref;

  StatusController({
    required this.statusRepository,
    required this.ref,
  });

  void addStatus(File file, BuildContext context) {
    ref.watch(userDataAuthProvider).whenData((value) {
      statusRepository.uploadStatus(
          userName: value!.name,
          profilePic: value.profilePic,
          phoneNumber: value.phoneNumber,
          statusImage: file,
          context: context,
      );
    });
  }
}
