import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poopy/features/journal/models/stool_model.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/poopy_widgets.dart';

class DayDetailCard extends StatelessWidget {
  final DateTime date;
  final Stool entry;
  final VoidCallback onEdit;

  const DayDetailCard({
    super.key,
    required this.date,
    required this.entry,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final dateStr = DateFormat('EEEE d MMMM', 'fr_FR').format(date);

    return PoopyCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Quicksand', fontSize: 11,
                        fontWeight: FontWeight.w700, color: t.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${entry.count} épisode${entry.count > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontFamily: 'Quicksand', fontSize: 22,
                        fontWeight: FontWeight.w500, color: t.text,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: t.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 14, color: t.text),
                      const SizedBox(width: 4),
                      Text(
                        'Modifier',
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 12,
                          fontWeight: FontWeight.w700, color: t.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChip(
                label: 'Bristol ${entry.bristol}',
                color: AppColors.poids,
                icon: Icons.auto_awesome_rounded,
              ),
              AppChip(
                label: entry.blood ? 'Sang présent' : 'Pas de sang',
                color: entry.blood ? AppColors.selles : AppColors.rdv,
                icon: Icons.water_drop_outlined,
              ),
              AppChip(
                label: entry.urgency ? 'Urgence' : 'Calme',
                color: entry.urgency ? AppColors.meds : AppColors.rdv,
                icon: Icons.local_fire_department_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}