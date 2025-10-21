import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:design_system/design_system.dart';
import 'dart:math' as math;

import '../models/todo.dart';
import '../utils/storage_helper.dart';
import '../widgets/safe_scaffold.dart';
import 'user_menu_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _index = 0;
  String _greeting = '';
  String _firstName = '';
  String? _userPhotoPath;
  // User? _user; // Removed unused field

  final List<Todo> _todos = [];
  final List<Todo> _completedTodos = [];

  // simple id counter for demo todos
  int _todoCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadUserAndGreeting();
  }

  Future<void> _loadUserAndGreeting() async {
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

  String _computeGreeting(int hour) {
    if (hour >= 5 && hour < 12) return 'Bom dia';
    if (hour >= 12 && hour < 18) return 'Boa tarde';
    return 'Boa noite';
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
      setState(() {
        _todos.removeAt(index);
        _completedTodos.insert(0, updated);
      });
    } else {
      _todos[index] = updated;
      setState(() {});
    }
  }

  void _restoreFromCompleted(Todo todo) {
    setState(() {
      _completedTodos.removeWhere((t) => t.id == todo.id);
      _todos.insert(0, todo.copyWith(completed: false, updatedAt: DateTime.now()));
    });
  }

  void _deleteCompleted(Todo todo) {
    setState(() {
      _completedTodos.removeWhere((t) => t.id == todo.id);
    });
  }

  void _editTodo(int index, String title, String? desc) {
    final t = _todos[index];
    setState(() {
      _todos[index] = t.copyWith(title: title, description: desc, updatedAt: DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeTab(
        todos: _todos,
        onAdd: _addTodo,
        onToggle: _toggleTodoCompleted,
        onEdit: _editTodo,
      ),
      CompletedTab(
        completedTodos: _completedTodos,
        onRestore: _restoreFromCompleted,
        onDelete: _deleteCompleted,
        onDeleteAll: () {
          setState(() {
            _completedTodos.clear();
          });
        },
      ),
      const PomodoroTab(),
      const RemindersTab(),
    ];

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
                    _firstName.isNotEmpty ? '$_greeting, $_firstName' : _greeting,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserMenuScreen()));
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.inputColor,
                  backgroundImage: _userPhotoPath != null ? FileImage(File(_userPhotoPath!)) : null,
                  child: _userPhotoPath == null ? const Icon(Icons.person, color: Colors.white) : null,
                ),
              ),
            ],
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.0),
            child: Divider(height: 0.2, thickness: 0.2, color: AppColors.dividerColor),
          ),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Concluídas'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Pomodoro'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Lembretes'),
        ],
  selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () async {
                final result = await showDialog<Map<String, String?>>(context: context, builder: (ctx) {
                  final titleCtrl = TextEditingController();
                  final descCtrl = TextEditingController();
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
                          TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'Título')),
                          const SizedBox(height: 8),
                          TextField(controller: descCtrl, decoration: const InputDecoration(hintText: 'Descrição')),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                      ElevatedButton(onPressed: () => Navigator.of(context).pop({'title': titleCtrl.text.trim(), 'desc': descCtrl.text.trim()}), child: const Text('Criar')),
                    ],
                  );
                });

                if (result != null && (result['title']?.isNotEmpty ?? false)) {
                  _addTodo(result['title']!, result['desc']);
                }
              },
              backgroundColor: AppColors.primaryLight,
              child: const Icon(Icons.add, color: AppColors.primaryDark),
            )
          : null,
    );
  }
}

class HomeTab extends StatelessWidget {
  final List<Todo> todos;
  final void Function(String, String?) onAdd;
  final void Function(int) onToggle;
  final void Function(int, String, String?) onEdit;

  const HomeTab({super.key, required this.todos, required this.onAdd, required this.onToggle, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (todos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 320.0),
            child: Text(
              'Nenhuma tarefa ainda. Crie a primeira usando o botão +',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color.fromARGB(255, 143, 143, 143)),
            ),
          )
        else
          ...todos.asMap().entries.map((entry) {
            final idx = entry.key;
            final todo = entry.value;
            return _buildTodoCard(context, idx, todo);
          }),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTodoCard(BuildContext context, int index, Todo todo) {
    final timeLabel = '${todo.createdAt.hour.toString().padLeft(2, '0')}:${todo.createdAt.minute.toString().padLeft(2, '0')}';
    return GestureDetector(
      onTap: () async {
        final titleCtrl = TextEditingController(text: todo.title);
        final descCtrl = TextEditingController(text: todo.description ?? '');
        final res = await showDialog<bool>(context: context, builder: (ctx) {
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
                  TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'Título')),
                  const SizedBox(height: 8),
                  TextField(controller: descCtrl, decoration: const InputDecoration(hintText: 'Descrição'), maxLines: 4),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
              ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Salvar')),
            ],
          );
        });

        if (res == true) {
          onEdit(index, titleCtrl.text.trim(), descCtrl.text.trim());
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => onToggle(index),
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
            ],
          ),
        ),
      ),
    );
  }
}

class CompletedTab extends StatelessWidget {
  final List<Todo> completedTodos;
  final void Function(Todo) onRestore;
  final void Function(Todo) onDelete;
  final VoidCallback? onDeleteAll;

  const CompletedTab({super.key, required this.completedTodos, required this.onRestore, required this.onDelete, this.onDeleteAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tarefas concluídas', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryLight)),
              if (completedTodos.isNotEmpty)
                TextButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Excluir todas'),
                        content: const Text('Deseja realmente excluir todas as tarefas concluídas? Esta ação não pode ser desfeita.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
                          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Excluir')),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      onDeleteAll?.call();
                    }
                  },
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text('Excluir todas', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: completedTodos.isEmpty
                ? Center(child: Text('Nenhuma tarefa concluída.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8.0),
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
          ),
        ],
      ),
    );
  }
}

class PomodoroTab extends StatefulWidget {
  const PomodoroTab({super.key});

  @override
  State<PomodoroTab> createState() => _PomodoroTabState();
}

class _PomodoroTabState extends State<PomodoroTab> {
  static const int defaultSeconds = 25 * 60;
  int _seconds = defaultSeconds;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    // _ticker = null; // Removed unused field
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _start() {
    if (_running) return;
    setState(() => _running = true);
    // simple timer using periodic
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (!_running) return false;
      if (_seconds > 0) {
        setState(() => _seconds -= 1);
        return true;
      }
      setState(() => _running = false);
      return false;
    });
  }

  void _pause() {
    setState(() => _running = false);
  }

  void _reset() {
    setState(() {
      _running = false;
      _seconds = defaultSeconds;
    });
  }

  String _format(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final total = defaultSeconds;
    final progress = 1.0 - (_seconds / total);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // circular progress with time in center (responsive diameter)
            LayoutBuilder(builder: (ctx, constraints) {
              final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.of(context).size.width;
              // allow a much larger ring; inner size reduced proportionally
              // allow a much larger ring; inner size adjusted to create a visible ring
              // slightly smaller ring: reduce multiplier and upper clamp
              final diameter = (maxWidth * 0.92).clamp(320.0, 760.0);
              final innerSize = diameter * 0.48; // space for the timer text inside the ring

              return SizedBox(
                width: diameter,
                height: diameter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // drawing the ring and elapsed arc using CustomPaint
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: diameter,
                          height: diameter,
                          child: CustomPaint(
                            painter: PomodoroPainter(
                              progress: progress.clamp(0.0, 1.0),
                              ringColor: AppColors.primaryLight,
                              accentColor: AppColors.success, // pink accent
                              strokeWidth: math.max(6.0, diameter * 0.025),
                              backgroundOpacity: 0.12,
                            ),
                            child: Center(
                              // inner circular hole simulated by background color of scaffold
                              child: SizedBox(
                                width: innerSize,
                                height: innerSize,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // big number (always shown)
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(_format(_seconds), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 220, color: AppColors.primaryLight)),
                                      ),
                                      const SizedBox(height: 8),
                                      // small status text under the number
                                      Builder(builder: (_) {
                                        final atDefault = _seconds == _PomodoroTabState.defaultSeconds;
                                        if (!_running && atDefault) {
                                          return const Text('Iniciar', style: TextStyle(fontSize: 18, color: AppColors.primaryLight, fontWeight: FontWeight.w600));
                                        }
                                        if (!_running && !atDefault) {
                                          return const Text('Pausado', style: TextStyle(fontSize: 18, color: AppColors.primaryLight, fontWeight: FontWeight.w600));
                                        }
                                        return const Text('Em andamento', style: TextStyle(fontSize: 18, color: AppColors.primaryLight, fontWeight: FontWeight.w600));
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    // status label moved below (kept for accessibility)
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryLight, foregroundColor: AppColors.primaryDark),
                  onPressed: _running ? _pause : _start,
                  child: Builder(builder: (_) {
                    final atDefault = _seconds == _PomodoroTabState.defaultSeconds;
                    if (_running) return const Text('Pausar');
                    return Text(atDefault ? 'Iniciar' : 'Continuar');
                  }),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _reset,
                  style: TextButton.styleFrom(foregroundColor: AppColors.priorityHigh),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RemindersTab extends StatefulWidget {
  const RemindersTab({super.key});

  @override
  State<RemindersTab> createState() => _RemindersTabState();
}

// Painter used to draw a thick outer ring and an accent arc showing elapsed portion
class PomodoroPainter extends CustomPainter {
  final double progress; // 0.0..1.0
  final Color ringColor;
  final Color accentColor;
  final double strokeWidth;
  final double backgroundOpacity;

  PomodoroPainter({required this.progress, required this.ringColor, required this.accentColor, required this.strokeWidth, this.backgroundOpacity = 0.12});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final basePaint = Paint()
      ..color = ringColor.withOpacity(1.0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // background ring (faded)
    final bgPaint = Paint()
      ..color = ringColor.withOpacity(backgroundOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // full ring as base (drawn with full color to match design)
    canvas.drawCircle(center, radius, basePaint);

    // elapsed arc (small pink arc near top-right in example)
    final sweep = (progress.clamp(0.0, 1.0)) * 2 * math.pi;
    final startAngle = -math.pi / 2; // start at top

    final arcPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (sweep > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PomodoroPainter old) {
    return old.progress != progress || old.ringColor != ringColor || old.accentColor != accentColor || old.strokeWidth != strokeWidth;
  }
}

class _ReminderItem {
  final String id;
  final String title;
  final String? description;
  final DateTime? dateTime;

  _ReminderItem({required this.id, required this.title, this.description, this.dateTime});
}

class _RemindersTabState extends State<RemindersTab> {
  // keep raw dynamic list to be tolerant to hot-reload or older serialized formats
  final List<dynamic> _items = [];

  void _addReminder(dynamic item) {
    setState(() => _items.insert(0, item));
    try {
      // schedule notification 5 minutes before if dateTime available
      final _ReminderItem ri = item is _ReminderItem
          ? item
          : (item is Map
              ? _ReminderItem(id: item['id']?.toString() ?? 'r', title: item['title']?.toString() ?? '', description: item['description']?.toString(), dateTime: item['dateTime'] is DateTime ? item['dateTime'] as DateTime : (item['when'] != null ? DateTime.tryParse(item['when']) : null))
              : _ReminderItem(id: 'r', title: item.toString()));

      if (ri.dateTime != null) {
        final scheduled = ri.dateTime!.subtract(const Duration(minutes: 5));
        // compute an integer id for the notification
        final nid = ri.id.hashCode & 0x7fffffff;
        NotificationHelper.scheduleNotification(id: nid, title: ri.title, body: ri.description ?? 'Lembrete', dateTime: scheduled, payload: ri.id);
      }
    } catch (_) {}
  }

  void _removeReminder(String id) {
    setState(() => _items.removeWhere((r) {
          try {
            if (r is _ReminderItem) return r.id == id;
            if (r is Map) return (r['id'] ?? r['title']) == id;
          } catch (_) {}
          return false;
        }));
    try {
      final nid = id.hashCode & 0x7fffffff;
      NotificationHelper.cancel(nid);
    } catch (_) {}
  }

  Future<void> _showAddDialog() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime? pickedDate;
    TimeOfDay? pickedTime;

    await showDialog<bool>(context: context, builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setStateDialog) {
        String dateLabel() {
          if (pickedDate == null) return 'Escolher data';
          return '${pickedDate!.day.toString().padLeft(2, '0')}/${pickedDate!.month.toString().padLeft(2, '0')}/${pickedDate!.year}';
        }

        String timeLabel() {
          if (pickedTime == null) return 'Escolher hora';
          return pickedTime!.format(ctx);
        }

        return AlertDialog(
          title: const Text('Novo lembrete'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(hintText: 'Título')),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(hintText: 'Descrição'), maxLines: 3),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          final d = await showDatePicker(context: ctx, initialDate: now, firstDate: DateTime(now.year - 2), lastDate: DateTime(now.year + 5));
                          if (d != null) setStateDialog(() => pickedDate = d);
                        },
                        child: Text(dateLabel()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                          if (t != null) setStateDialog(() => pickedTime = t);
                        },
                        child: Text(timeLabel()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return; // keep dialog open
                DateTime? dt;
                if (pickedDate != null) {
                  if (pickedTime != null) {
                    dt = DateTime(pickedDate!.year, pickedDate!.month, pickedDate!.day, pickedTime!.hour, pickedTime!.minute);
                  } else {
                    dt = DateTime(pickedDate!.year, pickedDate!.month, pickedDate!.day);
                  }
                }
                final item = _ReminderItem(id: 'r_${DateTime.now().millisecondsSinceEpoch}', title: titleCtrl.text.trim(), description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(), dateTime: dt);
                Navigator.of(ctx).pop(true);
                _addReminder(item);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      });
    });

    // no-op: item already added inside dialog's onPressed
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: _items.isEmpty
                ? Center(child: Text('Nenhum lembrete. Toque em "Adicionar lembrete" para criar um.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (ctx, i) {
                      final raw = _items[i];
                      // convert raw entry (either _ReminderItem or old Map<String,String>) to _ReminderItem
                      _ReminderItem it;
                      if (raw is _ReminderItem) {
                        it = raw;
                      } else if (raw is Map) {
                        // old format used keys 'title' and 'when'
                        final title = (raw['title'] ?? '') as String;
                        final when = (raw['when'] ?? '') as String;
                        DateTime? dt;
                        try {
                          dt = DateTime.tryParse(when);
                        } catch (_) {
                          dt = null;
                        }
                        it = _ReminderItem(id: raw['id']?.toString() ?? 'r_${i}', title: title, description: when.isNotEmpty ? when : null, dateTime: dt);
                      } else {
                        // fallback
                        it = _ReminderItem(id: 'r_${i}', title: raw.toString());
                      }

                      final dateLabel = it.dateTime != null ? '${it.dateTime!.day.toString().padLeft(2, '0')}/${it.dateTime!.month.toString().padLeft(2, '0')}/${it.dateTime!.year} ${it.dateTime!.hour.toString().padLeft(2, '0')}:${it.dateTime!.minute.toString().padLeft(2, '0')}' : '';
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(it.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (it.description != null && it.description!.isNotEmpty) Text(it.description!),
                              if (dateLabel.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(dateLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.redAccent,
                            onPressed: () => _removeReminder(it.id),
                            tooltip: 'Remover',
                          ),
                        ),
                      );
                    },
                  ),
          ),
          ElevatedButton(
            onPressed: _showAddDialog,
            child: const Text('Adicionar lembrete'),
          ),
        ],
      ),
    );
  }
}
