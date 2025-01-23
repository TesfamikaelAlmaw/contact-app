import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contact_provider.dart';
import 'add_contact_page.dart';
import 'contact_details_page.dart';
import '../models/contact.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';

class HomePage extends StatefulWidget {
  final bool requirePasscode;

  HomePage({this.requirePasscode = false});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = "";
  final _passcodeController = TextEditingController();
  bool _isPasscodeVerified = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.requirePasscode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPasscodeDialog();
      });
    }
  }

  Future<void> _showPasscodeDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Passcode'),
          content: TextField(
            controller: _passcodeController,
            decoration: InputDecoration(
              labelText: 'Passcode',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final passcode = _passcodeController.text.trim();
                final storedPasscode = await Provider.of<ContactProvider>(
                  context,
                  listen: false,
                ).getStoredPasscode();

                if (passcode == storedPasscode) {
                  setState(() {
                    _isPasscodeVerified = true;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Incorrect passcode!')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> callUser(String phone) async {
    final url = "tel:$phone";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not make the call to $phone")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.requirePasscode && !_isPasscodeVerified) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final contactProvider = Provider.of<ContactProvider>(context);
    contactProvider.fetchContacts();
    List<Contact> filteredContacts = contactProvider.contacts
        .where((contact) =>
            contact.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContactList(filteredContacts, showCallIcon: true),
          _buildContactList(
            filteredContacts.where((contact) => contact.isFavorite).toList(),
            showCallIcon: true,
          ),
          _buildContactList(
            filteredContacts.where((contact) => contact.isBlacklisted).toList(),
            showCallIcon: false,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddContactPage()),
        ),
        child: Icon(Icons.person_add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white),
                  onPressed: () => setState(() => _searchQuery = ""),
                )
              : null,
        ),
        style: TextStyle(color: Colors.white),
        onChanged: (query) => setState(() => _searchQuery = query),
      ),
      backgroundColor: Colors.teal,
      bottom: TabBar(
        controller: _tabController,
        tabs: [
          Tab(icon: Icon(Icons.contacts), text: 'All'),
          Tab(icon: Icon(Icons.favorite), text: 'Favorite'),
          Tab(icon: Icon(Icons.block), text: 'Blocked'),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Text(
              'Contact Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          ListTile(
            leading: Icon(Icons.toggle_on),
            title: Text('Toggle Theme'),
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactList(List<Contact> contacts,
      {required bool showCallIcon}) {
    if (contacts.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isNotEmpty
              ? 'No contacts match your search.'
              : 'No contacts found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: contact.imageUrl.isNotEmpty
                ? NetworkImage(contact.imageUrl)
                : null,
            child: contact.imageUrl.isEmpty
                ? Text(contact.name[0].toUpperCase())
                : null,
          ),
          title: Text(contact.name),
          subtitle: Text(contact.phone),
          trailing: showCallIcon
              ? IconButton(
                  icon: Icon(Icons.call, color: Theme.of(context).primaryColor),
                  onPressed: () => callUser(contact.phone),
                )
              : null,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContactDetailsPage(contact: contact),
            ),
          ),
        );
      },
    );
  }
}
