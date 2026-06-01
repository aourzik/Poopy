import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_router.dart';
import '../../../core/services/user_session.dart';
import '../../../shared/widgets/poopy_widgets.dart';
import '../../../shared/models/models.dart';
import '../services/profile_service.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/add_lab_sheet.dart';
import '../../journal/services/stool_service.dart';
import '../../journal/models/stool_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  int _labTab = 0;
  int _openFaq = -1;

  UserModel? _currentUser;
  List<MedicalLab> _bloodLabs = [];
  List<MedicalLab> _calproLabs = [];
  bool _isLoading = true;

  int _streak = 0;
  String _healthStatus = 'Stable';

  static const _faqs = [
    (
      q: 'À quoi sert la calprotectine fécale ?',
      a: 'C\'est un marqueur de l\'inflammation intestinale. Plus le taux est bas, mieux ton intestin se porte. Au-delà de 250 µg/g, on parle d\'une poussée active.'
    ),
    (
      q: 'Quand consulter en urgence ?',
      a: 'Présence de sang abondant, douleurs intenses, fièvre supérieure à 38.5°C, ou plus de 6 selles liquides par jour. Contacte ton gastro ou les urgences.'
    ),
    (
      q: 'Comment Poopy protège mes données ?',
      a: 'Tes données sont chiffrées de bout en bout et stockées en France. Tu peux les exporter ou tout supprimer à tout moment.'
    ),
    (
      q: 'Puis-je partager mon journal avec mon médecin ?',
      a: 'Oui, depuis l\'onglet Analyses tu peux générer un rapport PDF et l\'envoyer directement à ton gastro.'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final userFuture = _profileService.getUser(AppConstants.currentUserId);
    final labsFuture = _profileService.getLabs(AppConstants.currentUserId);
    final stoolsFuture = StoolService().getStools(AppConstants.currentUserId);

    await Future.wait([userFuture, labsFuture, stoolsFuture]);

    final user = await userFuture;
    final allLabs = await labsFuture;
    final stools = await stoolsFuture;

    setState(() {
      _currentUser = user;
      _bloodLabs = allLabs.where((l) => l.type == LabType.blood).toList();
      _calproLabs = allLabs.where((l) => l.type == LabType.calprotectin).toList();
      _streak = _computeStreak(stools);
      _healthStatus = _computeHealthStatus(stools);
      _isLoading = false;
    });
  }

  int _computeStreak(List<Stool> stools) {
    if (stools.isEmpty) return 0;
    final today = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final day = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      final hasEntry = stools.any((s) {
        if (s.date == null) return false;
        final d = s.date!.toLocal();
        return d.year == day.year && d.month == day.month && d.day == day.day;
      });
      if (hasEntry) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  String _computeHealthStatus(List<Stool> stools) {
    final now = DateTime.now();
    final last7 = stools.where((s) {
      if (s.date == null) return false;
      return now.difference(s.date!.toLocal()).inDays <= 7;
    }).toList();

    if (last7.isEmpty) return 'Stable';

    final hasDanger = last7.any((s) => s.blood || s.urgency);
    final highBristolDays = <String>{};
    for (final s in last7) {
      if (s.bristol >= 5 && s.date != null) {
        final d = s.date!.toLocal();
        highBristolDays.add('${d.year}-${d.month}-${d.day}');
      }
    }

    if (hasDanger || highBristolDays.length >= 4) return 'En crise';
    if (highBristolDays.length >= 2) return 'À surveiller';
    return 'Stable';
  }

  void _openEditProfile() {
    if (_currentUser == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(
        user: _currentUser!,
        onSaved: _loadData,
      ),
    );
  }

  void _openAddLab(int tab) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddLabSheet(
        initialTab: tab,
        onAdded: _loadData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final currentLabsList = _labTab == 0 ? _bloodLabs : _calproLabs;

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.analysesDeep));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          0, MediaQuery.of(context).padding.top + 56, 0, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
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
                              fontFamily: 'Quicksand',
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                              color: t.text)),
                    ],
                  ),
                ),
                // Bouton +Analyse Sang
                _HeaderBtn(
                  icon: Icons.bloodtype_outlined,
                  onTap: () => _openAddLab(0),
                  t: t,
                ),
                const SizedBox(width: 8),
                // Bouton +Analyse Calpro
                _HeaderBtn(
                  icon: Icons.science_outlined,
                  onTap: () => _openAddLab(1),
                  t: t,
                ),
              ],
            ),
          ),

          // ── Carte profil ────────────────────────────────────────────────────
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
                      // Avatar tappable
                      GestureDetector(
                        onTap: _openEditProfile,
                        child: _Avatar(user: _currentUser),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUser?.name ?? 'Chargement...',
                              style: const TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  height: 1.1),
                            ),
                            Text(
                              _currentUser?.diagnosis ?? 'MICI',
                              style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9)),
                            ),
                          ],
                        ),
                      ),
                      // Bouton édition
                      GestureDetector(
                        onTap: _openEditProfile,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_outlined,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const _StatBox(label: 'Jours suivis', value: '—'),
                      const SizedBox(width: 10),
                      _StatBox(label: 'Statut', value: _healthStatus),
                      const SizedBox(width: 10),
                      _StreakBox(streak: _streak),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Analyses ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text('MES ANALYSES',
                      style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: t.textDim)),
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

          // Liste des analyses
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
            child: currentLabsList.isEmpty
                ? _EmptyLabs(
                    isBlood: _labTab == 0,
                    onAdd: () => _openAddLab(_labTab),
                  )
                : Column(
                    children: currentLabsList.map((lab) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _LabCard(lab: lab, isBlood: _labTab == 0, t: t),
                      );
                    }).toList(),
                  ),
          ),

          // ── FAQ ─────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text('QUESTIONS FRÉQUENTES',
                      style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: t.textDim)),
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
                            onTap: () => setState(
                                () => _openFaq = isOpen ? -1 : e.key),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(e.value.q,
                                        style: TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: t.text)),
                                  ),
                                  AnimatedRotation(
                                    duration:
                                        const Duration(milliseconds: 240),
                                    turns: isOpen ? 0.5 : 0,
                                    child: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 14,
                                        color: t.textDim),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isOpen)
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 0, 14, 14),
                              child: Text(e.value.a,
                                  style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: t.textDim,
                                      height: 1.5)),
                            ),
                          if (!isLast)
                            Divider(
                                height: 1,
                                indent: 14,
                                endIndent: 14,
                                color: t.border),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // ── Déconnexion ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: GestureDetector(
              onTap: () => _confirmLogout(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.selles.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded,
                        size: 18, color: AppColors.sellesDeep),
                    const SizedBox(width: 8),
                    Text(
                      'Se déconnecter',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.sellesDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).padding.bottom + 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.t.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.logout_rounded, size: 36, color: AppColors.sellesDeep),
            const SizedBox(height: 12),
            Text(
              'Se déconnecter ?',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.t.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tu seras redirigé vers l\'écran d\'accueil.',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 13,
                color: context.t.textDim,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: context.t.bg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: context.t.border),
                      ),
                      child: Center(
                        child: Text('Annuler',
                            style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w600,
                                color: context.t.text)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await UserSession.clear();
                      if (mounted) context.go(AppRoutes.splash);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.sellesSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('Déconnecter',
                            style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w700,
                                color: AppColors.sellesDeep)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets internes ──────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final UserModel? user;
  const _Avatar({this.user});

  @override
  Widget build(BuildContext context) {
    final avatarBytes = user?.avatarUrl != null
        ? base64Decode(user!.avatarUrl!)
        : null;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        shape: BoxShape.circle,
        border: avatarBytes != null
            ? Border.all(color: Colors.white, width: 2)
            : null,
      ),
      child: ClipOval(
        child: avatarBytes != null
            ? Image.memory(avatarBytes, fit: BoxFit.cover)
            : Center(
                child: Text(
                  user?.initial ?? '?',
                  style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
      ),
    );
  }
}

class _LabCard extends StatelessWidget {
  final MedicalLab lab;
  final bool isBlood;
  final AppThemeExtension t;
  const _LabCard({required this.lab, required this.isBlood, required this.t});

  @override
  Widget build(BuildContext context) {
    final mainValue = isBlood ? lab.crp : lab.calprotectin;
    final mainLabel = isBlood ? 'CRP' : 'Calpro';
    final mainUnit = isBlood ? 'mg/L' : 'µg/g';
    final isNormal = isBlood
        ? (lab.crp != null && lab.crp! < 5.0)
        : (lab.calprotectin != null && lab.calprotectin! < 250.0);

    return PoopyCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 50,
                decoration: BoxDecoration(
                    color: AppColors.analysesSoft,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.description_outlined,
                    size: 22, color: AppColors.analysesDeep),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBlood ? 'Bilan inflammatoire' : 'Calprotectine fécale',
                      style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: t.text),
                    ),
                    Text(
                      '${DateFormat('dd MMMM yyyy', 'fr_FR').format(lab.date)} · ${lab.notes ?? 'Cerba'}',
                      style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: t.textDim),
                    ),
                    const SizedBox(height: 6),
                    if (mainValue != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isNormal
                              ? AppColors.rdvSoft
                              : AppColors.sellesSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$mainLabel : $mainValue $mainUnit',
                          style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isNormal
                                  ? AppColors.rdvDeep
                                  : AppColors.sellesDeep),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Champs supplémentaires sang (B12, B9, ferritine, fer)
          if (isBlood &&
              (lab.b12 != null ||
                  lab.b9 != null ||
                  lab.ferritin != null ||
                  lab.iron != null)) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (lab.b12 != null)
                  _MiniChip(label: 'B12', value: lab.b12!, unit: 'pg/mL',
                      normal: lab.b12! >= 200 && lab.b12! <= 900),
                if (lab.b9 != null)
                  _MiniChip(label: 'B9', value: lab.b9!, unit: 'µg/L',
                      normal: lab.b9! >= 3),
                if (lab.ferritin != null)
                  _MiniChip(label: 'Ferritine', value: lab.ferritin!, unit: 'ng/mL',
                      normal: lab.ferritin! >= 20 && lab.ferritin! <= 200),
                if (lab.iron != null)
                  _MiniChip(label: 'Fer', value: lab.iron!, unit: 'µmol/L',
                      normal: lab.iron! >= 10 && lab.iron! <= 30),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final bool normal;
  const _MiniChip(
      {required this.label,
      required this.value,
      required this.unit,
      required this.normal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: normal ? AppColors.rdvSoft : AppColors.sellesSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label : $value $unit',
        style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: normal ? AppColors.rdvDeep : AppColors.sellesDeep),
      ),
    );
  }
}

class _EmptyLabs extends StatelessWidget {
  final bool isBlood;
  final VoidCallback onAdd;
  const _EmptyLabs({required this.isBlood, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return PoopyCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            isBlood ? Icons.bloodtype_outlined : Icons.science_outlined,
            size: 32,
            color: t.textMuted,
          ),
          const SizedBox(height: 10),
          Text(
            isBlood
                ? 'Aucun bilan sanguin enregistré'
                : 'Aucune calprotectine enregistrée',
            style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: t.textDim),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.analysesSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Ajouter une analyse',
                style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.analysesDeep),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final AppThemeExtension t;
  const _HeaderBtn(
      {required this.icon, required this.onTap, required this.t});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: t.surface,
            shape: BoxShape.circle,
            border: Border.all(color: t.border)),
        child: Icon(icon, size: 18, color: t.text),
      ),
    );
  }
}

class _StreakBox extends StatelessWidget {
  final int streak;
  const _StreakBox({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department_rounded,
                    size: 16,
                    color: streak > 0
                        ? const Color(0xFFFF6B35)
                        : Colors.white.withOpacity(0.5)),
                const SizedBox(width: 3),
                Text(
                  streak > 0 ? '$streak j' : '0 j',
                  style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ],
            ),
            Text('Streak',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.85))),
          ],
        ),
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
            borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.85))),
          ],
        ),
      ),
    );
  }
}
