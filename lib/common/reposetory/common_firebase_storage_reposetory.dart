import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commonFirebaseStorageRepoProvider = Provider(
        (ref) => commonFirebaseStorageRepo(
            firebaseStorage: FirebaseStorage.instance
        ),
);

class commonFirebaseStorageRepo {
  final FirebaseStorage firebaseStorage;

  commonFirebaseStorageRepo({
    required this.firebaseStorage
  });

  Future<String> storeFileToFirebase(String ref, File file) async {
    UploadTask uploadTask = firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

}