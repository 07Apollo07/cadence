import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/cadence_provider.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    final height = ref.read(cadenceProvider).userHeightCm;
    _heightController = TextEditingController(text: height.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _heightController.dispose();
    super.dispose();
  }

  void _showPrefillModal(double heightCm) {
    final state = ref.read(cadenceProvider);
    final curWalk = state.walkStride;
    final curJog = state.jogStride;
    final curRun = state.runStride;

    final propWalk = double.parse((heightCm * 0.415 / 100).toStringAsFixed(2));
    final propJog = double.parse((heightCm * 0.55 / 100).toStringAsFixed(2));
    final propRun = double.parse((heightCm * 0.65 / 100).toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfacePanel,
        title: const Text('Prefill Strides from Height', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Height: ${heightCm.toStringAsFixed(0)} cm', style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            const Text('Proposed Stride Overwrites:', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildComparisonRow('Walking', curWalk, propWalk),
            const SizedBox(height: 8),
            _buildComparisonRow('Jogging', curJog, propJog),
            const SizedBox(height: 8),
            _buildComparisonRow('Running', curRun, propRun),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.traceCalm),
            onPressed: () {
              ref.read(cadenceProvider.notifier).prefillStridesFromHeight(heightCm);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Strides updated successfully from height!')),
              );
            },
            child: const Text('Apply Prefill', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String mode, double current, double proposed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(mode, style: const TextStyle(color: AppColors.textPrimary)),
        Text('${current.toStringAsFixed(2)}m ➔ ${proposed.toStringAsFixed(2)}m', style: const TextStyle(color: AppColors.traceCalm, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showColorPicker(MovementMode mode, Color currentColor) {
    final colors = [
      Colors.green,
      Colors.lightGreen,
      Colors.amber,
      Colors.yellow,
      Colors.orange,
      Colors.deepOrange,
      Colors.red,
      Colors.teal,
      Colors.cyan,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfacePanel,
        title: Text('Pick Color for ${mode.name.toUpperCase()}', style: const TextStyle(color: AppColors.textPrimary)),
        content: SizedBox(
          width: 300,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: colors.map((c) {
              return GestureDetector(
                onTap: () {
                  ref.read(cadenceProvider.notifier).setModeColor(mode, c);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentColor == c ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cadenceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SETTINGS',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Height & Prefill Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfacePanel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Height Estimation',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter height to estimate and prefill stride lengths for walking, jogging, and running.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Height (cm)',
                          labelStyle: const TextStyle(color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surfaceRaised,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.hairline),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.traceCalm,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        final h = double.tryParse(_heightController.text) ?? 175.0;
                        _showPrefillModal(h);
                      },
                      child: const Text('Prefill Strides', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Stride & Color Cards for Walking, Jogging, Running
          _buildStrideCard(
            context,
            ref,
            'Walking Stride & Color',
            MovementMode.walking,
            state.walkStride,
            state.walkColor,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildStrideCard(
            context,
            ref,
            'Jogging Stride & Color',
            MovementMode.jogging,
            state.jogStride,
            state.jogColor,
            Colors.amber,
          ),
          const SizedBox(height: 16),
          _buildStrideCard(
            context,
            ref,
            'Running Stride & Color',
            MovementMode.running,
            state.runStride,
            state.runColor,
            Colors.deepOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildStrideCard(
    BuildContext context,
    WidgetRef ref,
    String title,
    MovementMode mode,
    double stride,
    Color color,
    Color defaultColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => _showColorPicker(mode, color),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Color', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: stride,
                  min: 0.4,
                  max: 2.5,
                  divisions: 42,
                  activeColor: color,
                  inactiveColor: AppColors.surfaceRaised,
                  onChanged: (val) {
                    ref.read(cadenceProvider.notifier).setModeStride(mode, val);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Text(
                  '${stride.toStringAsFixed(2)} m',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
