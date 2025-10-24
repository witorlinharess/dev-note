import 'dart:io';

import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/services.dart';
import '../utils/storage_helper.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'about_screen.dart';
import 'auth/login_screen.dart';
import '../widgets/safe_scaffold.dart';

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
    if (!mounted) return;
    
    // Usar avatar do usuário se disponível, senão usar foto local
    String? photoPath;
    if (user?.avatar != null && user!.avatar!.isNotEmpty) {
      // Se o avatar é uma URL completa, usar diretamente
      if (user.avatar!.startsWith('http')) {
        photoPath = user.avatar;
      } else {
        // Se é um caminho relativo, construir URL completa
        photoPath = 'http://10.0.2.2:3000${user.avatar}';
      }
    } else {
      // Fallback para foto local
      photoPath = await StorageHelper.getUserPhotoPath();
    }
    
    setState(() {
      _user = user;
      _photoPath = photoPath;
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

    return SafeScaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        toolbarHeight: 80.0,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: AppColors.primaryDark,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        surfaceTintColor: AppColors.primaryDark,
        shadowColor: AppColors.primaryDark,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Menu',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.0),
            child: Divider(height: 0.2, thickness: 0.2, color: AppColors.dividerColor),
          ),
        ),
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
                  backgroundImage: _photoPath != null 
                    ? (_photoPath!.startsWith('http') 
                        ? NetworkImage(_photoPath!) as ImageProvider
                        : FileImage(File(_photoPath!)))
                    : null,
                  child: _photoPath == null ? const Icon(Icons.person, color: Colors.white, size: 36) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryLight)),
                      const SizedBox(height: 6),
                      Text(_user?.name ?? _user?.username ?? '-', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
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
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Configurações'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showConfigurationsDialog(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Sair',
                onPressed: _logout,
                type: ButtonType.error,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfigurationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width - 32, // Largura similar ao botão Sair (tela menos padding)
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configurações',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Excluir conta'),
                  subtitle: const Text('Remover permanentemente'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteAccountDialog();
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                    ),
                    child: const Text('Fechar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir conta'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️ ATENÇÃO: Esta ação é irreversível!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Ao excluir sua conta:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Todos os seus dados serão permanentemente removidos'),
              Text('• Suas tarefas e informações não poderão ser recuperadas'),
              Text('• Seu e-mail e nome de usuário ficarão permanentemente indisponíveis para uso futuro'),
              SizedBox(height: 16),
              Text(
                'Tem certeza que deseja continuar?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
              ),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => _deleteAccount(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Excluir conta'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() async {
    try {
      Navigator.of(context).pop(); // Fecha o dialog
      
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await AuthService.deleteAccount();
      
      if (mounted) {
        Navigator.of(context).pop(); // Fecha o loading
        
        // Navegar para tela de login e limpar todo o stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Fecha o loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir conta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // navigation-only screen: EditProfileScreen and AboutScreen are pushed from the menu items
}
