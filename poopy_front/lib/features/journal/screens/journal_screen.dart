import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// Fichiers locaux
import 'package:poopy/features/journal/models/stool_model.dart';
import 'package:poopy/features/journal/services/stool_service.dart';
import 'package:poopy/core/constants/app_constants.dart';
import '../../../../core/constants/app_constants.dart';

// Design
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/poopy_widgets.dart';
import '../widgets/day_detail_card.dart';
import '../widgets/add_entry_sheet.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  // Variables calendrier
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  
  // Nouvelles variables pour les données réelles
  Map<DateTime, Stool> _entries = {};
  bool _isLoading = true; // Pour afficher le loader au début

  @override
  void initState() {
    super.initState();
    _refreshData(); // On charge les données dès l'ouverture
  }

  // Fonction magique qui va chercher tes données sur Neon
  Future<void> _refreshData() async {
    try {
      print("🛰️ Synchronisation Neon en cours...");
      
      // On récupère les données
      final stools = await StoolService().getStools(AppConstants.currentUserId);
      print("📊 Serveur a renvoyé ${stools.length} selles.");

      final Map<DateTime, Stool> loadedEntries = {};
      
      for (var s in stools) {
      if (s.date != null) {
        // .toLocal() est crucial ici pour gérer le décalage Neon/Téléphone
        final localDate = s.date!.toLocal(); 
        final dayKey = DateTime(localDate.year, localDate.month, localDate.day);
        
        loadedEntries[dayKey] = s;
        print("📍 Point ajouté pour : $dayKey"); // Log de vérification
      }
    }

      // On met à jour l'UI
      setState(() {
        _entries = loadedEntries;
        _isLoading = false;
      });
      
      print("✅ UI mise à jour avec ${loadedEntries.length} points sur le calendrier.");
    } catch (e) {
      print("❌ Erreur lors du refresh : $e");
      setState(() => _isLoading = false);
    }
  }

  Stool? get _selectedEntry {
    final key = DateTime(
      _selectedDay.year, _selectedDay.month, _selectedDay.day,
    );
    return _entries[key];
  }

  Color _colorForEntry(Stool e) {
    if (e.blood) return AppColors.selles;
    if (e.bristol >= 5 || e.urgency) return AppColors.meds;
    if (e.bristol == 3 || e.bristol == 4) return AppColors.rdv;
    return AppColors.poids;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    // Si on charge, on affiche un rond qui tourne au milieu de l'écran
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.selles,
          strokeWidth: 3,
        ),
      );
    }

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
                      const EyebrowLabel('Journal de selles'),
                      Text(
                        'Mes traces',
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 26,
                          fontWeight: FontWeight.w500, color: t.text,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showAddSheet(),
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.selles,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.selles.withOpacity(0.4),
                          blurRadius: 16, offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),

          // Calendar card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: PoopyCard(
              borderRadius: 26,
              padding: const EdgeInsets.all(14),
              child: TableCalendar(
                firstDay: DateTime(2024, 1, 1),
                lastDay: DateTime(2027, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                onFormatChanged: (f) => setState(() => _calendarFormat = f),
                onPageChanged: (f) => setState(() => _focusedDay = f),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontFamily: 'Quicksand', fontSize: 19,
                    fontWeight: FontWeight.w500, color: t.text,
                  ),
                  leftChevronIcon: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.border),
                    ),
                    child: Icon(Icons.chevron_left_rounded, color: t.text),
                  ),
                  rightChevronIcon: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.border),
                    ),
                    child: Icon(Icons.chevron_right_rounded, color: t.text),
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    fontFamily: 'Quicksand', fontSize: 10.5,
                    fontWeight: FontWeight.w700, color: t.textMuted,
                    letterSpacing: 0.5,
                  ),
                  weekendStyle: TextStyle(
                    fontFamily: 'Quicksand', fontSize: 10.5,
                    fontWeight: FontWeight.w700, color: t.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(
                    fontFamily: 'Quicksand', fontSize: 13,
                    fontWeight: FontWeight.w500, color: t.text,
                  ),
                  weekendTextStyle: TextStyle(
                    fontFamily: 'Quicksand', fontSize: 13,
                    fontWeight: FontWeight.w500, color: t.text,
                  ),
                  todayTextStyle: TextStyle(
                    fontFamily: 'Quicksand', fontSize: 13,
                    fontWeight: FontWeight.w700, color: AppColors.pinkDeep,
                  ),
                  todayDecoration: BoxDecoration(
                    border: Border.all(color: AppColors.pinkDeep, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  selectedTextStyle: const TextStyle(
                    fontFamily: 'Quicksand', fontSize: 13,
                    fontWeight: FontWeight.w700, color: Colors.white,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: t.text,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.selles,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                  markerSize: 5,
                  markerMargin: const EdgeInsets.only(top: 1),
                  cellMargin: const EdgeInsets.all(2),
                  defaultDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  weekendDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final key = DateTime(day.year, day.month, day.day);
                    final entry = _entries[key];

                      if (entry == null) return null;

  // On détermine la couleur selon tes critères
                      final color = _colorForEntry(entry);
  
  // LOG DE SÉCURITÉ : Pour être sûr que le code passe ici
                      print("🎨 Dessin des points pour Bristol ${entry.bristol} le ${key.day}");

                    return Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
        // On dessine toujours au moins un point si l'entrée existe
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            ),
                          ),
        // Si urgence ou sang, on peut ajouter un deuxième point par exemple
                          if (entry.blood || entry.urgency) 
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(left: 2),
                              decoration: const BoxDecoration(
                                color: Colors.orange, // Un point orange d'alerte
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 12, 26, 8),
            child: Wrap(
              spacing: 14,
              children: const [
                _LegendDot(color: AppColors.rdv, label: 'OK'),
                _LegendDot(color: AppColors.poids, label: 'À surveiller'),
                _LegendDot(color: AppColors.meds, label: 'Alerte'),
                _LegendDot(color: AppColors.selles, label: 'Sang'),
              ],
            ),
          ),

          // Day detail
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
            child: _selectedEntry != null
                ? DayDetailCard(
                    date: _selectedDay,
                    entry: _selectedEntry!,
                    onEdit: () => _showAddSheet(),
                  )
                : _EmptyDayCard(
                    date: _selectedDay,
                    onAdd: () => _showAddSheet(),
                  ),
          ),

          // Month summary
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'RÉSUMÉ DU MOIS',
                    style: TextStyle(
                      fontFamily: 'Quicksand', fontSize: 12,
                      fontWeight: FontWeight.w700, letterSpacing: 0.5,
                      color: context.t.textDim,
                    ),
                  ),
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.8,
                  children: [
                    _SummaryCard(
                      title: 'Total épisodes',
                      value: '16',
                      sub: '9 jours actifs',
                    ),
                    _SummaryCard(
                      title: 'Bristol moyen',
                      value: '3.6',
                      sub: 'idéal entre 3-4',
                    ),
                    _SummaryCard(
                      title: 'Jours avec sang',
                      value: '3',
                      valueColor: AppColors.selles,
                    ),
                    _SummaryCard(
                      title: "Jours d'urgence",
                      value: '4',
                      valueColor: AppColors.meds,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet() async {
    // On ajoute 'final result =' et on attend la fermeture avec 'await'
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEntrySheet(
        date: _selectedDay,
        initial: _selectedEntry,
        onSave: (entry) {
          // Ce callback peut rester vide si ton service gère l'enregistrement
        },
      ),
    );

    // ICI : On ne rafraîchit que si result est true (succès)
    if (result == true) {
      await Future.delayed(const Duration(milliseconds: 300));
      await _refreshData();
    }
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(
          fontFamily: 'Quicksand', fontSize: 11,
          fontWeight: FontWeight.w600, color: context.t.textDim,
        )),
      ],
    );
  }
}

class _EmptyDayCard extends StatelessWidget {
  final DateTime date;
  final VoidCallback onAdd;

  const _EmptyDayCard({required this.date, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final dateStr = DateFormat('EEEE d MMMM', 'fr_FR').format(date);
    return PoopyCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            dateStr.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Quicksand', fontSize: 11,
              fontWeight: FontWeight.w700, color: t.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune entrée',
            style: TextStyle(
              fontFamily: 'Quicksand', fontSize: 18,
              fontWeight: FontWeight.w500, color: t.text,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.selles,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Ajouter pour ce jour',
                    style: TextStyle(
                      fontFamily: 'Quicksand', fontSize: 13,
                      fontWeight: FontWeight.w700, color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? sub;
  final Color? valueColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    this.sub,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return PoopyCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(
            fontFamily: 'Quicksand', fontSize: 11.5,
            fontWeight: FontWeight.w600, color: t.textDim,
          )),
          const Spacer(),
          Text(value, style: TextStyle(
            fontFamily: 'Quicksand', fontSize: 22,
            fontWeight: FontWeight.w700,
            color: valueColor ?? t.text,
          )),
          if (sub != null)
            Text(sub!, style: TextStyle(
              fontFamily: 'Quicksand', fontSize: 10.5,
              fontWeight: FontWeight.w600, color: t.textMuted,
            )),
        ],
      ),
    );
  }
}