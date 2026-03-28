import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Key/value attribute rows; [keyControllers] / [valueControllers] must match
/// length (managed by the screen / notifier sync).
class AttributesSection extends StatelessWidget {
  const AttributesSection({
    super.key,
    required this.keyControllers,
    required this.valueControllers,
    required this.onAdd,
    required this.onRemove,
    required this.onKeyChanged,
    required this.onValueChanged,
  });

  final List<TextEditingController> keyControllers;
  final List<TextEditingController> valueControllers;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final void Function(int index, String key) onKeyChanged;
  final void Function(int index, String value) onValueChanged;

  @override
  Widget build(BuildContext context) {
    assert(keyControllers.length == valueControllers.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < keyControllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: keyControllers[i],
                    onChanged: (v) => onKeyChanged(i, v),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const Gap(AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    ':',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: valueControllers[i],
                    onChanged: (v) => onValueChanged(i, v),
                    decoration: InputDecoration(
                      labelText: 'Value',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => onRemove(i),
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                ),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add attribute'),
        ),
      ],
    );
  }
}
