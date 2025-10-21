import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';
import 'dart:io';
import '../utils/storage_helper.dart';
import '../models/todo.dart';
import 'completed_tasks_screen.dart';
import 'user_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _greeting = '';
  String _firstName = '';
  final List<Todo> _todos = [];
  final List<Todo> _completedTodos = [];
  String? _userPhotoPath;

  // simple id counter for demo todos
  int _todoCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadUserAndGreeting();
  }

  // image picker moved to user menu screen

  // user menu actions moved to `UserMenuScreen`

  Future<void> _loadUserAndGreeting() async {
    // load user to get first name and compute greeting
    final user = await StorageHelper.getUser();

    String name = '';
    if (user != null) {
      name = (user.name ?? user.username).trim();
    }

    String firstName = '';
    if (name.isNotEmpty) {
      firstName = name.split(' ').first;
    }

    final hour = DateTime.now().hour;
    final greeting = _computeGreeting(hour);

    if (!mounted) return;
    final photo = await StorageHelper.getUserPhotoPath();
    setState(() {
      _firstName = firstName;
      _greeting = greeting;
      _userPhotoPath = photo;
    });
  }

  void _addTodo(String title, String? description) {
    final now = DateTime.now();
    final todo = Todo(
      id: 'tmp_${_todoCounter++}',
      title: title,
      description: description,
      completed: false,
      priority: 'normal',
      dueDate: null,
      createdAt: now,
      updatedAt: now,
      userId: 'local',
    );

    setState(() => _todos.insert(0, todo));
  }

  void _toggleTodoCompleted(int index) {
    final t = _todos[index];
    final updated = t.copyWith(completed: !t.completed, updatedAt: DateTime.now());

    if (!t.completed && updated.completed) {
      // moving to completed
      setState(() {
        _todos.removeAt(index);
        _completedTodos.insert(0, updated);
      });

      // navigate automatically to completed tasks screen
      // small delay to allow UI update
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => CompletedTasksScreen(
          completedTodos: _completedTodos,
          onRestore: (todo) {
            // restore back to active
            setState(() {
              _completedTodos.removeWhere((t) => t.id == todo.id);
              _todos.insert(0, todo.copyWith(completed: false, updatedAt: DateTime.now()));
            });
            Navigator.of(context).pop();
          },
          onDelete: (todo) {
            setState(() {
              _completedTodos.removeWhere((t) => t.id == todo.id);
            });
            Navigator.of(context).pop();
          },
        )));
      });
    } else {
      // toggle within active list (or restoring from completed handled elsewhere)
      _todos[index] = updated;
      setState(() {});
    }
  }

  String _computeGreeting(int hour) {
    if (hour >= 5 && hour < 12) return 'Bom dia';
    if (hour >= 12 && hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        // Greeting placed flush to the very left using leading
        leadingWidth: 140,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
            child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              // show greeting with first name when available: 'Boa noite, João'
              _firstName.isNotEmpty ? '$_greeting, $_firstName' : _greeting,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
        ),
        // keep title minimal to avoid shifting the greeting
        title: const SizedBox.shrink(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserMenuScreen()));
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white24,
                backgroundImage: _userPhotoPath != null ? FileImage(File(_userPhotoPath!)) : null,
                child: _userPhotoPath == null ? const Icon(Icons.person, color: Colors.white) : null,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Todo list
          if (_todos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Nenhuma tarefa ainda. Crie a primeira usando o botão +',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            )
          else
            ..._todos.asMap().entries.map((entry) {
              final idx = entry.key;
              final todo = entry.value;
              return _buildTodoCard(idx, todo);
            }),

          const SizedBox(height: 24),

          // Seção de status (mantida abaixo da lista)
          
          const SizedBox(height: 16),

          // status cards removed (per request)
          const SizedBox(height: 32),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // open a simple dialog to create a todo
            final result = await showDialog<Map<String, String?>>(context: context, builder: (ctx) {
              final titleCtrl = TextEditingController();
              final descCtrl = TextEditingController();
              // compute available width minus inset padding (16 left + 16 right)
              final dialogWidth = MediaQuery.of(ctx).size.width - 32.0;
              return AlertDialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                title: const Text('Nova tarefa'),
                content: SizedBox(
                  width: dialogWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(hintText: 'Título'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descCtrl,
                        decoration: const InputDecoration(hintText: 'Descrição'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                  ElevatedButton(onPressed: () {
                    Navigator.of(context).pop({'title': titleCtrl.text.trim(), 'desc': descCtrl.text.trim()});
                  }, child: const Text('Criar')),
                ],
              );
            });

          if (result != null && (result['title']?.isNotEmpty ?? false)) {
            _addTodo(result['title']!, result['desc']);
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodoCard(int index, Todo todo) {
    final timeLabel = '${todo.createdAt.hour.toString().padLeft(2, '0')}:${todo.createdAt.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => _editTodo(index),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // rounded square check
              GestureDetector(
                onTap: () => _toggleTodoCompleted(index),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: todo.completed ? AppColors.success : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: todo.completed ? AppColors.success : AppColors.textSecondary),
                  ),
                  child: todo.completed ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                ),
              ),

              const SizedBox(width: 12),

              // title + description
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

              // created time
              Text(timeLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editTodo(int index) async {
    final todo = _todos[index];
    final titleCtrl = TextEditingController(text: todo.title);
    final descCtrl = TextEditingController(text: todo.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dialogWidth = MediaQuery.of(ctx).size.width - 32.0;
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          title: const Text('Editar tarefa'),
          content: SizedBox(
            width: dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(hintText: 'Título'),
                  keyboardType: TextInputType.text,
                  autocorrect: true,
                  enableSuggestions: true,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(hintText: 'Descrição'),
                  keyboardType: TextInputType.multiline,
                  autocorrect: true,
                  enableSuggestions: true,
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                // ask for confirmation before deleting
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (innerCtx) {
                    final innerWidth = MediaQuery.of(innerCtx).size.width - 32.0;
                    return AlertDialog(
                      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      title: const Text('Confirmar exclusão'),
                      content: SizedBox(width: innerWidth, child: const Text('Tem certeza que deseja excluir esta tarefa?')),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(innerCtx).pop(false), child: const Text('Cancelar')),
                        ElevatedButton(onPressed: () => Navigator.of(innerCtx).pop(true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Excluir')),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  // delete and close edit dialog
                  if (mounted) {
                    setState(() {
                      _todos.removeAt(index);
                    });
                    Navigator.of(context).pop(false);
                  }
                }
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(onPressed: () {
              Navigator.of(context).pop(true);
            }, child: const Text('Salvar')),
          ],
        );
      }
    );

    if (result == true) {
      final newTitle = titleCtrl.text.trim();
      final newDesc = descCtrl.text.trim();
      if (newTitle.isNotEmpty) {
        _todos[index] = _todos[index].copyWith(
          title: newTitle,
          description: newDesc.isEmpty ? null : newDesc,
          updatedAt: DateTime.now(),
        );
        setState(() {});
      } else {
        // if title cleared, ignore save (or you could delete) — keep current
      }
    }
  }
}
