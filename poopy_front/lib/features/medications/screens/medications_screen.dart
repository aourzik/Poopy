import 'package:flutter/material.dart';
import 'dart:math' as math;

// Chemins vers le thème et les widgets partagés
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/poopy_widgets.dart';

// Chemin vers ton modèle partagé
import '../../../shared/models/models.dart'; 

// Chemins vers les fichiers dans le même dossier feature
import '../services/medication_service.dart'; 
import '../widgets/add_medication_sheet.dart';
import '../../../core/constants/app_constants.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final MedicationService _service = MedicationService();
  List<Medication> _meds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final data = await _service.getMeds(AppConstants.currentUserId);
    
    print("💊 Nombre de médicaments chargés: ${data.length}");

    if (!mounted) return;
    setState(() {
      _meds = data;
      _isLoading = false;
    });
  }

  int get _totalTaken => _meds.fold(0, (sum, item) => sum + item.takenToday);
  int get _totalExpected => _meds.fold(0, (sum, item) => sum + (item.totalToday ?? 0));

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
                  _ComplianceRing(taken: _totalTaken, total: _totalExpected),
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
                      Text(
                        '$_totalTaken/$_totalExpected prises',
                        style: const TextStyle(
                          fontFamily: 'Quicksand', fontSize: 22,
                          fontWeight: FontWeight.w500, color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Suivi en temps réel',
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

          // Bouton Ajouter
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: GestureDetector(
              onTap: () async {
                final result = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddMedicationSheet(),
                );
                if (result == true) {
                  _loadData(); 
                }
              },
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: context.t.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.t.border, width: 1.5),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 20, color: t.text),
                      const SizedBox(width: 10),
                      Text(
                        'Ajouter un traitement',
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
          ),

          // Liste des Médicaments (ICI MODIFIÉ POUR LE SWIPE)
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
                if (_isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                else if (_meds.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Aucun traitement enregistré")))
                else
                  ..._meds.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Dismissible(
                      key: Key(m.id ?? UniqueKey().toString()),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        // Optionnel : tu pourrais ajouter un dialogue de confirmation ici
                        return true;
                      },
                      onDismissed: (direction) async {
                        if (m.id != null) {
                          await _service.deleteMedication(m.id!);
                          _loadData(); // On recharge
                        }
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      child: _MedCard(
                        med: m,
                        onTaken: () async {
                          if (m.id != null) {
                            await _service.markAsTaken(m.id!);
                            _loadData();
                          }
                        },
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

    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke,
    );

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
  final Medication med;
  final VoidCallback onTaken;
  const _MedCard({required this.med, required this.onTaken});

  @override
  State<_MedCard> createState() => _MedCardState();
}

class _MedCardState extends State<_MedCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final m = widget.med;
    final color = _getColor(m.color);

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
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Icon(
                      m.isInjection ? Icons.auto_awesome_rounded : Icons.medication_rounded,
                      size: 22, color: color,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(m.name, style: TextStyle(fontFamily: 'Quicksand', fontSize: 15.5, fontWeight: FontWeight.w700, color: t.text)),
                            const SizedBox(width: 8),
                            Text(m.dose, style: TextStyle(fontFamily: 'Quicksand', fontSize: 11.5, fontWeight: FontWeight.w600, color: t.textDim)),
                          ],
                        ),
                        Text(m.frequency, style: TextStyle(fontFamily: 'Quicksand', fontSize: 12, fontWeight: FontWeight.w500, color: t.textDim)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('PRISES', style: TextStyle(fontFamily: 'Quicksand', fontSize: 10.5, fontWeight: FontWeight.w700, color: t.textMuted)),
                      Text('${m.takenToday}/${m.totalToday ?? '∞'}', style: TextStyle(fontFamily: 'Quicksand', fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                            onTap: widget.onTaken,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_rounded, size: 16, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text('Marquer pris', style: TextStyle(fontFamily: 'Quicksand', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(color: context.t.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.t.border)),
                            child: Center(child: Text('Reporter', style: TextStyle(fontFamily: 'Quicksand', fontSize: 13, fontWeight: FontWeight.w700, color: context.t.text))),
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

  Color _getColor(MedColor c) {
    switch (c) {
      case MedColor.coral: return AppColors.selles;
      case MedColor.amber: return AppColors.meds;
      case MedColor.green: return AppColors.rdv;
      case MedColor.blue: return AppColors.analyses;
      case MedColor.purple: return AppColors.poids;
    }
  }
}