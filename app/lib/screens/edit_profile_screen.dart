import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../utils/storage_helper.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  User? _user;
  final _emailCtrl = TextEditingController();
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
    });
  }

  Future<void> _saveEmail() async {
    if (_user == null) return;
    setState(() => _saving = true);
    final updated = _user!.copyWith(email: _emailCtrl.text.trim());
    await StorageHelper.saveUser(updated);
    if (!mounted) return;
    setState(() {
      _user = updated;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail atualizado')));
  }

  Future<void> _changePassword() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final res = await showDialog<bool>(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Alterar senha'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: currentCtrl, decoration: const InputDecoration(labelText: 'Senha atual'), obscureText: true),
            const SizedBox(height: 8),
            TextField(controller: newCtrl, decoration: const InputDecoration(labelText: 'Nova senha'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Alterar')),
        ],
      );
    });

    if (res == true) {
      final current = currentCtrl.text;
      final nw = newCtrl.text;
      final response = await AuthService.changePassword(current, nw);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha alterada com sucesso')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error ?? 'Erro ao alterar senha')));
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil'), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: TextEditingController(text: _user?.username ?? ''), enabled: false, decoration: const InputDecoration(labelText: 'Usuário')),
            const SizedBox(height: 12),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'E-mail')),
            const SizedBox(height: 20),
            Row(children: [Expanded(child: ElevatedButton(onPressed: _saving ? null : _saveEmail, child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar e-mail')))]),
            const SizedBox(height: 12),
            Row(children: [Expanded(child: OutlinedButton(onPressed: _changePassword, child: const Text('Alterar senha')))]),
          ],
        ),
      ),
    );
  }
}
