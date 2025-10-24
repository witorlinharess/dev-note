import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'register_screen.dart';
import '../../services/auth_service.dart';
import '../main_nav_screen.dart';
import '../../widgets/safe_scaffold.dart';
import '../../widgets/login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      _performLogin();
    }
  }

  Future<void> _performLogin() async {
    setState(() => _isLoading = true);

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    try {
      // Simula um pequeno delay para mostrar o loading (verificação do usuário)
      await Future.delayed(const Duration(milliseconds: 500));
      
      final result = await AuthService.login(identifier, password);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result.success) {
        // Ir para a Home e limpar a pilha de navegação
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Usuário não encontrado ou senha incorreta'),
            backgroundColor: AppColors.priorityHigh,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro de conexão. Tente novamente.'),
          backgroundColor: AppColors.priorityHigh,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeScaffold(
      appBar: null,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const SizedBox(height: 24),
              const AppLogo(
                assetPath: 'assets/images/listfy-white.svg',
                packageName: 'app_images',
                size: 70,
              ),

              const SizedBox(height: 24),
              Text(
                'Bem-vindo!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 48),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Usuário ou Email
                    SizedBox(
                      width: double.infinity,
                      child: CustomTextField(
                        controller: _identifierController,
                        hint: '@usuário ou email',
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.alternate_email,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe o usuário ou e-mail';
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Senha
                    SizedBox(
                      width: double.infinity,
                      child: CustomTextField(
                        controller: _passwordController,
                        hint: 'Senha',
                        obscureText: true,
                        prefixIcon: Icons.lock,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe a senha';
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Esqueceu a senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Recuperação de senha - Em breve')),
                          );
                        },
                        child: Text(
                          'esqueceu a senha?',
                          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Entrar
                    LoginButton(
                      text: 'Entrar',
                      onPressed: _onLogin,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 32),

                    // Primeiro acesso
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Primeiro acesso? ',
                          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                          children: [
                            TextSpan(
                              text: 'Criar conta',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
