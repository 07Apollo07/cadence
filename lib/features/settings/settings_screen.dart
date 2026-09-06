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
  late FocusNode _heightFocusNode;

  @override
  void initState() {
    super.initState();
    final height = ref.read(cadenceProvider).userHeightCm;
    _heightController = TextEditingController(text: height.toStringAsFixed(0));
    _heightFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _heightFocusNode.dispose();
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
        title: const Text(
          'Prefill Strides from Height',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Height: ${heightCm.toStringAsFixed(0)} cm',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            const Text(
              'Proposed Stride Overwrites:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.traceCalm,
            ),
            onPressed: () {
              ref
                  .read(cadenceProvider.notifier)
                  .prefillStridesFromHeight(heightCm);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Strides updated successfully from height!'),
                ),
              );
            },
            child: const Text(
              'Apply Prefill',
              style: TextStyle(color: Colors.black),
            ),
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
        Text(
          '${current.toStringAsFixed(2)}m ➔ ${proposed.toStringAsFixed(2)}m',
          style: const TextStyle(
            color: AppColors.traceCalm,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        title: Text(
          'Pick Color for ${mode.name.toUpperCase()}',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
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
                      color: currentColor == c
                          ? Colors.white
                          : Colors.transparent,
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

  void _showHeightResetModal() {
    final state = ref.read(cadenceProvider);
    final curHeight = state.userHeightCm;
    const defHeight = 175.0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfacePanel,
        title: const Text(
          'Reset Height to Default',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset user height to the standard factory default.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Text(
              'Comparison:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Height',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                Text(
                  '${curHeight.toStringAsFixed(0)} cm ➔ ${defHeight.toStringAsFixed(0)} cm',
                  style: const TextStyle(
                    color: AppColors.traceCalm,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.traceCalm,
            ),
            onPressed: () {
              ref.read(cadenceProvider.notifier).resetHeight();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Height reset successfully!')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showStridesColorsResetModal() {
    final state = ref.read(cadenceProvider);
    final curWalk = state.walkStride;
    final curJog = state.jogStride;
    final curRun = state.runStride;

    final curWalkCol = state.walkColor;
    final curJogCol = state.jogColor;
    final curRunCol = state.runColor;

    const defWalk = 0.75;
    const defJog = 1.10;
    const defRun = 1.30;
    final defWalkCol = Colors.green;
    final defJogCol = Colors.amber;
    final defRunCol = Colors.deepOrange;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfacePanel,
        title: const Text(
          'Reset Strides & Colors',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset all strides and highlight colors to defaults.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Text(
              'Proposed Changes:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildStrideColorComparisonRow(
              'Walking Stride',
              curWalk,
              defWalk,
              curWalkCol,
              defWalkCol,
            ),
            const SizedBox(height: 8),
            _buildStrideColorComparisonRow(
              'Jogging Stride',
              curJog,
              defJog,
              curJogCol,
              defJogCol,
            ),
            const SizedBox(height: 8),
            _buildStrideColorComparisonRow(
              'Running Stride',
              curRun,
              defRun,
              curRunCol,
              defRunCol,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.traceCalm,
            ),
            onPressed: () {
              ref.read(cadenceProvider.notifier).resetStridesAndColors();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Strides and colors reset successfully!'),
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildStrideColorComparisonRow(
    String label,
    double currentVal,
    double defaultVal,
    Color currentCol,
    Color defaultCol,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textPrimary)),
            Text(
              '${currentVal.toStringAsFixed(2)}m ➔ ${defaultVal.toStringAsFixed(2)}m',
              style: const TextStyle(
                color: AppColors.traceCalm,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Color',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: currentCol,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '➔',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: defaultCol,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(color: AppColors.hairline, height: 12),
      ],
    );
  }

  void _showAudioResetModal() {
    final state = ref.read(cadenceProvider);
    final curNormal = state.normalAudio;
    final curAccent = state.accentedAudio;
    const defNormal = 'claves44_wav.wav';
    const defAccent = 'woodblock_high44_wav.wav';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfacePanel,
        title: const Text(
          'Reset Metronome Audio',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset beat sounds to standard options.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Text(
              'Proposed Changes:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildAudioComparisonRow('Normal Beat', curNormal, defNormal),
            const SizedBox(height: 8),
            _buildAudioComparisonRow('Accent Beat', curAccent, defAccent),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.traceCalm,
            ),
            onPressed: () {
              ref.read(cadenceProvider.notifier).resetAudio();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Metronome audio reset successfully!'),
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioComparisonRow(
    String label,
    String current,
    String proposed,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textPrimary)),
            Expanded(
              child: Text(
                '${current.split('.').first} ➔ ${proposed.split('.').first}',
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.traceCalm,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPresetsResetModal() {
    final state = ref.read(cadenceProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfacePanel,
        title: const Text(
          'Reset Cadence Presets',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reset all walk, jog, and run preset SPM values to factory defaults.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              const Text(
                'Proposed Changes:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Walking:',
                style: TextStyle(
                  color: AppColors.traceCalm,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...defaultWalkPresets.entries.map((e) {
                final cur = state.walkPresets[e.key] ?? e.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '$cur SPM ➔ ${e.value} SPM',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              const Text(
                'Jogging:',
                style: TextStyle(
                  color: AppColors.traceCalm,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...defaultJogPresets.entries.map((e) {
                final cur = state.jogPresets[e.key] ?? e.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '$cur SPM ➔ ${e.value} SPM',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              const Text(
                'Running:',
                style: TextStyle(
                  color: AppColors.traceCalm,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...defaultRunPresets.entries.map((e) {
                final cur = state.runPresets[e.key] ?? e.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '$cur SPM ➔ ${e.value} SPM',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.traceCalm,
            ),
            onPressed: () {
              ref.read(cadenceProvider.notifier).resetPresets();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cadence presets reset successfully!'),
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cadenceProvider);

    ref.listen(cadenceProvider.select((s) => s.userHeightCm), (previous, next) {
      // ONLY override the text field if the user isn't currently typing in it!
      if (!_heightFocusNode.hasFocus) {
        final expectedText = next.toStringAsFixed(0);
        if (_heightController.text != expectedText) {
          _heightController.text = expectedText;
        }
      }
    });

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
            // Card 1: Height Estimation
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Height Estimation',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        color: AppColors.textMuted,
                        onPressed: _showHeightResetModal,
                        tooltip: 'Reset height',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
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
                          focusNode: _heightFocusNode,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(color: AppColors.textPrimary),
                           onTap: () {
                              // Completely unbind any dirty focus states before demanding the keyboard
                              FocusManager.instance.primaryFocus?.unfocus();
                              Future.delayed(const Duration(milliseconds: 50), () {
                                if (mounted) {
                                  _heightFocusNode.requestFocus();
                                }
                              });
                            },
                          onChanged: (val) {
                            final h = double.tryParse(val);
                            if (h != null && h > 0) {
                              ref
                                  .read(cadenceProvider.notifier)
                                  .setUserHeight(h);
                            }
                          },
                          onSubmitted: (val) {
                            final h = double.tryParse(val);
                            if (h != null && h > 0) {
                              ref
                                  .read(cadenceProvider.notifier)
                                  .setUserHeight(h);
                            }
                            _heightFocusNode.unfocus();
                          },
                          decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            labelStyle: const TextStyle(
                              color: AppColors.textMuted,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceRaised,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.hairline,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.traceCalm,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          final h =
                              double.tryParse(_heightController.text) ?? 175.0;
                          _showPrefillModal(h);
                        },
                        child: const Text(
                          'Prefill Strides',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Card 2: Stride & Color Configuration
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Stride & Color Configuration',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        color: AppColors.textMuted,
                        onPressed: _showStridesColorsResetModal,
                        tooltip: 'Reset strides and colors',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Configure custom stride lengths and highlight colors for each movement mode.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  _buildModeStrideSection(
                    context,
                    ref,
                    'Walking Stride',
                    MovementMode.walking,
                    state.walkStride,
                    state.walkColor,
                  ),
                  const Divider(color: AppColors.hairline, height: 28),
                  _buildModeStrideSection(
                    context,
                    ref,
                    'Jogging Stride',
                    MovementMode.jogging,
                    state.jogStride,
                    state.jogColor,
                  ),
                  const Divider(color: AppColors.hairline, height: 28),
                  _buildModeStrideSection(
                    context,
                    ref,
                    'Running Stride',
                    MovementMode.running,
                    state.runStride,
                    state.runColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Card 3: Metronome Audio
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Metronome Audio',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        color: AppColors.textMuted,
                        onPressed: _showAudioResetModal,
                        tooltip: 'Reset audio selections',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose the sound files for normal and accented beats.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Normal Beat',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildAudioDropdown(state.normalAudio, (val) {
                    ref
                        .read(cadenceProvider.notifier)
                        .setAudioSelection(val, state.accentedAudio);
                  }),
                  const SizedBox(height: 16),
                  const Text(
                    'Accent Beat',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildAudioDropdown(state.accentedAudio, (val) {
                    ref
                        .read(cadenceProvider.notifier)
                        .setAudioSelection(state.normalAudio, val);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Card 4: Cadence Presets
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cadence Presets',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        color: AppColors.textMuted,
                        onPressed: _showPresetsResetModal,
                        tooltip: 'Reset cadence presets',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Customize SPM values for walking, jogging, and running presets (60–240 SPM).',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  _buildPresetCategorySection(
                    context,
                    ref,
                    'Walking Presets',
                    MovementMode.walking,
                    state.walkPresets,
                  ),
                  const Divider(color: AppColors.hairline, height: 28),
                  _buildPresetCategorySection(
                    context,
                    ref,
                    'Jogging Presets',
                    MovementMode.jogging,
                    state.jogPresets,
                  ),
                  const Divider(color: AppColors.hairline, height: 28),
                  _buildPresetCategorySection(
                    context,
                    ref,
                    'Running Presets',
                    MovementMode.running,
                    state.runPresets,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildPresetCategorySection(
    BuildContext context,
    WidgetRef ref,
    String title,
    MovementMode mode,
    Map<String, int> presets,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...presets.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: entry.value.toDouble(),
                          min: 60,
                          max: 240,
                          divisions: 180,
                          activeColor: AppColors.traceCalm,
                          inactiveColor: AppColors.surfaceRaised,
                          onChanged: (val) {
                            ref
                                .read(cadenceProvider.notifier)
                                .setPresetCadence(
                                  mode,
                                  entry.key,
                                  val.round(),
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 48,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.hairline),
                        ),
                        child: Text(
                          '${entry.value}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAudioDropdown(
    String currentValue,
    ValueChanged<String> onChanged,
  ) {
    final availableAudioFiles = [
      'base44_wav.wav',
      'claves44_wav.wav',
      'hihat44_wav.wav',
      'mute44_wav.wav',
      'snare44_wav.wav',
      'sticks44_wav.wav',
      'woodblock_high44_wav.wav',
    ];

    final value = availableAudioFiles.contains(currentValue)
        ? currentValue
        : availableAudioFiles.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.hairline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.surfacePanel,
          style: const TextStyle(color: AppColors.textPrimary),
          isExpanded: true,
          onChanged: (val) {
            if (val != null) {
              onChanged(val);
            }
          },
          items: availableAudioFiles
              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildModeStrideSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    MovementMode mode,
    double stride,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => _showColorPicker(mode, color),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Color',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
