import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import '../widgets/safe_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                    'Sobre',
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
            child: Divider(height: 0.1, thickness: 0.1, color: AppColors.dividerColor),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dev Note', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
            const SizedBox(height: 8),
            Text('Versão 1.0.0', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryLight)),
            const SizedBox(height: 16),
            Text('Descrição', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryLight)),
            const SizedBox(height: 8),
            Text('Dev Note é um aplicativo simples para gerenciar notas e tarefas. Desenvolvido para demonstração e uso local.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryLight)),
            const SizedBox(height: 24),
            Text('Contato', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryLight)),
            const SizedBox(height: 8),
            Text('support@devnote.example', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryLight)),
          ],
        ),
      ),
    );
  }
}
