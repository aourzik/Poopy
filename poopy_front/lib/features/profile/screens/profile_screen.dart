import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/poopy_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _labTab = 0; // 0=Sang, 1=Calpro
  int _openFaq = -1;

  static const _labResults = [
    [
      _LabData(name: 'Bilan inflammatoire', date: '12 mars 2026',
          lab: 'Cerba', tag: 'CRP 4.2 mg/L', isNormal: true),
      _LabData(name: 'NFS complet', date: '12 mars 2026',
          lab: 'Cerba', tag: 'Hb 13.4 g/dL', isNormal: true),
      _LabData(name: 'Bilan inflammatoire', date: '08 février 2026',
          lab: 'Cerba', tag: 'CRP 8.6 mg/L', isNormal: false),
      _LabData(name: 'Vitamine D + B12', date: '08 février 2026',
          lab: 'Cerba', tag: 'Légère carence', isNormal: false),
    ],
    [
      _LabData(name: 'Calprotectine fécale', date: '12 mars 2026',
          lab: 'Cerba', tag: '128 µg/g', isNormal: true),
      _LabData(name: 'Calprotectine fécale', date: '08 février 2026',
          lab: 'Cerba', tag: '462 µg/g', isNormal: false),
      _LabData(name: 'Calprotectine fécale', date: '15 décembre 2025',
          lab: 'Biogroup', tag: '720 µg/g', isNormal: false),
    ],
  ];

  static const _faqs = [
    (
      q: 'À quoi sert la calprotectine fécale\u00a0?',
      a: 'C\'est un marqueur de l\'inflammation intestinale. Plus le taux est bas, mieux ton intestin se porte. Au-delà de 250 µg/g, on parle d\'une poussée active.',
    ),
    (
      q: 'Quand consulter en urgence\u00a0?',
      a: 'Présence de sang abondant, douleurs intenses, fièvre supérieure à 38.5°C, ou plus de 6 selles liquides par jour. Contacte ton gastro ou les urgences.',
    ),
    (
      q: 'Comment Poopy protège mes données\u00a0?',
      a: 'Tes données sont chiffrées de bout en bout et stockées en France. Tu peux les exporter ou tout supprimer à tout moment.',
    ),
    (
      q: 'Puis-je partager mon journal avec mon médecin\u00a0?',
      a: 'Oui, depuis l\'onglet Analyses tu peux générer un rapport PDF et l\'envoyer directement à ton gastro.',
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const EyebrowLabel('Mon espace'),
                      Text('Profil & Analyses',
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 26,
                          fontWeight: FontWeight.w500, color: t.text,
                        )),
                    ],
                  ),
                ),
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.border),
                  ),
                  child: Icon(Icons.settings_outlined, size: 20, color: t.text),
                ),
              ],
            ),
          ),

          // Profile card
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
            child: PoopyCard(
              backgroundColor: AppColors.analyses,
              borderRadius: 26,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('A',
                            style: TextStyle(
                              fontFamily: 'Quicksand', fontSize: 24,
                              fontWeight: FontWeight.w700, color: Colors.white,
                            )),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Alex Moreau',
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 22,
                                fontWeight: FontWeight.w500, color: Colors.white,
                                height: 1.1,
                              )),
                            Text(
                              'MICI · Maladie de Crohn · diagnostic 2023',
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatBox(label: 'Jours suivis', value: '847'),
                      const SizedBox(width: 10),
                      _StatBox(label: 'En rémission', value: '143j'),
                      const SizedBox(width: 10),
                      _StatBox(label: 'Streak', value: '🔥 28'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Analyses
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text('MES ANALYSES',
                    style: TextStyle(
                      fontFamily: 'Quicksand', fontSize: 12,
                      fontWeight: FontWeight.w700, letterSpacing: 0.5,
                      color: t.textDim,
                    )),
                ),
                PoopySegmented(
                  options: const ['Sang', 'Calpro'],
                  selectedIndex: _labTab,
                  onChanged: (i) => setState(() => _labTab = i),
                  accentColor: AppColors.analyses,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
            child: Column(
              children: _labResults[_labTab].map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PoopyCard(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.analysesSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          size: 22, color: AppColors.analysesDeep,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.name,
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 13.5,
                                fontWeight: FontWeight.w700, color: t.text,
                              )),
                            Text('${d.date} · ${d.lab}',
                              style: TextStyle(
                                fontFamily: 'Quicksand', fontSize: 11,
                                fontWeight: FontWeight.w500, color: t.textDim,
                              )),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: d.isNormal
                                    ? AppColors.rdvSoft
                                    : AppColors.sellesSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(d.tag,
                                style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: d.isNormal
                                      ? AppColors.rdvDeep
                                      : AppColors.sellesDeep,
                                )),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          _DocActionBtn(
                            icon: Icons.visibility_outlined, t: t,
                          ),
                          const SizedBox(height: 6),
                          _DocActionBtn(
                            icon: Icons.download_outlined, t: t,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),

          // FAQ
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text('QUESTIONS FRÉQUENTES',
                    style: TextStyle(
                      fontFamily: 'Quicksand', fontSize: 12,
                      fontWeight: FontWeight.w700, letterSpacing: 0.5,
                      color: t.textDim,
                    )),
                ),
                PoopyCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: _faqs.asMap().entries.map((e) {
                      final isOpen = _openFaq == e.key;
                      final isLast = e.key == _faqs.length - 1;
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              _openFaq = isOpen ? -1 : e.key;
                            }),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(e.value.q,
                                      style: TextStyle(
                                        fontFamily: 'Quicksand', fontSize: 13.5,
                                        fontWeight: FontWeight.w700, color: t.text,
                                      )),
                                  ),
                                  AnimatedRotation(
                                    duration: const Duration(milliseconds: 240),
                                    turns: isOpen ? 0.5 : 0,
                                    child: Container(
                                      width: 24, height: 24,
                                      decoration: BoxDecoration(
                                        color: isOpen
                                            ? AppColors.pink.withOpacity(0.2)
                                            : t.surfaceMuted,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 14,
                                        color: isOpen
                                            ? AppColors.pinkDeep
                                            : t.textDim,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeInOut,
                            child: isOpen
                                ? Padding(
                                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                                    child: Text(e.value.a,
                                      style: TextStyle(
                                        fontFamily: 'Quicksand', fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: t.textDim, height: 1.5,
                                      )),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          if (!isLast)
                            Divider(height: 1, indent: 14, endIndent: 14, color: t.border),
                        ],
                      );
                    }).toList(),
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

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
              style: const TextStyle(
                fontFamily: 'Quicksand', fontSize: 17,
                fontWeight: FontWeight.w700, color: Colors.white,
              )),
            Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Quicksand', fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.85),
              )),
          ],
        ),
      ),
    );
  }
}

class _DocActionBtn extends StatelessWidget {
  final IconData icon;
  final AppThemeExtension t;

  const _DocActionBtn({required this.icon, required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.border),
      ),
      child: Icon(icon, size: 16, color: t.text),
    );
  }
}

class _LabData {
  final String name;
  final String date;
  final String lab;
  final String tag;
  final bool isNormal;

  const _LabData({
    required this.name, required this.date,
    required this.lab, required this.tag,
    required this.isNormal,
  });
}
