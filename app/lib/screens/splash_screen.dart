import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'auth/login_screen.dart';
import '../widgets/safe_scaffold.dart';
import '../utils/storage_helper.dart';
import 'main_nav_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Checa se usuário/token estão salvos. Se sim, vai para MainNavScreen.
    Future.delayed(const Duration(seconds: 1), () async {
      final token = await StorageHelper.getToken();
      final user = await StorageHelper.getUser();
      if (!mounted) return;
      if (token != null && user != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavScreen()));
        return;
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(
              assetPath: 'assets/images/logo-devnote.svg',
              packageName: 'app_images',
              size: 144,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
