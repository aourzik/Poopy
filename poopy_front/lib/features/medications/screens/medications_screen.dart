import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/poopy_widgets.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  static const _meds = [
    _MedData(
      name: 'Pentasa', dose: '500 mg',
      freq: '2 comprimés · 3×/jour',
      next: '20:00', nextColor: AppColors.meds,
      taken: 2, total: 3,
      iconColor: AppColors.meds, isInjection: false,
    ),
    _MedData(
      name: 'Imurel', dose: '50 mg',
      freq: '1 comprimé · matin',
      next: 'Demain · 08:00', nextColor: AppColors.rdv,
      taken: 1, total: 1,
      iconColor: AppColors.rdv, isInjection: false,
    ),
    _MedData(
      name: 'Humira', dose: '40 mg',
      freq: 'Injection · tous les 14j',
      next: 'Lun. 18 mai', nextColor: AppColors.analyses,
      taken: 0, total: 0,
      iconColor: AppColors.analyses, isInjection: true,
    ),
    _MedData(
      name: 'Spasfon', dose: '80 mg',
      freq: 'Si besoin · max 6/j',
      next: 'Au besoin', nextColor: AppColors.poids,
      taken: 1, total: null,
      iconColor: AppColors.poids, isInjection: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.t;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EyebrowLabel('Médicaments'),
                Text(
                  'Mon traitement',
                  style: TextStyle(
                    fontFamily: 'Quicksand', fontSize: 26,
                    fontWeight: FontWeight.w500, color: t.text,
                  ),
                ),
              ],
            ),
          ),

          // Compliance card
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: PoopyCard(
              backgroundColor: AppColors.meds,
              borderRadius: 26,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _ComplianceRing(taken: 3, total: 4),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AUJOURD'HUI",
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 12,
                          fontWeight: FontWeight.w700, letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '3/4 prises',
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 22,
                          fontWeight: FontWeight.w500, color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Prochaine prise dans 4h30',
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Scan button
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: context.t.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: context.t.border,
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              // Dashed border effect via CustomPaint
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.document_scanner_outlined,
                        size: 20, color: t.text),
                    const SizedBox(width: 10),
                    Text(
                      'Scanner une ordonnance',
                      style: TextStyle(
                        fontFamily: 'Quicksand', fontSize: 14,
                        fontWeight: FontWeight.w700, color: t.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Meds list
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'MES MÉDICAMENTS',
                    style: TextStyle(
                      fontFamily: 'Quicksand', fontSize: 12,
                      fontWeight: FontWeight.w700, letterSpacing: 0.5,
                      color: t.textDim,
                    ),
                  ),
                ),
                ..._meds.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _MedCard(med: m),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceRing extends StatelessWidget {
  final int taken;
  final int total;

  const _ComplianceRing({required this.taken, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? taken / total : 0.0;
    return SizedBox(
      width: 72, height: 72,
      child: CustomPaint(
        painter: _RingPainter(pct: pct),
        child: Center(
          child: Text(
            '${(pct * 100).round()}%',
            style: const TextStyle(
              fontFamily: 'Quicksand', fontSize: 18,
              fontWeight: FontWeight.w700, color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double pct;
  _RingPainter({required this.pct});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background ring
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * pct,
      false,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.pct != pct;
}

class _MedCard extends StatefulWidget {
  final _MedData med;
  const _MedCard({required this.med});

  @override
  State<_MedCard> createState() => _MedCardState();
}

class _MedCardState extends State<_MedCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final m = widget.med;

    return PoopyCard(
      borderRadius: 20,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: m.iconColor.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: m.iconColor.withOpacity(0.2),
                      ),
                    ),
                    child: Icon(
                      m.isInjection
                          ? Icons.auto_awesome_rounded
                          : Icons.medication_rounded,
                      size: 22, color: m.iconColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              m.name,
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 15.5,
                                fontWeight: FontWeight.w700, color: t.text,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              m.dose,
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 11.5,
                                fontWeight: FontWeight.w600, color: t.textDim,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          m.freq,
                          style: TextStyle(
                            fontFamily: 'Quicksand', fontSize: 12,
                            fontWeight: FontWeight.w500, color: t.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Next
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PROCHAINE',
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 10.5,
                          fontWeight: FontWeight.w700, letterSpacing: 0.4,
                          color: t.textMuted,
                        ),
                      ),
                      Text(
                        m.next,
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: m.nextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded actions
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: m.iconColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Marquer pris',
                                    style: TextStyle(
                                      fontFamily: 'Quicksand', fontSize: 13,
                                      fontWeight: FontWeight.w700, color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: context.t.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.t.border),
                            ),
                            child: Center(
                              child: Text(
                                'Reporter',
                                style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: context.t.text,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _MedData {
  final String name;
  final String dose;
  final String freq;
  final String next;
  final Color nextColor;
  final int taken;
  final int? total;
  final Color iconColor;
  final bool isInjection;

  const _MedData({
    required this.name, required this.dose, required this.freq,
    required this.next, required this.nextColor,
    required this.taken, this.total,
    required this.iconColor, required this.isInjection,
  });
}
