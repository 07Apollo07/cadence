import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample workout history list for display demonstration
    final dummyWorkouts = [
      {'title': 'Metronome Run (180 SPM)', 'duration': '15:30', 'distance': '2.4 km', 'date': 'Today, 8:30 AM'},
      {'title': 'GPS Outdoor Run', 'duration': '32:10', 'distance': '5.2 km', 'date': 'Yesterday, 6:15 PM'},
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: const Text('Workout History'),
        backgroundColor: AppColors.surfacePanel,
      ),
      body: dummyWorkouts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history, size: 64, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text(
                    'No completed workouts yet.',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your saved metronome and GPS runs will appear here.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dummyWorkouts.length,
              itemBuilder: (context, index) {
                final workout = dummyWorkouts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfacePanel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_run, color: AppColors.traceCalm, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout['title']!,
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${workout['date']} • ${workout['duration']} • ${workout['distance']}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textMuted),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

