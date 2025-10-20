import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dev Todo App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Todo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de boas-vindas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo ao Dev Todo! 👨‍💻',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Organize suas tarefas de desenvolvimento',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Seção de status
            Text(
              'Status do Projeto:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Cards de status
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.success,
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                title: const Text('Backend Configurado'),
                subtitle: const Text('Node.js + Express + Prisma'),
                trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary),
              ),
            ),
            
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.success,
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                title: const Text('Frontend Configurado'),
                subtitle: const Text('Flutter + Design System'),
                trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary),
              ),
            ),
            
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.warning,
                  child: const Icon(Icons.build, color: Colors.white),
                ),
                title: const Text('Em Desenvolvimento'),
                subtitle: const Text('Implementando telas principais'),
                trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botão de ação
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Ver Minhas Tarefas',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento! 🚀'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                type: ButtonType.primary,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Adicionar tarefa - Em breve! ✨'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}