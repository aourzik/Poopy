import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour formater les dates proprement
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/poopy_widgets.dart';
import '../../../shared/models/models.dart';
import '../../../core/constants/app_constants.dart';
import '../services/appointment_service.dart';
import '../widgets/add_appointment_sheet.dart';

class AppointmentsScreen extends StatefulWidget { // On passe en StatefulWidget
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  // --- TES NOUVELLES VARIABLES ---
  final AppointmentService _service = AppointmentService();
  List<Appointment> _upcoming = [];
  List<Appointment> _past = [];
  bool _isLoading = true;

  static const _months = ['JAN','FÉV','MAR','AVR','MAI','JUN','JUL','AOÛ','SEP','OCT','NOV','DÉC'];

  @override
  void initState() {
    super.initState();
    _loadData(); // On charge les données au démarrage
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await _service.getAppointments(AppConstants.currentUserId);
    setState(() {
      _upcoming = data['upcoming'] ?? [];
      _past = data['past'] ?? [];
      _isLoading = false;
    });
  }

  // Ta fonction pour les pop-ups
  void _showInfoPopup(String title, String? content) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20), // Marge sur les côtés
      child: Container(
        // On définit une contrainte de hauteur pour qu'elle soit bien visible
        constraints: BoxConstraints(
          minHeight: 200, 
          maxHeight: MediaQuery.of(context).size.height * 0.6, // Max 60% de l'écran
        ),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: context.t.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // S'adapte au contenu
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la pop-up
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.rdv,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: context.t.textMuted),
                ),
              ],
            ),
            const Divider(height: 30),
            
            // Corps du texte (Scrollable si le texte est très long)
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  content ?? "Aucune information enregistrée.",
                  style: TextStyle(
                    color: context.t.text,
                    fontSize: 16,
                    height: 1.6,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Bouton de fermeture en bas
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rdvSoft,
                  foregroundColor: AppColors.rdvDeep,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("J'ai compris", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    
    // On récupère le premier RDV s'il existe
    final next = _upcoming.isNotEmpty ? _upcoming.first : null;

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
                // Remplace ton Container par ce bloc :
                GestureDetector(
                  onTap: () async {
                    final newAppt = await showModalBottomSheet<Appointment>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const AddAppointmentSheet(),
                    );
                    if (newAppt != null) {
                      await _service.addAppointment(newAppt, AppConstants.currentUserId);
                      _loadData(); // On rafraîchit la liste après l'ajout
                    }
                  },
                  child: Container(
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
                ),
              ],
            ),
          ),

          // Hero next appointment
        if (next != null)
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
                              DateFormat('HH:mm').format(next.date),
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
                              onPressed: () => _showInfoPopup("Détails du rendez-vous", next.notes),
                            ),
                            const SizedBox(height: 6),
                            _ApptActionBtn(
                              label: 'Préparer la visite',
                              bg: Colors.white.withOpacity(0.2),
                              textColor: Colors.white,
                              onPressed: () => _showInfoPopup("Ma préparation", next.preparation),
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
    onTap: () => _showInfoPopup("Détails", a.notes), // Optionnel : ouvrir les détails au clic
    child: Row(
      children: [
        _buildSmallDateBox(a), // Ta petite boîte de date à gauche
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.doctor, style: TextStyle(fontFamily: 'Quicksand', fontSize: 14, fontWeight: FontWeight.w700, color: t.text)),
              // ICI : On utilise DateFormat pour l'heure
              Text('${DateFormat('HH:mm').format(a.date)} · ${a.type}', 
                style: TextStyle(fontFamily: 'Quicksand', fontSize: 11.5, fontWeight: FontWeight.w500, color: t.textDim)),
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
  Widget _buildSmallDateBox(Appointment a) {
  return Container(
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
  );
}
Widget _buildDateBox(Appointment next) {
  return Container(
    width: 64, height: 70,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.22),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Le mois
        Text(
          _months[next.date.month - 1],
          style: TextStyle(
            fontFamily: 'Quicksand', fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        // Le jour
        Text(
          '${next.date.day}',
          style: const TextStyle(
            fontFamily: 'Quicksand', fontSize: 26,
            fontWeight: FontWeight.w700, color: Colors.white,
            height: 1,
          ),
        ),
        // L'heure (dynamique !)
        Text(
          DateFormat('HH:mm').format(next.date),
          style: TextStyle(
            fontFamily: 'Quicksand', fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
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
  final VoidCallback onPressed; // <--- AJOUTE ÇA

  const _ApptActionBtn({
    required this.label, 
    required this.bg, 
    required this.textColor,
    required this.onPressed, // <--- AJOUTE ÇA
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // <--- ON AJOUTE LE GESTURE DETECTOR ICI
      onTap: onPressed,
      child: Container(
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
