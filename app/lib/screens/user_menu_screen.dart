import 'dart:io';

import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../utils/storage_helper.dart';
import '../models/user.dart';
import 'edit_profile_screen.dart';
import 'about_screen.dart';
import 'auth/login_screen.dart';

class UserMenuScreen extends StatefulWidget {
  const UserMenuScreen({super.key});

  @override
  State<UserMenuScreen> createState() => _UserMenuScreenState();
}

class _UserMenuScreenState extends State<UserMenuScreen> {
  User? _user;
  String? _photoPath;
  // simple menu, navigation-only: Edit profile and About open new screens

  @override
  void initState() {
    super.initState();
    _loadData();
  // Removed TabController initialization
  }

  Future<void> _loadData() async {
    final user = await StorageHelper.getUser();
    final photo = await StorageHelper.getUserPhotoPath();
    if (!mounted) return;
    setState(() {
      _user = user;
      _photoPath = photo;
    });
  }

  String _greetingForHour(int hour) {
    if (hour >= 5 && hour < 12) return 'Bom dia';
    if (hour >= 12 && hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  Future<void> _logout() async {
    await StorageHelper.clearAuthData();
    if (!mounted) return;
    // Navigate back to LoginScreen and clear navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = _greetingForHour(hour);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu do usuário'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white24,
                  backgroundImage: _photoPath != null ? FileImage(File(_photoPath!)) : null,
                  child: _photoPath == null ? const Icon(Icons.person, color: Colors.white, size: 36) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Text(_user?.name ?? _user?.username ?? '-', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Simple vertical menu: Editar perfil, Sobre
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Editar perfil'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Sobre'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _logout,
                child: const Text('Sair'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // navigation-only screen: EditProfileScreen and AboutScreen are pushed from the menu items
}
