import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/contact.dart';

class ContactProvider with ChangeNotifier {
  final List<Contact> _contacts = [];
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  List<Contact> get contacts => List.unmodifiable(_contacts);

  Future<void> fetchContacts() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('contacts').get();
      _contacts.clear();
      for (var doc in querySnapshot.docs) {
        _contacts.add(Contact.fromMap(doc.data(), doc.id));
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching contacts: $e");
    }
  }

  Future<void> addContact(Contact contact) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('contacts')
          .add(contact.toMap());
      final newContact = contact.copyWith(id: docRef.id);
      _contacts.add(newContact);
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding contact: $e");
    }
  }

  Future<void> updateContact(Contact updatedContact) async {
    try {
      await FirebaseFirestore.instance
          .collection('contacts')
          .doc(updatedContact.id)
          .update(updatedContact.toMap());

      final index =
          _contacts.indexWhere((contact) => contact.id == updatedContact.id);
      if (index != -1) {
        _contacts[index] = updatedContact;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating contact: $e");
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await FirebaseFirestore.instance
          .collection('contacts')
          .doc(contactId)
          .delete();
      _contacts.removeWhere((contact) => contact.id == contactId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting contact: $e");
    }
  }

  Contact? getContactById(String id) {
    return _contacts.firstWhere(
      (contact) => contact.id == id,
    );
  }

  Future<void> toggleFavoriteStatus(String contactId) async {
    final contactIndex =
        _contacts.indexWhere((contact) => contact.id == contactId);
    if (contactIndex != -1) {
      final currentContact = _contacts[contactIndex];
      final updatedContact = currentContact.copyWith(
        isFavorite: !currentContact.isFavorite,
      );

      try {
        await FirebaseFirestore.instance
            .collection('contacts')
            .doc(contactId)
            .update({'isFavorite': updatedContact.isFavorite});

        _contacts[contactIndex] = updatedContact;
        notifyListeners();
      } catch (e) {
        debugPrint("Error toggling favorite status: $e");
      }
    }
  }

  Future<void> toggleBlacklistStatus(String contactId) async {
    final contactIndex =
        _contacts.indexWhere((contact) => contact.id == contactId);
    if (contactIndex != -1) {
      final currentContact = _contacts[contactIndex];
      final updatedContact = currentContact.copyWith(
        isBlacklisted: !currentContact.isBlacklisted,
      );

      try {
        await FirebaseFirestore.instance
            .collection('contacts')
            .doc(contactId)
            .update({'isBlacklisted': updatedContact.isBlacklisted});

        _contacts[contactIndex] = updatedContact;
        notifyListeners();
      } catch (e) {
        debugPrint("Error toggling blacklist status: $e");
      }
    }
  }

  bool isFavorite(String contactId) {
    final contact = _contacts.firstWhere(
      (contact) => contact.id == contactId,
    );
    return contact.isFavorite ?? false;
  }

  bool isBlacklisted(String contactId) {
    final contact = _contacts.firstWhere(
      (contact) => contact.id == contactId,
    );
    return contact.isBlacklisted ?? false;
  }

  Future<void> savePasscode(String passcode) async {
    if (passcode.isNotEmpty && passcode.length >= 4) {
      await _storage.write(key: 'passcode', value: passcode);
    }
  }

  Future<String?> getStoredPasscode() async {
    return await _storage.read(key: 'passcode');
  }

  Future<void> removePasscode() async {
    await _storage.delete(key: 'passcode');
  }
}
