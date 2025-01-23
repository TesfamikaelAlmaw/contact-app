import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'providers/contact_provider.dart';
import 'screens/home_page.dart' as home;
import 'screens/add_contact_page.dart';
import 'screens/passcode_page.dart';
import 'providers/theme_provider.dart';
import 'firebase_options.dart';
import 'screens/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  final storage = FlutterSecureStorage();
  final passcode = await storage.read(key: 'passcode');

  runApp(ContactApp(passcodeSet: passcode != null));
}

class ContactApp extends StatelessWidget {
  final bool passcodeSet;

  const ContactApp({Key? key, required this.passcodeSet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme:
                themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            
            home: passcodeSet
                ? PasscodePage() 
                : home.HomePage(requirePasscode: false), 
            routes: {
              '/settings': (context) => SettingsPage(),
              '/home': (context) => home.HomePage(requirePasscode: false),
              '/add': (context) => AddContactPage(),
              '/passcode': (context) => PasscodePage(),
            },
          );
        },
      ),
    );
  }
}
