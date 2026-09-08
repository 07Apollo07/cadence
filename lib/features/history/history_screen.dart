import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/app_database.dart';
import '../../core/theme/app_colors.dart';
import 'repositories/gps_session_repository.dart';
import 'run_detail_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int? _selectedDayFilter; // null means all days in month
  final Set<int> _selectedSessionIds = {};

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      _selectedDayFilter = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      _selectedDayFilter = null;
    });
  }

  String _monthYearString(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteSelectedSessions(BuildContext context) async {
    final count = _selectedSessionIds.length;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfacePanel,
        title: const Text('Delete Runs', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete $count selected run(s)? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.statusDanger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(gpsSessionRepositoryProvider);
      final idsToDelete = List<int>.from(_selectedSessionIds);
      for (final id in idsToDelete) {
        await repo.deleteSession(id);
      }
      setState(() {
        _selectedSessionIds.clear();
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted $count run(s)')),
        );
      }
    }
  }

  Future<bool> _confirmSingleDelete(BuildContext context, WorkoutSession session) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfacePanel,
        title: const Text('Delete Run', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete this run (${session.distanceKm.toStringAsFixed(2)} km)? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.statusDanger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(allGpsSessionsProvider);

    return sessionsAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.surfaceBase,
        appBar: AppBar(
          title: const Text('Workout History (GPS Runs)'),
          backgroundColor: AppColors.surfacePanel,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        backgroundColor: AppColors.surfaceBase,
        appBar: AppBar(
          title: const Text('Workout History (GPS Runs)'),
          backgroundColor: AppColors.surfacePanel,
        ),
        body: Center(child: Text('Error loading history: $e', style: const TextStyle(color: AppColors.statusDanger))),
      ),
      data: (sessions) {
        // Filter sessions for selected month
        final monthSessions = sessions.where((s) {
          return s.startTime.year == _selectedMonth.year && s.startTime.month == _selectedMonth.month;
        }).toList();

        // Map day -> count of sessions
        final Map<int, int> dayCounts = {};
        for (var s in monthSessions) {
          dayCounts[s.startTime.day] = (dayCounts[s.startTime.day] ?? 0) + 1;
        }

        // Filter by selected day if set
        final displayedSessions = _selectedDayFilter == null
            ? monthSessions
            : monthSessions.where((s) => s.startTime.day == _selectedDayFilter).toList();

        // Calculate monthly stats
        double totalDistance = monthSessions.fold(0.0, (sum, s) => sum + s.distanceKm);
        int totalMovingSec = monthSessions.fold(0, (sum, s) => sum + s.movingDurationSeconds);

        final isSelectionMode = _selectedSessionIds.isNotEmpty;

        return Scaffold(
          backgroundColor: AppColors.surfaceBase,
          appBar: AppBar(
            backgroundColor: AppColors.surfacePanel,
            leading: isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                    onPressed: () => setState(() => _selectedSessionIds.clear()),
                  )
                : null,
            title: Text(
              isSelectionMode
                  ? '${_selectedSessionIds.length} Selected'
                  : 'Workout History (GPS Runs)',
            ),
            actions: isSelectionMode
                ? [
                    IconButton(
                      icon: Icon(
                        _selectedSessionIds.length == displayedSessions.length
                            ? Icons.deselect
                            : Icons.select_all,
                        color: AppColors.textPrimary,
                      ),
                      tooltip: _selectedSessionIds.length == displayedSessions.length
                          ? 'Deselect All'
                          : 'Select All',
                      onPressed: () {
                        setState(() {
                          if (_selectedSessionIds.length == displayedSessions.length) {
                            _selectedSessionIds.clear();
                          } else {
                            _selectedSessionIds.addAll(displayedSessions.map((s) => s.id));
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.statusDanger),
                      tooltip: 'Delete Selected',
                      onPressed: () => _deleteSelectedSessions(context),
                    ),
                  ]
                : null,
          ),
          body: Column(
            children: [
              // Month Switcher Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.surfacePanel,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                      onPressed: _previousMonth,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
                          _selectedDayFilter = null;
                        });
                      },
                      child: Text(
                        _monthYearString(_selectedMonth),
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),

              // Calendar Grid View for the Month
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                color: AppColors.surfacePanel,
                child: Column(
                  children: [
                    // Weekday headers
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('S', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        Text('M', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        Text('T', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        Text('W', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        Text('T', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        Text('F', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        Text('S', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildCalendarGrid(dayCounts),
                  ],
                ),
              ),

              // Summary bar for month
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.surfaceRaised,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('Month Runs', '${monthSessions.length}'),
                    _buildSummaryItem('Total Distance', '${totalDistance.toStringAsFixed(2)} km'),
                    _buildSummaryItem('Moving Time', _formatDuration(totalMovingSec)),
                  ],
                ),
              ),

              if (_selectedDayFilter != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.surfacePanel,
                  child: Row(
                    children: [
                      Text('Showing runs for day: ${_selectedMonth.month}/$_selectedDayFilter/${_selectedMonth.year}', style: const TextStyle(color: AppColors.traceCalm, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setState(() => _selectedDayFilter = null),
                        child: const Text('Show All Month', style: TextStyle(color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                ),

              // Workout Sessions List
              Expanded(
                child: displayedSessions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.directions_run, size: 54, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text('No GPS runs recorded for this period.', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 84),
                        itemCount: displayedSessions.length,
                        itemBuilder: (context, index) {
                          final session = displayedSessions[index];
                          final isSelected = _selectedSessionIds.contains(session.id);

                          return Dismissible(
                            key: ValueKey(session.id),
                            direction: isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
                            confirmDismiss: (dir) => _confirmSingleDelete(context, session),
                            onDismissed: (dir) async {
                              final repo = ref.read(gpsSessionRepositoryProvider);
                              await repo.deleteSession(session.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Run deleted')),
                                );
                              }
                            },
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: AppColors.statusDanger.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.delete, color: Colors.white),
                                ],
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                if (isSelectionMode) {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedSessionIds.remove(session.id);
                                    } else {
                                      _selectedSessionIds.add(session.id);
                                    }
                                  });
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => RunDetailScreen(session: session)),
                                  );
                                }
                              },
                              onLongPress: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedSessionIds.remove(session.id);
                                  } else {
                                    _selectedSessionIds.add(session.id);
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.traceCalm.withValues(alpha: 0.15)
                                      : AppColors.surfacePanel,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? AppColors.traceCalm : AppColors.hairline,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (isSelectionMode)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Icon(
                                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                          color: isSelected ? AppColors.traceCalm : AppColors.textMuted,
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                          color: AppColors.surfaceRaised,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.directions_run, color: AppColors.traceCalm, size: 24),
                                      ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'GPS Run • ${session.distanceKm.toStringAsFixed(2)} km',
                                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                '${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}',
                                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Moving: ${_formatDuration(session.movingDurationSeconds)} • Total: ${_formatDuration(session.durationSeconds)}',
                                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Pace: ${session.avgPaceMinPerKm?.toStringAsFixed(1) ?? '--'} /km • Cadence: ${session.avgCadence.toStringAsFixed(0)} SPM',
                                            style: const TextStyle(color: AppColors.traceCalm, fontSize: 11, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarGrid(Map<int, int> dayCounts) {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    List<Widget> dayWidgets = [];

    // Blank cells before first day
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Days of month
    for (int day = 1; day <= daysInMonth; day++) {
      final hasRuns = dayCounts.containsKey(day);
      final count = dayCounts[day] ?? 0;
      final isSelected = _selectedDayFilter == day;

      dayWidgets.add(
        InkWell(
          onTap: () {
            setState(() {
              if (_selectedDayFilter == day) {
                _selectedDayFilter = null;
              } else {
                _selectedDayFilter = day;
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.traceCalm
                  : (hasRuns ? AppColors.surfaceRaised : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: hasRuns && !isSelected ? Border.all(color: AppColors.traceCalm.withValues(alpha: 0.5)) : null,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.black : (hasRuns ? AppColors.textPrimary : AppColors.textMuted),
                    fontWeight: hasRuns || isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                if (hasRuns) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black.withValues(alpha: 0.2) : AppColors.traceCalm,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 1.2,
      children: dayWidgets,
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

