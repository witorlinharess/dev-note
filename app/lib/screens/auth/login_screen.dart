import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Autenticando...')),
      );
      // TODO: implementar lógica de autenticação
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                const SizedBox(height: 24),
                const AppLogo(
                  assetPath: 'assets/images/logo-devnote.svg',
                  packageName: 'app_images',
                  size: 124,
                ),

                const SizedBox(height:24),
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
                      // Email
                      CustomTextField(
                        controller: _emailController,
                        hint: 'E-mail',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe o e-mail';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Senha
                      CustomTextField(
                        controller: _passwordController,
                        hint: 'Senha',
                        obscureText: true,
                        prefixIcon: Icons.lock,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe a senha';
                          return null;
                        },
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

                      // Entrar (gradient button)
                      GradientButton(
                        text: 'Entrar',
                        onPressed: _onLogin,
                        height: 56,
                        borderRadius: 12,
                        fullWidth: true,
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
      ),
    );
  }
}
