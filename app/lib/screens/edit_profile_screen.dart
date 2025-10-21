import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import '../utils/storage_helper.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/safe_scaffold.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  User? _user;
  final _emailCtrl = TextEditingController();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _saving = false;
  

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await StorageHelper.getUser();
    if (!mounted) return;
    setState(() {
      _user = u;
      _emailCtrl.text = u?.email ?? '';
      _usernameCtrl.text = u?.username ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    final emailTrim = _emailCtrl.text.trim();
    final current = _currentCtrl.text;
    final nw = _newCtrl.text;

    // Nothing to do?
    if (emailTrim == (_user?.email ?? '') && current.isEmpty && nw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhuma alteração detectada')));
      return;
    }

    setState(() => _saving = true);

    // Save email if changed
    if (emailTrim != (_user?.email ?? '')) {
      final updated = _user!.copyWith(email: emailTrim);
      await StorageHelper.saveUser(updated);
      if (!mounted) {
        setState(() => _saving = false);
        return;
      }
      setState(() {
        _user = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail atualizado')));
    }

    // Change password if fields provided
    if (current.isNotEmpty || nw.isNotEmpty) {
      if (current.isEmpty || nw.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha a senha atual e a nova senha')));
      } else {
        final response = await AuthService.changePassword(current, nw);
        if (!mounted) {
          setState(() => _saving = false);
          return;
        }
        if (response.success) {
          _currentCtrl.clear();
          _newCtrl.clear();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha alterada com sucesso')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error ?? 'Erro ao alterar senha')));
        }
      }
    }

    if (!mounted) return;
    setState(() => _saving = false);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    'Editar perfil',
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
          children: [
            // username (read-only)
            SizedBox(
              width: double.infinity,
              child: CustomTextField(
                controller: _usernameCtrl,
                hint: 'Usuário',
                prefixIcon: Icons.person,
                enabled: false,
              ),
            ),
            const SizedBox(height: 16),
            // email (editable)
            SizedBox(
              width: double.infinity,
              child: CustomTextField(
                controller: _emailCtrl,
                hint: 'E-mail',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
                required: true,
              ),
            ),
            const SizedBox(height: 16),
            // Password change fields (moved from dialog) - use CustomTextField to match other inputs
            SizedBox(
              width: double.infinity,
              child: CustomTextField(
                controller: _currentCtrl,
                hint: 'Senha atual',
                obscureText: true,
                prefixIcon: Icons.lock,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CustomTextField(
                controller: _newCtrl,
                hint: 'Nova senha',
                obscureText: true,
                prefixIcon: Icons.lock,
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: CustomButton(
              text: 'Salvar perfil',
              onPressed: _saving ? null : _saveProfile,
              type: ButtonType.primary,
              isLoading: _saving,
              fullWidth: true,
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.primaryDark,
            ))]),
          ],
        ),
      ),
    );
  }
}
