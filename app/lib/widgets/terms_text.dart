import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const terms = '''
Termos e Política de Privacidade

1. Introdução
Este documento descreve os termos e condições de uso do aplicativo.

2. Uso do Serviço
Ao utilizar o aplicativo, você concorda com os termos.

3. Privacidade
Descreva como os dados são coletados e usados.

4. Limitação de responsabilidade
...

5. Contato
Para dúvidas, entre em contato.
''';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Este aplicativo valoriza a sua privacidade. Abaixo está o texto completo de termos e políticas.',
          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 12),
        Text(terms, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.white)),
      ],
    );
  }
}
