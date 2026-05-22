import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_router.dart';
import '../../../shared/widgets/poopy_widgets.dart';
import '../../auth/services/user_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../journal/services/stool_service.dart';
import '../../journal/models/stool_model.dart';
import '../../medications/services/medication_service.dart';
import '../../../shared/models/models.dart';
import '../../appointments/services/appointment_service.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _currentUserName = "Chargement...";
  int? _selectedMood;
  bool _isLoading = true;

 int _todayStoolsCount = 0;
  String _todayStoolsDetail = "Aucune trace aujourd'hui";
  List<Map<String, dynamic>> _dynamicLast7 = [];

  int _takenMedsCount = 0;
  int _totalMedsCount = 0;
  String _nextMedText = "Aucun traitement prévu";

  Appointment? _nextAppointment;
  final List<String> _monthsList = ['JANV.', 'FÉVR.', 'MARS', 'AVR.', 'MAI', 'JUIN', 'JUIL.', 'AOÛT', 'SEPT.', 'OCT.', 'NOV.', 'DÉC.'];

  static const _moods = [
    (emoji: '😣', label: 'Crise', value: 1),
    (emoji: '😕', label: 'Difficile', value: 2),
    (emoji: '😐', label: 'Moyen', value: 3),
    (emoji: '🙂', label: 'Bien', value: 4),
    (emoji: '😄', label: 'Top', value: 5),
  ];

  @override
  void initState() {
    super.initState();
    _loadAllDashboardData();
  }

  Future<void> _loadUserName() async {
    final name = await UserService().getUserName(AppConstants.currentUserId);
    if (mounted) {
      setState(() {
        _currentUserName = name;
      });
    }
  }

  Future<void> _loadAllDashboardData() async {
    try {
      final userId = AppConstants.currentUserId;
      
      // 1. Charger le nom d'utilisateur
      final name = await UserService().getUserName(userId);
      
      // 2. Récupérer et calculer les données des selles (Journal)
      final stools = await StoolService().getStools(userId);
      final now = DateTime.now();
      
      int todayCount = 0;
      String todayDetail = "0 épisode";
      
      for (var s in stools) {
        if (s.date != null) {
          final localDate = s.date!.toLocal();
          if (localDate.year == now.year && localDate.month == now.month && localDate.day == now.day) {
            todayCount++;
            todayDetail = "Bristol ${s.bristol}${s.urgency ? ' · urgence' : ''}";
          }
        }
      }

      // Générer le mini-graphique des 7 derniers jours
      List<Map<String, dynamic>> tempLast7 = [];
      for (int i = 6; i >= 0; i--) {
        final dayIndex = now.subtract(Duration(days: i));
        int countForDay = stools.where((s) {
          if (s.date == null) return false;
          final d = s.date!.toLocal();
          return d.year == dayIndex.year && d.month == dayIndex.month && d.day == dayIndex.day;
        }).length;
        
        tempLast7.add({'day': dayIndex.day, 'count': countForDay});
      }

      // 3. Récupérer et calculer les données des médicaments
      final meds = await MedicationService().getMeds(userId);
      int takenCount = 0;
      int totalCount = meds.length;
      String nextMed = "Traitement à jour";

      for (var m in meds) {
        // 💾 FIX 1 : On force la valeur par défaut à 0 si takenToday ou totalToday sont nulls
        final taken = m.takenToday ?? 0;
        final total = m.totalToday ?? 0;
        
        takenCount += taken;
        if (taken < total) {
          nextMed = "Prochain : ${m.name}";
        }
      }

      // 4. Récupérer le prochain rendez-vous
      Appointment? upcomingAppt;
      try {
        final appointmentsMap = await AppointmentService().getAppointments(userId);
        
        // 💾 FIX 2 & 3 : On extrait tous les rendez-vous de la Map pour en faire une liste plate
        List<Appointment> allAppointments = [];
        appointmentsMap.forEach((key, list) {
          allAppointments.addAll(list);
        });

        final futureAppts = allAppointments.where((a) => a.date.isAfter(now)).toList();
        if (futureAppts.isNotEmpty) {
          futureAppts.sort((a, b) => a.date.compareTo(b.date));
          upcomingAppt = futureAppts.first; // Nom corrigé ici
        }
      } catch (e) {
        print("⚠️ Pas de service de RDV ou erreur : $e");
      }

      if (mounted) {
        setState(() {
          _currentUserName = name;
          _todayStoolsCount = todayCount;
          _todayStoolsDetail = todayDetail;
          _dynamicLast7 = tempLast7;
          _takenMedsCount = takenCount;
          _totalMedsCount = totalCount;
          _nextMedText = nextMed;
          _nextAppointment = upcomingAppt;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Erreur chargement dashboard : $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final today = DateTime.now();
    final dateStr = DateFormat('EEEE d MMMM', 'fr_FR').format(today);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.pinkDeep, strokeWidth: 3),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top + 20, 0, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER AVEC MASCOTTE ET NOTIFS ---
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFEF7EF),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pinkDeep.withOpacity(0.3),
                        blurRadius: 14, offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Transform.scale(
                      scale: 1.3,
                      child: Image.asset(
                        'assets/poopy_logo_dash.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.face),
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
                        dateStr[0].toUpperCase() + dateStr.substring(1),
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 13,
                          fontWeight: FontWeight.w500, color: t.textDim,
                        ),
                      ),
                      Text(
                        'Coucou, $_currentUserName',
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 24,
                          fontWeight: FontWeight.w500, color: t.text,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Cloche notifications
                Stack(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: t.surface, shape: BoxShape.circle,
                        border: Border.all(color: t.border),
                      ),
                      child: Icon(Icons.notifications_none_rounded, size: 20, color: t.text),
                    ),
                    Positioned(
                      top: 8, right: 9,
                      child: Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.selles, shape: BoxShape.circle,
                          border: Border.all(color: t.surface, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- SÉLECTEUR D'HUMEUR ---
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
                            color: isSelected ? AppColors.pink.withOpacity(0.2) : t.surface,
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
                                  fontFamily: 'Quicksand', fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppColors.pinkDeep : t.textDim,
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

          // --- CARTE SÈLLES DYNAMIQUE ---
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
                            const Icon(Icons.menu_book_rounded, size: 16, color: Colors.white70),
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
                            Text(
                              '$_todayStoolsCount',
                              style: const TextStyle(
                                fontFamily: 'Quicksand', fontSize: 44,
                                fontWeight: FontWeight.w700, color: Colors.white,
                                letterSpacing: -1, height: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                _todayStoolsCount > 1 ? 'épisodes' : 'épisode',
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
                          _todayStoolsDetail,
                          style: TextStyle(
                            fontFamily: 'Quicksand', fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sparkline Dynamique des 7 derniers jours
                  SizedBox(
                    width: 92, height: 60,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _dynamicLast7.asMap().entries.map((e) {
                        final isToday = e.key == 6;
                        final count = e.value['count'] as int;
                        final h = count == 0 ? 4.0 : (count / 5.0) * 50;
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: double.infinity,
                                    height: h.clamp(4.0, 50.0),
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(isToday ? 1.0 : 0.42),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${e.value['day']}',
                                style: TextStyle(
                                  fontSize: 9, color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w600, fontFamily: 'Quicksand',
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

          // --- RANGÉE POIDS + MÉDICAMENTS DYNAMIQUE ---
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: Row(
              children: [
                // Bloc Poids (Statique pour le moment)
                Expanded(
                  child: PoopyCard(
                    backgroundColor: AppColors.poids,
                    borderRadius: 24, padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 144,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'POIDS',
                                style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 12,
                                  fontWeight: FontWeight.w700, letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
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
                                      fontWeight: FontWeight.w700, color: Colors.white,
                                      letterSpacing: -0.5,
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
                // Bloc Médicaments Dynamique
                Expanded(
                  child: PoopyCard(
                    backgroundColor: AppColors.meds,
                    borderRadius: 24, padding: const EdgeInsets.all(16),
                    onTap: () => context.go(AppRoutes.medications),
                    child: SizedBox(
                      height: 144,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'MÉDICAMENTS',
                                style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 12,
                                  fontWeight: FontWeight.w700, letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(Icons.medication_rounded, size: 16, color: Colors.white),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$_takenMedsCount',
                                    style: const TextStyle(
                                      fontFamily: 'Quicksand', fontSize: 30,
                                      fontWeight: FontWeight.w700, color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '/ $_totalMedsCount pris',
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
                                _nextMedText,
                                style: TextStyle(
                                  fontFamily: 'Quicksand', fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.85),
                                  overflow: TextOverflow.ellipsis,
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

          // --- BANDEAU TENDANCE ---
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: PoopyCard(
              borderRadius: 20, padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.pink.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, size: 20, color: AppColors.pinkDeep),
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

          // --- PROCHAIN RDV AGENDA DYNAMIQUE ---
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
                  borderRadius: 22, padding: const EdgeInsets.all(16),
                  onTap: () => context.go(AppRoutes.appointments),
                  child: _nextAppointment == null
                      ? Center(
                          child: Text(
                            "Aucun rendez-vous planifié",
                            style: TextStyle(fontFamily: 'Quicksand', color: context.t.textDim),
                          ),
                        )
                      : Row(
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _monthsList[_nextAppointment!.date.month - 1],
                                    style: const TextStyle(
                                      fontFamily: 'Quicksand', fontSize: 10,
                                      fontWeight: FontWeight.w700, color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '${_nextAppointment!.date.day}',
                                    style: const TextStyle(
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
                                    _nextAppointment!.doctor,
                                    style: TextStyle(
                                      fontFamily: 'Quicksand', fontSize: 14.5,
                                      fontWeight: FontWeight.w700, color: context.t.text,
                                    ),
                                  ),
                                  Text(
                                    '${DateFormat('HH:mm').format(_nextAppointment!.date)} · ${_nextAppointment!.type}',
                                    style: TextStyle(
                                      fontFamily: 'Quicksand', fontSize: 12.5,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
