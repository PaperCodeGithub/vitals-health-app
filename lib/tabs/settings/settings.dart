import 'package:flutter/material.dart';
import 'package:vitals/tabs/settings/sub/EditProfileScreen.dart';
import 'package:vitals/tabs/settings/sub/ManageAccountScreen.dart';

import '../../main.dart';

class SettingsScreen extends StatefulWidget{
  final String? accountType;
  const SettingsScreen({super.key, required this.accountType});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();

}

class _SettingsScreen extends State<SettingsScreen>{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 64,
                    backgroundColor: Colors.blue,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage('https://your-image-url.com/profile.jpg'),
                    ),
                  ),
                ),
                SizedBox(height: 50),
                _buildSectionHeader("Account"),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text("Edit Profile"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfileScreen(accountType: widget.accountType,)),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.account_circle_outlined, color: Colors.blue),
                  title: const Text("Manage Account"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(

                      context,
                      MaterialPageRoute(builder: (context) => ManageAccountScreen()),
                    );
                  },
                ),

                const Divider(height: 32),

                _buildSectionHeader("Preferences"),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined, color: Colors.blue),
                  title: const Text("Push Notifications"),
                  trailing: Switch(
                    value: true,
                    activeThumbColor: Colors.blue,
                    onChanged: (bool value) {},
                  ),
                ),

                const SizedBox(height: 16),

                _buildSectionHeader("Theme"),

                ValueListenableBuilder<ThemeMode>(
                  valueListenable: themeNotifier,
                  builder: (context, ThemeMode currentMode, child) {
                    return Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          title: const Text("System Default"),
                          value: ThemeMode.system,
                          groupValue: currentMode,
                          activeColor: Colors.blue,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          onChanged: (ThemeMode? value) {
                            if (value != null) saveTheme(value);
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text("Light Mode"),
                          value: ThemeMode.light,
                          groupValue: currentMode,
                          activeColor: Colors.blue,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          onChanged: (ThemeMode? value) {
                            if (value != null) saveTheme(value);
                          },
                        ),
                        RadioListTile<ThemeMode>(
                          title: const Text("Dark Mode"),
                          value: ThemeMode.dark,
                          groupValue: currentMode,
                          activeColor: Colors.blue,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          onChanged: (ThemeMode? value) {
                            if (value != null) saveTheme(value);
                          },
                        ),
                      ],
                    );
                  },
                ),

                const Divider(height: 32),

                _buildSectionHeader("Support"),

                ListTile(
                  leading: const Icon(Icons.help_outline, color: Colors.blue),
                  title: const Text("Help Center & FAQ"),
                  onTap: () {},
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),

                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined, color: Colors.blue),
                  title: const Text("Privacy Policy"),
                  onTap: () {},
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                ),

                const SizedBox(height: 40),

              ]
            ),
          )
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

}