import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../../widgets/terms_text.dart';
import '../../widgets/safe_scaffold.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
  // Terms content provided by TermsText widget

      return SafeScaffold(
        appBar: AppBar(
        title: const Text('Termos e Privacidade'),
        backgroundColor: AppColors.primaryLight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TermsText(),
            ],
          ),
        ),
      ),
    );
  }
}
