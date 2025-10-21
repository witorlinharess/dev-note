import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import '../models/todo.dart';
import '../widgets/safe_scaffold.dart';

class CompletedTasksScreen extends StatelessWidget {
  final List<Todo> completedTodos;
  final void Function(Todo) onRestore; // restore to active
  final void Function(Todo) onDelete; // permanent delete
  final VoidCallback? onDeleteAll;

  const CompletedTasksScreen({
    super.key,
    required this.completedTodos,
    required this.onRestore,
    required this.onDelete,
    this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      appBar: AppBar(
        title: const Text('Tarefas concluídas'),
        backgroundColor: AppColors.primaryLight,
        elevation: 2,
        actions: [
          if (onDeleteAll != null)
            IconButton(
              tooltip: 'Excluir todas',
              icon: const Icon(Icons.delete_forever),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirmar'),
                    content: const Text('Deseja excluir todas as tarefas concluídas? Esta ação é irreversível.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                      ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Excluir')),
                    ],
                  ),
                );
                if (confirm == true) {
                  onDeleteAll!();
                }
              },
            ),
        ],
      ),
      body: completedTodos.isEmpty
          ? Center(
              child: Text(
                'Nenhuma tarefa concluída.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: completedTodos.length,
              itemBuilder: (ctx, i) {
                final todo = completedTodos[i];
                final timeLabel = '${todo.createdAt.hour.toString().padLeft(2, '0')}:${todo.createdAt.minute.toString().padLeft(2, '0')}';
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.check, size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(todo.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              if (todo.description != null && todo.description!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(todo.description!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(timeLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'restore') onRestore(todo);
                            if (v == 'delete') onDelete(todo);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'restore', child: Text('Restaurar')),
                            const PopupMenuItem(value: 'delete', child: Text('Excluir permanentemente')),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
