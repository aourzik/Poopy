import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_router.dart';
import '../../../shared/widgets/poopy_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? _selectedMood;

  static const _moods = [
    (emoji: '😣', label: 'Crise', value: 1),
    (emoji: '😕', label: 'Difficile', value: 2),
    (emoji: '😐', label: 'Moyen', value: 3),
    (emoji: '🙂', label: 'Bien', value: 4),
    (emoji: '😄', label: 'Top', value: 5),
  ];

  // Mock 7-day data (replace with real Riverpod state later)
  final _last7 = [
    (day: 7, count: 1),
    (day: 8, count: 0),
    (day: 9, count: 2),
    (day: 10, count: 1),
    (day: 11, count: 4),
    (day: 12, count: 1),
    (day: 13, count: 2),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final today = DateTime.now();
    final dateStr = DateFormat('EEEE d MMMM', 'fr_FR').format(today);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        0, MediaQuery.of(context).padding.top + 56, 0, 140,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
            child: Row(
              children: [
                // Mascot
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFEF7EF),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pinkDeep.withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Transform.scale(
                      scale: 1.3,
                      child: Image.asset(
                        'assets/poopy_logo_dash.png', // Ton logo en miniature
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // Capitalize first letter
                        dateStr[0].toUpperCase() + dateStr.substring(1),
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 13,
                          fontWeight: FontWeight.w500, color: t.textDim,
                        ),
                      ),
                      Text(
                        'Coucou, Alex',
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 24,
                          fontWeight: FontWeight.w500, color: t.text,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bell
                Stack(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: t.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.border),
                      ),
                      child: Icon(Icons.notifications_none_rounded, size: 20, color: t.text),
                    ),
                    Positioned(
                      top: 8, right: 9,
                      child: Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.selles,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.surface, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Mood selector
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comment te sens-tu aujourd\'hui\u00a0?',
                  style: TextStyle(
                    fontFamily: 'Quicksand', fontSize: 13,
                    fontWeight: FontWeight.w600, color: t.textDim,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: _moods.map((m) {
                    final isSelected = _selectedMood == m.value;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMood = m.value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.pink.withOpacity(0.2)
                                : t.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected ? AppColors.pinkDeep : t.border,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(m.emoji, style: const TextStyle(fontSize: 22)),
                              const SizedBox(height: 4),
                              Text(
                                m.label,
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.pinkDeep
                                      : t.textDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Hero stool card
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: PoopyCard(
              backgroundColor: AppColors.selles,
              borderRadius: 28,
              padding: const EdgeInsets.all(20),
              onTap: () => context.go(AppRoutes.journal),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.menu_book_rounded,
                                size: 16, color: Colors.white70),
                            const SizedBox(width: 8),
                            const Text(
                              'JOURNAL · AUJOURD\'HUI',
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 13,
                                fontWeight: FontWeight.w600, color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '2',
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 44,
                                fontWeight: FontWeight.w700, color: Colors.white,
                                letterSpacing: -1, height: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'épisodes',
                                style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.92),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Bristol 4 · urgence',
                          style: TextStyle(
                            fontFamily: 'Quicksand', fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Mini sparkline
                  SizedBox(
                    width: 92, height: 60,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _last7.asMap().entries.map((e) {
                        final isToday = e.key == 6;
                        final h = e.value.count == 0
                            ? 4.0
                            : (e.value.count / 5.0) * 50;
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: double.infinity,
                                    height: h,
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withOpacity(isToday ? 1.0 : 0.42),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${e.value.day}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Quicksand',
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Poids + Méds row
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: Row(
              children: [
                Expanded(
                  child: PoopyCard(
                    backgroundColor: AppColors.poids,
                    borderRadius: 24,
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 144,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'POIDS',
                                style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 12,
                                  fontWeight: FontWeight.w700, letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                              const Icon(Icons.auto_awesome_rounded,
                                  size: 16, color: Colors.white),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    '62.4',
                                    style: TextStyle(
                                      fontFamily: 'Quicksand', fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white, letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      'kg',
                                      style: TextStyle(
                                        fontFamily: 'Quicksand', fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '↗ +0.3 kg cette semaine',
                                style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PoopyCard(
                    backgroundColor: AppColors.meds,
                    borderRadius: 24,
                    padding: const EdgeInsets.all(16),
                    onTap: () => context.go(AppRoutes.medications),
                    child: SizedBox(
                      height: 144,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'MÉDICAMENTS',
                                style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 12,
                                  fontWeight: FontWeight.w700, letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                              const Icon(Icons.medication_rounded,
                                  size: 16, color: Colors.white),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    '3',
                                    style: TextStyle(
                                      fontFamily: 'Quicksand', fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white, letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '/ 4 pris',
                                      style: TextStyle(
                                        fontFamily: 'Quicksand', fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Prochaine\u00a0: Pentasa · 20h',
                                style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Insight strip
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: PoopyCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              onTap: () {},
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.pink.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 20, color: AppColors.pinkDeep,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tendance stable depuis 4 jours',
                          style: TextStyle(
                            fontFamily: 'Quicksand', fontSize: 13,
                            fontWeight: FontWeight.w700, color: context.t.text,
                          ),
                        ),
                        Text(
                          'Bonne réponse au traitement actuel.',
                          style: TextStyle(
                            fontFamily: 'Quicksand', fontSize: 11.5,
                            fontWeight: FontWeight.w500, color: context.t.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: context.t.textMuted),
                ],
              ),
            ),
          ),

          // Next appointment
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'PROCHAIN RENDEZ-VOUS',
                    style: TextStyle(
                      fontFamily: 'Quicksand', fontSize: 12,
                      fontWeight: FontWeight.w700, letterSpacing: 0.5,
                      color: context.t.textDim,
                    ),
                  ),
                ),
                PoopyCard(
                  borderRadius: 22,
                  padding: const EdgeInsets.all(16),
                  onTap: () => context.go(AppRoutes.appointments),
                  child: Row(
                    children: [
                      Container(
                        width: 56, height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.rdv,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.rdv.withOpacity(0.35),
                              blurRadius: 14, offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'MAI',
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 10,
                                fontWeight: FontWeight.w700, color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '27',
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 22,
                                fontWeight: FontWeight.w700, color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. Marchand · CHU',
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: context.t.text,
                              ),
                            ),
                            Text(
                              '14:30 · Contrôle trimestriel',
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: context.t.textDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: context.t.textMuted),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
