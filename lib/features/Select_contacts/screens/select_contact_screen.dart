import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/error.dart';
import '../../../common/widget/loder.dart';
import '../controller/select_contact_controller.dart';

class SelectContactScreen extends ConsumerWidget {
  static const String routeName = '/select-contact';

  const SelectContactScreen({super.key});

  void selectContacts(WidgetRef ref, Contact selectedContact, BuildContext context) {
    ref.read(selectContactControllerProvider).selectContact(selectedContact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactPermission = ref.watch(contactPermissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contact'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: contactPermission.when(
        data: (isGranted) {
          if (isGranted) {
            return ref.watch(getContactProvider).when(
              data: (contactList) => ListView.builder(
                itemCount: contactList.length,
                itemBuilder: (context, index) {
                  final contact = contactList[index];
                  return InkWell(
                    onTap: () => selectContacts(ref, contact, context),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          contact.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        leading: contact.photo == null
                            ? null
                            : CircleAvatar(
                          backgroundImage: MemoryImage(contact.photo!),
                          radius: 30,
                        ),
                      ),
                    ),
                  );
                },
              ),
              error: (err, trace) => ErrorScreen(error: err.toString()),
              loading: () => const Loader(),
            );
          } else {
            return const Text('Contact permission not granted');
          }
        },
        loading: () => const Loader(),
        error: (err, trace) => ErrorScreen(error: err.toString()),
      ),
    );
  }
}
