import 'package:diary/data/models/contact.dart';
import 'package:diary/widgets/common/contact_input.dart';
import 'package:flutter/material.dart';

void showEditContactPopup(BuildContext context, MyContact? givenContact) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (builder) {
        return ContactInputWidget(
          givenContact: givenContact,
        );
      });
}
