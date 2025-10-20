import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

class TodoCard extends StatelessWidget {
  final String id;
  final String title;
  final String? description;
  final bool completed;
  final String priority;
  final DateTime? dueDate;
  final List<String> tags;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TodoCard({
    Key? key,
    required this.id,
    required this.title,
    this.description,
    required this.completed,
    required this.priority,
    this.dueDate,
    this.tags = const [],
    this.onTap,
    this.onToggleComplete,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onToggleComplete,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: completed ? _getPriorityColor() : AppColors.border,
                          width: 2,
                        ),
                        color: completed ? _getPriorityColor() : Colors.transparent,
                      ),
                      child: completed
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: completed ? AppColors.textTertiary : AppColors.textPrimary,
                        decoration: completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPriorityText(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getPriorityColor(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(
                      Icons.more_vert,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: completed ? AppColors.textTertiary : AppColors.textSecondary,
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (dueDate != null || tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (dueDate != null) ...[
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: _getDueDateColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDueDate(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getDueDateColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (tags.isNotEmpty) const SizedBox(width: 12),
                    ],
                    if (tags.isNotEmpty)
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: tags.take(3).map((tag) => _buildTag(tag)).toList(),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'low':
        return AppColors.priorityLow;
      case 'medium':
        return AppColors.priorityMedium;
      case 'high':
        return AppColors.priorityHigh;
      case 'urgent':
        return AppColors.priorityUrgent;
      default:
        return AppColors.priorityMedium;
    }
  }

  String _getPriorityText() {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Baixa';
      case 'medium':
        return 'Média';
      case 'high':
        return 'Alta';
      case 'urgent':
        return 'Urgente';
      default:
        return 'Média';
    }
  }

  Color _getDueDateColor() {
    if (dueDate == null) return AppColors.textTertiary;
    
    final now = DateTime.now();
    final difference = dueDate!.difference(now).inDays;
    
    if (difference < 0) return AppColors.error; // Vencido
    if (difference == 0) return AppColors.warning; // Hoje
    if (difference == 1) return AppColors.warning; // Amanhã
    return AppColors.textTertiary; // Normal
  }

  String _formatDueDate() {
    if (dueDate == null) return '';
    
    final now = DateTime.now();
    final difference = dueDate!.difference(now).inDays;
    
    if (difference < 0) return 'Vencido';
    if (difference == 0) return 'Hoje';
    if (difference == 1) return 'Amanhã';
    
    return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
  }
}