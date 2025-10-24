import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import '../../services/auth_service.dart';
import '../main_nav_screen.dart';
import 'terms_screen.dart';
import '../../widgets/safe_scaffold.dart';
import '../../widgets/create_account_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onCreateAccount() {
    if (_formKey.currentState?.validate() ?? false) {
      _createAccount();
    }
  }

  Future<void> _createAccount() async {
    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
  final password = _passwordController.text;

    final result = await AuthService.register(
      email: email,
      password: password,
      username: username.isEmpty ? null : username,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Conta criada com sucesso')),
      );

      // Navegar para a Home e limpar a pilha de navegação
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
        (route) => false,
      );
    } else {
      final errorMsg = result.error ?? 'Erro ao criar conta';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeScaffold(
      appBar: null,
      body: Stack(
        children: [
          // Seta para voltar ao login (parte superior esquerda)
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          
          // Conteúdo principal
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),
                  const AppLogo(
                    assetPath: 'assets/images/listfy-white.svg',
                    packageName: 'app_images',
                    size: 50,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Crie sua conta grátis!',
                    style: theme.textTheme.headlineSmall?.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 24),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _usernameController,
                          hint: 'Nome de usuário',
                          prefixIcon: Icons.alternate_email,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Informe o nome de usuário';
                            if (v.length < 3) return 'Mínimo 3 caracteres';
                            if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(v)) return 'Apenas letras e números';
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _emailController,
                          hint: 'E-mail',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Informe o e-mail';
                            if (!v.contains('@')) return 'E-mail inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _passwordController,
                          hint: 'Senha',
                          obscureText: true,
                          prefixIcon: Icons.lock,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Informe a senha';
                            if (v.length < 6) return 'Senha muito curta';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _confirmController,
                          hint: 'Confirmar senha',
                          obscureText: true,
                          prefixIcon: Icons.lock,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Confirme a senha';
                            if (v != _passwordController.text) return 'As senhas não conferem';
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        CreateAccountButton(
                          text: 'Criar conta grátis',
                          onPressed: _onCreateAccount,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const TermsScreen()),
                            );
                          },
                          child: Text(
                            'Ao continuar você concorda com os termos e política de privacidade',
                            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
