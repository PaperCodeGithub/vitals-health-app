import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitals/tabs/nearby/nearby.dart';
import 'package:vitals/welcome_screen.dart';
import 'package:vitals/auth/CreateProfile.dart';
import 'package:vitals/services/apis.dart';
import 'package:vitals/tabs/chatAI/chatAI.dart';
import 'package:vitals/tabs/home/home.dart';
import 'package:vitals/tabs/settings/settings.dart';

import 'bloc/appointments/appointments_tab.dart';
import 'firebase_options.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> loadTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final String? savedTheme = prefs.getString('theme_mode');

  if (savedTheme == 'light') {
    themeNotifier.value = ThemeMode.light;
  } else if (savedTheme == 'dark') {
    themeNotifier.value = ThemeMode.dark;
  } else {
    themeNotifier.value = ThemeMode.system;
  }
}

Future<void> saveTheme(ThemeMode mode) async {
  themeNotifier.value = mode;

  final prefs = await SharedPreferences.getInstance();
  if (mode == ThemeMode.light) {
    await prefs.setString('theme_mode', 'light');
  } else if (mode == ThemeMode.dark) {
    await prefs.setString('theme_mode', 'dark');
  } else {
    await prefs.setString('theme_mode', 'system');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await loadTheme();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  Widget build(BuildContext context){
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, child){
        return MaterialApp(
          home: const AuthGate(),
          themeMode: currentMode,

          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            scaffoldBackgroundColor: Colors.grey.shade50,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.dark(
              primary: Colors.blue,
              surface: Colors.grey.shade900,
              onSurface: Colors.white,
            ),
            scaffoldBackgroundColor: Colors.black,
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (authSnapshot.hasData && authSnapshot.data != null) {
          return const ProfileCheckGate();
        }

        return const WelcomeScreen();
      },
    );
  }
}

class ProfileCheckGate extends StatefulWidget {
  const ProfileCheckGate({super.key});
  @override
  State<ProfileCheckGate> createState() => _ProfileCheckGateState();
}

class _ProfileCheckGateState extends State<ProfileCheckGate> {

  late Future<bool> _userExistsFuture;

  @override
  void initState() {
    super.initState();
    _userExistsFuture = DatabaseService.instance.doesUserExist();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _userExistsFuture,
      builder: (context, dbSnapshot) {
        if (dbSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (dbSnapshot.hasData && dbSnapshot.data == true) {
          return FutureBuilder<String>(
            future: DatabaseService.instance.getAccountType(),
            builder: (context, typeSnapshot) {
              if (typeSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (typeSnapshot.hasData && typeSnapshot.data != null) {
                return BottomNavLayout(accountType: typeSnapshot.data!);
              } else {
                return const CreateProfile();
              }
            },
          );
        } else {
          return const CreateProfile();
        }
      },
    );
  }
}

class BottomNavLayout extends StatefulWidget{
  final String? accountType;

  BottomNavLayout({super.key, required this.accountType});

  @override
  State<BottomNavLayout> createState() => _BottomNavLayout();

}

class _BottomNavLayout extends State<BottomNavLayout>{

  int _selectedIndex = 0;


  List<Widget> get _screens => [
    Center(child: HomeWidget(accountType: widget.accountType)),
    const Center(child: AppointmentsTab()),
    const Center(child: NearbyDoctorsScreen()),
    const Center(child: ChatAiScreen()),
    Center(child: SettingsScreen(accountType: widget.accountType,)),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.shifting,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: 'Appointments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.share_location_outlined),
                label: 'NearBy',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.panorama_photosphere),
                label: 'Dr. DeepLearno',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Settings',
              ),
            ],
          ),
        )
      )
    );
  }
}