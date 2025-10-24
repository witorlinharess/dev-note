import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  final _nameCtrl = TextEditingController();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _saving = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  

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
      _nameCtrl.text = u?.name ?? '';
      _usernameCtrl.text = u?.username ?? '';
    });
  }

  void _showImageSourceDialog() {
    // Verificar se o usuário já tem uma foto
    final hasExistingPhoto = _user?.avatar != null && _user!.avatar!.isNotEmpty;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecionar foto'),
          content: const Text('Escolha a origem da sua foto de perfil:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _selectImageFromSource(ImageSource.camera);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
              child: const Text('Câmera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _selectImageFromSource(ImageSource.gallery);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
              child: const Text('Galeria'),
            ),
            // Mostrar botão de excluir apenas se houver foto existente
            if (hasExistingPhoto)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deletePhoto();
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.priorityHigh),
                child: const Text('Excluir'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: AppColors.priorityHigh),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao selecionar imagem. Tente novamente.'),
          backgroundColor: AppColors.priorityHigh,
        ),
      );
    }
  }

  Future<void> _deletePhoto() async {
    try {
      // Chamar API para excluir foto do servidor
      final deleteResponse = await AuthService.deleteProfilePhoto();
      
      if (!mounted) return;
      
      if (deleteResponse.success) {
        // Recarregar dados do usuário
        await _load();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil removida com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${deleteResponse.error ?? 'Erro ao remover foto'}'),
            backgroundColor: AppColors.priorityHigh,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro inesperado: $e'),
          backgroundColor: AppColors.priorityHigh,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    final nameTrim = _nameCtrl.text.trim();
    final current = _currentCtrl.text;
    final nw = _newCtrl.text;

    // Check if there are any changes
    final hasNameChange = nameTrim != (_user?.name ?? '');
    final hasPasswordChange = current.isNotEmpty || nw.isNotEmpty;
    final hasPhotoChange = _selectedImage != null;

    if (!hasNameChange && !hasPasswordChange && !hasPhotoChange) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhuma alteração detectada')));
      return;
    }

    setState(() => _saving = true);

    // Save name if changed
    if (hasNameChange) {
      try {
        final nameResponse = await AuthService.updateProfileName(nameTrim);
        if (!mounted) {
          setState(() => _saving = false);
          return;
        }
        
        if (nameResponse.success) {
          // Reload user data to get updated profile
          await _load();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${nameResponse.error ?? 'Erro ao atualizar nome'}'),
              backgroundColor: AppColors.priorityHigh,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro inesperado: $e'),
            backgroundColor: AppColors.priorityHigh,
          ),
        );
      }
    }

    // Upload profile photo if selected
    if (hasPhotoChange) {
      try {
        final photoResponse = await AuthService.updateProfilePhoto(_selectedImage!.path);
        if (!mounted) {
          setState(() => _saving = false);
          return;
        }
        
        if (photoResponse.success) {
          setState(() {
            _selectedImage = null; // Clear selected image after successful upload
          });
          
          // Reload user data to get updated profile
          await _load();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${photoResponse.error ?? 'Erro ao atualizar foto de perfil'}'),
              backgroundColor: AppColors.priorityHigh,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro inesperado: $e'),
            backgroundColor: AppColors.priorityHigh,
          ),
        );
      }
    }

    // Change password if fields provided
    if (hasPasswordChange) {
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error ?? 'Erro ao alterar senha')));
        }
      }
    }

    if (!mounted) return;
    setState(() => _saving = false);
    
    // Mostrar mensagem de sucesso geral se houve alguma alteração
    if (hasNameChange || hasPasswordChange || hasPhotoChange) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil salvo com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
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
            // Foto de perfil
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withOpacity(0.1),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: _selectedImage != null
                          ? ClipOval(
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            )
                          : _user?.avatar != null && _user!.avatar!.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    _user!.avatar!.startsWith('http') 
                                        ? _user!.avatar!
                                        : 'http://10.0.2.2:3000${_user!.avatar!}',
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('❌ Erro ao carregar avatar: $error');
                                      return const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.white,
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.white,
                                ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight,
                          border: Border.all(
                            color: AppColors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 18,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // username (read-only)
            SizedBox(
              width: double.infinity,
              child: CustomTextField(
                controller: _usernameCtrl,
                hint: 'Usuário',
                prefixIcon: Icons.person,
                enabled: false,
                textColor: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // email (read-only - conforme regras de negócio)
            SizedBox(
              width: double.infinity,
              child: CustomTextField(
                controller: _emailCtrl,
                hint: 'E-mail',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
                enabled: false,
                textColor: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // name (editable)
            SizedBox(
              width: double.infinity,
              child: CustomTextField(
                controller: _nameCtrl,
                hint: 'Insira seu nome',
                prefixIcon: Icons.badge,
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
