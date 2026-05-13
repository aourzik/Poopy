import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/poopy_widgets.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  static const _months = [
    'JAN','FÉV','MAR','AVR','MAI','JUN',
    'JUL','AOÛ','SEP','OCT','NOV','DÉC',
  ];

  static final _upcoming = [
    _ApptData(
      date: DateTime(2026, 5, 27), time: '14:30',
      doctor: 'Dr. Marchand', location: 'CHU · Service gastro',
      type: 'Contrôle trimestriel', daysFromNow: 14,
    ),
    _ApptData(
      date: DateTime(2026, 6, 15), time: '09:00',
      doctor: 'Lab Cerba', location: 'Prise de sang',
      type: 'Bilan inflammatoire', daysFromNow: 33,
    ),
    _ApptData(
      date: DateTime(2026, 7, 8), time: '11:00',
      doctor: 'Dr. Lambert', location: 'Cabinet de ville',
      type: 'Endoscopie de contrôle', daysFromNow: 56,
    ),
  ];

  static final _past = [
    _ApptData(
      date: DateTime(2026, 3, 12), time: '15:00',
      doctor: 'Dr. Marchand', location: 'CHU · Service gastro',
      type: 'Suivi traitement', daysFromNow: -62,
    ),
    _ApptData(
      date: DateTime(2026, 2, 8), time: '08:30',
      doctor: 'Lab Cerba', location: 'Calprotectine',
      type: 'Analyse', daysFromNow: -94,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final next = _upcoming.first;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        0, MediaQuery.of(context).padding.top + 56, 0, 140,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const EyebrowLabel('Rendez-vous'),
                      Text(
                        'Mon agenda',
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 26,
                          fontWeight: FontWeight.w500, color: t.text,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42, height: 42,
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
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                ),
              ],
            ),
          ),

          // Hero next appointment
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
            child: PoopyCard(
              backgroundColor: AppColors.rdv,
              borderRadius: 28,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DANS ${next.daysFromNow} JOURS',
                    style: TextStyle(
                      fontFamily: 'Quicksand', fontSize: 11.5,
                      fontWeight: FontWeight.w700, letterSpacing: 0.5,
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    next.doctor,
                    style: const TextStyle(
                      fontFamily: 'Quicksand', fontSize: 26,
                      fontWeight: FontWeight.w500, color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${next.type} · ${next.location}',
                    style: TextStyle(
                      fontFamily: 'Quicksand', fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      // Date box
                      Container(
                        width: 64, height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _months[next.date.month - 1],
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              '${next.date.day}',
                              style: const TextStyle(
                                fontFamily: 'Quicksand', fontSize: 26,
                                fontWeight: FontWeight.w700, color: Colors.white,
                                height: 1,
                              ),
                            ),
                            Text(
                              next.time,
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Action buttons
                      Expanded(
                        child: Column(
                          children: [
                            _ApptActionBtn(
                              label: 'Voir détails',
                              bg: Colors.white,
                              textColor: AppColors.rdvDeep,
                            ),
                            const SizedBox(height: 6),
                            _ApptActionBtn(
                              label: 'Préparer la visite',
                              bg: Colors.white.withOpacity(0.2),
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Upcoming
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text('À VENIR',
                    style: TextStyle(
                      fontFamily: 'Quicksand', fontSize: 12,
                      fontWeight: FontWeight.w700, letterSpacing: 0.5,
                      color: t.textDim,
                    )),
                ),
                ..._upcoming.skip(1).map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PoopyCard(
                    borderRadius: 18,
                    padding: const EdgeInsets.all(14),
                    onTap: () {},
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.rdvSoft,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _months[a.date.month - 1],
                                style: const TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.rdvDeep, letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                '${a.date.day}',
                                style: const TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.rdvDeep, height: 1,
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
                              Text(a.doctor,
                                style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 14,
                                  fontWeight: FontWeight.w700, color: t.text,
                                )),
                              Text('${a.time} · ${a.type}',
                                style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 11.5,
                                  fontWeight: FontWeight.w500, color: t.textDim,
                                )),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: t.textMuted),
                      ],
                    ),
                  ),
                )),

                // Past
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text('PASSÉS',
                    style: TextStyle(
                      fontFamily: 'Quicksand', fontSize: 12,
                      fontWeight: FontWeight.w700, letterSpacing: 0.5,
                      color: t.textDim,
                    )),
                ),
                ..._past.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Opacity(
                    opacity: 0.78,
                    child: PoopyCard(
                      borderRadius: 18,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 52,
                            decoration: BoxDecoration(
                              color: t.surfaceMuted,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: t.border),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _months[a.date.month - 1],
                                  style: TextStyle(
                                    fontFamily: 'Quicksand', fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: t.textDim, letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  '${a.date.day}',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand', fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: t.textDim, height: 1,
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
                                Text(a.doctor,
                                  style: TextStyle(
                                    fontFamily: 'Quicksand', fontSize: 14,
                                    fontWeight: FontWeight.w700, color: t.text,
                                  )),
                                Text(a.type,
                                  style: TextStyle(
                                    fontFamily: 'Quicksand', fontSize: 11.5,
                                    fontWeight: FontWeight.w500, color: t.textDim,
                                  )),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.rdvSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'FAIT',
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.rdvDeep,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApptActionBtn extends StatelessWidget {
  final String label;
  final Color bg;
  final Color textColor;

  const _ApptActionBtn({
    required this.label, required this.bg, required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(label, style: TextStyle(
          fontFamily: 'Quicksand', fontSize: 12.5,
          fontWeight: FontWeight.w700, color: textColor,
        )),
      ),
    );
  }
}

class _ApptData {
  final DateTime date;
  final String time;
  final String doctor;
  final String location;
  final String type;
  final int daysFromNow;

  const _ApptData({
    required this.date, required this.time,
    required this.doctor, required this.location,
    required this.type, required this.daysFromNow,
  });
}
