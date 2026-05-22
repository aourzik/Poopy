import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poopy/features/journal/models/stool_model.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/poopy_widgets.dart';
import 'bristol_scale.dart';
import '../models/stool_model.dart';
import '../services/stool_service.dart';
import '../../../../core/constants/app_constants.dart';

class AddEntrySheet extends StatefulWidget {
  final DateTime date;
  final Stool? initial;
  final ValueChanged<Stool> onSave;

  const AddEntrySheet({
    super.key,
    required this.date,
    this.initial,
    required this.onSave,
  });

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  late int _bristol;
  late bool _blood;
  late bool _urgency;
  late int _count;

  @override
  void initState() {
    super.initState();
    _bristol = widget.initial?.bristol ?? 3;
    _blood = widget.initial?.blood ?? false;
    _urgency = widget.initial?.urgency ?? false;
    _count = widget.initial?.count ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final dateStr = DateFormat('EEEE d MMMM', 'fr_FR').format(widget.date);

    return Container(
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: const Border(
          top: BorderSide(color: AppColors.selles, width: 3),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        22, 18, 22,
        MediaQuery.of(context).viewInsets.bottom + 120,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: t.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header
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
                        'Nouvelle entrée',
                        style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 20,
                          fontWeight: FontWeight.w500, color: t.text,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: t.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: t.border),
                    ),
                    child: Icon(Icons.close_rounded, size: 16, color: t.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bristol scale
            Text(
              'Forme · échelle de Bristol',
              style: TextStyle(
                fontFamily: 'Quicksand', fontSize: 12,
                fontWeight: FontWeight.w700, letterSpacing: 0.3,
                color: t.textDim,
              ),
            ),
            const SizedBox(height: 10),
            BristolScale(
              value: _bristol,
              onChanged: (v) => setState(() => _bristol = v),
            ),
            const SizedBox(height: 16),

            // Count
            Text(
              "Nombre d'épisodes",
              style: TextStyle(
                fontFamily: 'Quicksand', fontSize: 12,
                fontWeight: FontWeight.w700, letterSpacing: 0.3,
                color: t.textDim,
              ),
            ),
            const SizedBox(height: 10),
            PoopyStepper(
              value: _count,
              onChanged: (v) => setState(() => _count = v),
              color: AppColors.selles,
            ),
            const SizedBox(height: 16),

            // Toggles
            ToggleRow(
              icon: Icons.water_drop_outlined,
              color: AppColors.selles,
              label: 'Présence de sang',
              subtitle: 'Trace visible dans les selles',
              value: _blood,
              onChanged: (v) => setState(() => _blood = v),
            ),
            const SizedBox(height: 10),
            ToggleRow(
              icon: Icons.local_fire_department_outlined,
              color: AppColors.meds,
              label: 'Faux besoin / urgence',
              subtitle: 'Besoin pressant mais sans résultat',
              value: _urgency,
              onChanged: (v) => setState(() => _urgency = v),
            ),
            const SizedBox(height: 18),

            // Save
            PoopyButton(
              label: 'Enregistrer',
              color: AppColors.selles,
              onPressed: () async {
    // 1. On prépare l'objet avec la DATE du calendrier
                final stoolData = Stool(
      // Si on modifie, on garde l'ID existant, sinon null (le serveur en créera un)
                  id: widget.initial?.id, 
                  userId: AppConstants.currentUserId,
                  bristol: _bristol,
                  count: _count,
                  blood: _blood,
                  urgency: _urgency,
                  date: widget.date, // <--- C'EST CA QUI PERMET DE SAUVER POUR HIER !
                );

    // 2. On appelle le service (saveStool doit gérer l'ID interne)
                final success = await StoolService().saveStool(stoolData);

                if (success) {
                  if (mounted) Navigator.pop(context, true);
                  print("💩 Données synchronisées avec Neon !");
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Erreur de connexion au serveur ❌")),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}