
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../reposetory/select_contact_repository.dart';

final getContactProvider = FutureProvider((ref) {
  final SelectContactRepo = ref.watch(SelectContactRepoProvider);
  return SelectContactRepo.getContacts();
});

final selectContactControllerProvider = Provider((ref) {
  final SelectContactRepo = ref.watch(SelectContactRepoProvider);
  return SelectContactController(
      ref: ref,
      selectContactRepo: SelectContactRepo
  );
});

final contactPermissionProvider = FutureProvider<bool>((ref) async {
  final status = await Permission.contacts.request();
  return status.isGranted;
});


class SelectContactController {
  final ProviderRef ref;
  final SelectContactRepo selectContactRepo;

  SelectContactController({
    required this.ref,
    required this.selectContactRepo
  });

 void selectContact(Contact selectedContact, BuildContext context){
    selectContactRepo.selectContact(selectedContact, context);
 }

}
