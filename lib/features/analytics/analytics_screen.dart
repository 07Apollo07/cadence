import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../history/run_detail_screen.dart';
import 'analytics_repository.dart';

enum AnalyticsFilter { allTime, last4Weeks, last7Days }

class AnalyticsFilterNotifier extends Notifier<AnalyticsFilter> {
  @override
  AnalyticsFilter build() => AnalyticsFilter.allTime;

  set filter(AnalyticsFilter value) => state = value;
}

final analyticsFilterProvider = NotifierProvider<AnalyticsFilterNotifier, AnalyticsFilter>(AnalyticsFilterNotifier.new);

final analyticsSummaryProvider = FutureProvider.autoDispose<AnalyticsSummary>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final filter = ref.watch(analyticsFilterProvider);
  final now = DateTime.now();

  DateTime start;
  switch (filter) {
    case AnalyticsFilter.last7Days:
      start = now.subtract(const Duration(days: 7));
      break;
    case AnalyticsFilter.last4Weeks:
      start = now.subtract(const Duration(days: 28));
      break;
    case AnalyticsFilter.allTime:
      start = DateTime(2000);
      break;
  }

  return repo.getSummaryInRange(start, now);
});

final priorAnalyticsSummaryProvider = FutureProvider.autoDispose<AnalyticsSummary>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final filter = ref.watch(analyticsFilterProvider);
  final now = DateTime.now();

  if (filter != AnalyticsFilter.last4Weeks) {
    // Return empty / zero for non-4week comparisons
    return AnalyticsSummary(totalDistanceKm: 0, totalMovingDurationSeconds: 0, totalActivities: 0, avgPaceMinPerKm: 0);
  }

  // Prior 4 weeks: 56 days ago to 28 days ago
  final start = now.subtract(const Duration(days: 56));
  final end = now.subtract(const Duration(days: 28));

  return repo.getSummaryInRange(start, end);
});

final allTimePrsProvider = FutureProvider.autoDispose<List<BestEffortRow>>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getAllTimePrs();
});

final analyticsSessionsProvider = FutureProvider.autoDispose<List<WorkoutSession>>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final filter = ref.watch(analyticsFilterProvider);
  final now = DateTime.now();

  DateTime start;
  switch (filter) {
    case AnalyticsFilter.last7Days:
      start = now.subtract(const Duration(days: 7));
      break;
    case AnalyticsFilter.last4Weeks:
      start = now.subtract(const Duration(days: 28));
      break;
    case AnalyticsFilter.allTime:
      start = DateTime(2000);
      break;
  }

  return repo.getSessionsInRange(start, now);
});

final missingAnalyticsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  final filter = ref.watch(analyticsFilterProvider);
  final now = DateTime.now();

  DateTime start;
  switch (filter) {
    case AnalyticsFilter.last7Days:
      start = now.subtract(const Duration(days: 7));
      break;
    case AnalyticsFilter.last4Weeks:
      start = now.subtract(const Duration(days: 28));
      break;
    case AnalyticsFilter.allTime:
      start = DateTime(2000);
      break;
  }

  return repo.getMissingAnalyticsCount(start, now);
});

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _isBackfilling = false;
  int _backfillCurrent = 0;
  int _backfillTotal = 0;

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatPace(double? paceMinPerKm) {
    if (paceMinPerKm == null || paceMinPerKm <= 0 || paceMinPerKm.isInfinite) return '--:--';
    final mins = paceMinPerKm.floor();
    final secs = ((paceMinPerKm - mins) * 60).round();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildBackfillBanner(int count) {
    if (count <= 0 && !_isBackfilling) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfacePanel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isBackfilling
                ? AppColors.traceCalm.withValues(alpha: 0.5)
                : AppColors.traceHot.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isBackfilling ? Icons.sync : Icons.info_outline,
                  color: _isBackfilling ? AppColors.traceCalm : AppColors.traceHot,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isBackfilling
                        ? 'Backfilling workout analytics...'
                        : '$count workouts missing analytics in this period.',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
                if (_isBackfilling)
                  Text(
                    _backfillTotal > 0
                        ? '$_backfillCurrent / $_backfillTotal'
                        : 'Initialising...',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrains Mono',
                    ),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.traceHot,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      final repo = ref.read(analyticsRepositoryProvider);
                      final filter = ref.read(analyticsFilterProvider);
                      final now = DateTime.now();
                      DateTime start;
                      switch (filter) {
                        case AnalyticsFilter.last7Days:
                          start = now.subtract(const Duration(days: 7));
                          break;
                        case AnalyticsFilter.last4Weeks:
                          start = now.subtract(const Duration(days: 28));
                          break;
                        case AnalyticsFilter.allTime:
                          start = DateTime(2000);
                          break;
                      }

                      setState(() {
                        _isBackfilling = true;
                        _backfillCurrent = 0;
                        _backfillTotal = 0;
                      });

                      try {
                        await repo.backfillMissingAnalytics(
                          start,
                          now,
                          onProgress: (processed, total) {
                            setState(() {
                              _backfillCurrent = processed;
                              _backfillTotal = total;
                            });
                          },
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            _isBackfilling = false;
                          });
                        }
                        ref.invalidate(missingAnalyticsCountProvider);
                        ref.invalidate(analyticsSummaryProvider);
                        ref.invalidate(allTimePrsProvider);
                        ref.invalidate(analyticsSessionsProvider);
                      }
                    },
                    child: const Text('Backfill', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            if (_isBackfilling && _backfillTotal > 0) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _backfillCurrent / _backfillTotal,
                  backgroundColor: AppColors.surfaceInset,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.traceCalm),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(analyticsFilterProvider);
    final summaryAsync = ref.watch(analyticsSummaryProvider);
    final priorSummaryAsync = ref.watch(priorAnalyticsSummaryProvider);
    final prsAsync = ref.watch(allTimePrsProvider);
    final sessionsAsync = ref.watch(analyticsSessionsProvider);
    final missingCountAsync = ref.watch(missingAnalyticsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar / Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                    // Filter Segment
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfacePanel,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.hairline),
                      ),
                      child: Row(
                        children: [
                          _buildFilterTab(ref, AnalyticsFilter.allTime, 'All Time', filter),
                          _buildFilterTab(ref, AnalyticsFilter.last4Weeks, '4 Wks', filter),
                          _buildFilterTab(ref, AnalyticsFilter.last7Days, '7 Days', filter),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Missing Analytics Backfill Banner
            SliverToBoxAdapter(
              child: missingCountAsync.when(
                data: (count) => _buildBackfillBanner(count),
                loading: () => _buildBackfillBanner(0),
                error: (_, _) => _buildBackfillBanner(0),
              ),
            ),

            // Summary Totals Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: summaryAsync.when(
                  data: (summary) => GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _buildSummaryCard(
                        'Total Distance',
                        summary.totalDistanceKm.toStringAsFixed(1),
                        'km',
                        AppColors.traceCalm,
                      ),
                      _buildSummaryCard(
                        'Moving Time',
                        _formatDuration(summary.totalMovingDurationSeconds),
                        '',
                        AppColors.textPrimary,
                      ),
                      _buildSummaryCard(
                        'Activities',
                        '${summary.totalActivities}',
                        'runs',
                        AppColors.traceHot,
                      ),
                      _buildSummaryCard(
                        'Avg Pace',
                        _formatPace(summary.avgPaceMinPerKm),
                        'min/km',
                        AppColors.textPrimary,
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(
                    height: 160,
                    child: Center(child: CircularProgressIndicator(color: AppColors.traceCalm)),
                  ),
                  error: (e, st) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading summary: $e', style: const TextStyle(color: AppColors.statusDanger)),
                  ),
                ),
              ),
            ),

            // 4-Week Comparison Panel (Visible when Last 4 Weeks selected)
            if (filter == AnalyticsFilter.last4Weeks)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfacePanel,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '4-WEEK COMPARISON',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        summaryAsync.when(
                          data: (curr) => priorSummaryAsync.when(
                            data: (prior) {
                              final currDistPerWk = curr.totalDistanceKm / 4.0;
                              final priorDistPerWk = prior.totalDistanceKm / 4.0;
                              final distDiff = currDistPerWk - priorDistPerWk;
                              return Column(
                                children: [
                                  _buildComparisonRow(
                                    'Weekly Distance',
                                    '${currDistPerWk.toStringAsFixed(1)} km',
                                    '${priorDistPerWk.toStringAsFixed(1)} km prior',
                                    distDiff >= 0 ? '+${distDiff.toStringAsFixed(1)} km' : '${distDiff.toStringAsFixed(1)} km',
                                    distDiff >= 0,
                                  ),
                                  const Divider(color: AppColors.hairline, height: 20),
                                  _buildComparisonRow(
                                    'Weekly Activities',
                                    (curr.totalActivities / 4.0).toStringAsFixed(1),
                                    '${(prior.totalActivities / 4.0).toStringAsFixed(1)} prior',
                                    '',
                                    true,
                                  ),
                                ],
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, _) => const SizedBox.shrink(),
                          ),
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // All-Time Personal Records (PRs) Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: const Text(
                  'ALL-TIME PERSONAL RECORDS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: prsAsync.when(
                  data: (prs) {
                    if (prs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfacePanel,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.hairline),
                        ),
                        child: const Center(
                          child: Text(
                            'No personal records yet. Complete GPS runs to set PRs!',
                            style: TextStyle(color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfacePanel,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.hairline),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: prs.length,
                        separatorBuilder: (_, _) => const Divider(color: AppColors.hairline, height: 1),
                        itemBuilder: (context, index) {
                          final pr = prs[index];
                          return ListTile(
                            title: Text(
                              pr.distanceBucket,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                fontFamily: 'JetBrains Mono',
                              ),
                            ),
                            trailing: Text(
                              _formatDuration(pr.bestDurationSeconds),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.traceCalm,
                                fontFamily: 'JetBrains Mono',
                              ),
                            ),
                            subtitle: Text(
                              'Set on ${pr.computedAt.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: AppColors.traceCalm)),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading PRs: $e', style: const TextStyle(color: AppColors.statusDanger)),
                  ),
                ),
              ),
            ),

            // Recent Sessions in Range
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: const Text(
                  'ACTIVITIES IN RANGE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ),
            ),
            sessionsAsync.when(
              data: (sessions) {
                if (sessions.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No GPS activities found for this filter period.', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final session = sessions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RunDetailScreen(session: session),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfacePanel,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.hairline),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceInset,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.directions_run, color: AppColors.traceCalm, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${session.distanceKm.toStringAsFixed(2)} km  •  ${_formatDuration(session.movingDurationSeconds)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                          fontFamily: 'JetBrains Mono',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        session.startTime.toLocal().toString().substring(0, 16),
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: sessions.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: AppColors.traceCalm)),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading sessions: $e', style: const TextStyle(color: AppColors.statusDanger)),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding for navigation bar
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(WidgetRef ref, AnalyticsFilter filterType, String label, AnalyticsFilter currentFilter) {
    final isSelected = filterType == currentFilter;
    return GestureDetector(
      onTap: () => ref.read(analyticsFilterProvider.notifier).filter = filterType,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String unit, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String currentVal, String priorVal, String diffStr, bool positive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textPrimary)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(currentVal, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'JetBrains Mono')),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(priorVal, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                if (diffStr.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    diffStr,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: positive ? AppColors.traceCalm : AppColors.statusDanger,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}
