import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dev Note', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Versão 1.0.0', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Text('Descrição', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Dev Note é um aplicativo simples para gerenciar notas e tarefas. Desenvolvido para demonstração e uso local.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Text('Contato', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('support@devnote.example', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
