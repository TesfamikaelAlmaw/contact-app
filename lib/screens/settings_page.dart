import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _storage = FlutterSecureStorage();
  String? _savedPasscode;
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    String? passcode = await _storage.read(key: 'passcode');
    setState(() {
      _savedPasscode = passcode;
    });
  }

  Future<void> _setPasscode(String passcode) async {
    try {
      await _storage.write(key: 'passcode', value: passcode);
      setState(() {
        _savedPasscode = passcode;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passcode set successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set passcode. Please try again.')),
      );
    }
  }

  Future<void> _clearPasscode() async {
    try {
      await _storage.delete(key: 'passcode');
      setState(() {
        _savedPasscode = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passcode cleared successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear passcode. Please try again.')),
      );
    }
  }

  void _managePasscode() {
    if (_savedPasscode == null) {
      _showPasscodeDialog();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Clear Passcode'),
          content: Text('Are you sure you want to clear the passcode?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _clearPasscode();
              },
              child: Text('Clear'),
            ),
          ],
        ),
      );
    }
  }

  void _showPasscodeDialog() {
    final TextEditingController _passcodeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Passcode'),
        content: TextField(
          controller: _passcodeController,
          obscureText: true,
          maxLength: 4,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter 4-digit passcode',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final passcode = _passcodeController.text;
              if (passcode.length == 4 && int.tryParse(passcode) != null) {
                Navigator.pop(context);
                _setPasscode(passcode);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Passcode must be a 4-digit number.')),
                );
              }
            },
            child: Text('Set'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('Manage Passcode'),
              subtitle: Text(
                _savedPasscode == null ? 'No passcode set' : 'Passcode is set',
              ),
              trailing: IconButton(
                icon: Icon(
                  _savedPasscode == null ? Icons.add : Icons.delete,
                  color: _savedPasscode == null ? Colors.green : Colors.red,
                ),
                onPressed: _managePasscode,
                tooltip:
                    _savedPasscode == null ? 'Set Passcode' : 'Clear Passcode',
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
