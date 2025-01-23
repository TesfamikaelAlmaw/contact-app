import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PasscodePage extends StatefulWidget {
  const PasscodePage({Key? key}) : super(key: key);
  @override
  State<PasscodePage> createState() => _PasscodePageState();
}

class _PasscodePageState extends State<PasscodePage> {
  final _storage = FlutterSecureStorage();
  String _enteredPasscode = '';
  String? _savedPasscode;
  @override
  void initState() {
    super.initState();
    _loadPasscode();
  }

  Future<void> _loadPasscode() async {
    _savedPasscode = await _storage.read(key: 'passcode');
  }

  void _onPasscodeEntered() {
    if (_savedPasscode == null) {
      _storage.write(key: 'passcode', value: _enteredPasscode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passcode set successfully!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else if (_enteredPasscode == _savedPasscode) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect Passcode!')),
      );
      setState(() {
        _enteredPasscode = '';
      });
    }
  }

  void _onNumberPressed(String number) {
    if (_enteredPasscode.length < 4) {
      setState(() {
        _enteredPasscode += number;
      });

      if (_enteredPasscode.length == 4) {
        _onPasscodeEntered();
      }
    }
  }

  void _clearLastNumber() {
    if (_enteredPasscode.isNotEmpty) {
      setState(() {
        _enteredPasscode =
            _enteredPasscode.substring(0, _enteredPasscode.length - 1);
      });
    }
  }

  void _clearAll() {
    setState(() {
      _enteredPasscode = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Passcode')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _enteredPasscode.padRight(4, '*'),
              style: TextStyle(fontSize: 32, letterSpacing: 20),
            ),
            SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: List.generate(12, (index) {
                  if (index < 9) {
                    return ElevatedButton(
                      onPressed: () => _onNumberPressed((index + 1).toString()),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else if (index == 9) {
                    return ElevatedButton(
                      onPressed: () => _onNumberPressed('0'),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: Text(
                        '0',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else if (index == 10) {
                    return ElevatedButton(
                      onPressed: _clearAll,
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'C',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    return ElevatedButton(
                      onPressed: _clearLastNumber,
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'X',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
