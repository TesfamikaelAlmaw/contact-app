import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/contact.dart';
import '../providers/contact_provider.dart';
import 'edit_contact_page.dart';

class ContactDetailsPage extends StatelessWidget {
  final Contact contact;

  const ContactDetailsPage({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.name),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditContactPage(contact: contact),
                ),
              );
            },
          ),
          Consumer<ContactProvider>(
            builder: (context, contactProvider, child) {
              final isFavorite =
                  contactProvider.getContactById(contact.id)?.isFavorite ??
                      false;
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  contactProvider.toggleFavoriteStatus(contact.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite
                            ? 'Removed from favorites'
                            : 'Added to favorites',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
          Consumer<ContactProvider>(
            builder: (context, contactProvider, child) {
              final isBlacklisted =
                  contactProvider.getContactById(contact.id)?.isBlacklisted ??
                      false;
              return IconButton(
                icon: Icon(
                  isBlacklisted ? Icons.block : Icons.check_circle,
                  color: isBlacklisted ? Colors.red : Colors.green,
                ),
                onPressed: () {
                  contactProvider.toggleBlacklistStatus(contact.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isBlacklisted
                            ? 'Contact unblacklisted'
                            : 'Contact blacklisted',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: contact.imageUrl.isNotEmpty
                    ? FileImage(File(contact.imageUrl))
                    : null,
                child: contact.imageUrl.isEmpty
                    ? Text(
                        contact.name[0].toUpperCase(),
                        style:
                            const TextStyle(fontSize: 40, color: Colors.white),
                      )
                    : null,
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Name:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(contact.name, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text(
              'Phone:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(contact.phone, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text(
              'Email:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(contact.email, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text(
              'Category:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              contact.category.isNotEmpty ? contact.category : 'Uncategorized',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Provider.of<ContactProvider>(context, listen: false)
                      .deleteContact(contact.id);

                  Navigator.pop(context);
                },
                child: const Text('Delete Contact'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
