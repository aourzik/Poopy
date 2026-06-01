import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/models.dart';
import '../services/medication_service.dart';
import '../../../core/constants/app_constants.dart';

class AddMedicationSheet extends StatefulWidget {
  const AddMedicationSheet({super.key});

  @override
  State<AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<AddMedicationSheet> {
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();

  int _takesCount = 1;
  String _period = 'jour';
  MedColor _selectedColor = MedColor.amber;
  bool _isInjection = false;

  static const _periods = ['jour', 'semaine', 'mois'];
  static const _periodLabels = {'jour': 'Par jour', 'semaine': 'Par semaine', 'mois': 'Par mois'};

  final List<String> _suggestions = [
    'Pentasa', 'Fivasa', 'Mezavant', 'Rowasa',
    'Imurel', 'Purinethol', 'Méthotrexate',
    'Humira', 'Remicade', 'Stelara', 'Entyvio',
    'Solupred', 'Entocort',
  ];

  String get _frequencyLabel {
    final take = _isInjection ? 'injection' : 'prise';
    final takes = _takesCount > 1 ? '${_isInjection ? 'injections' : 'prises'}' : take;
    return '$_takesCount $takes · $_period';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final bottomPad = keyboard > 0 ? keyboard + 16.0 : safeBottom + 100.0;

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: t.textMuted.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Nouveau traitement',
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: t.text)),
            const SizedBox(height: 20),

            // Nom avec autocomplete
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                return _suggestions.where((s) =>
                    s.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (selection) => _nameController.text = selection,
              fieldViewBuilder: (context, autocompleteController, focusNode, onFieldSubmitted) {
                autocompleteController.addListener(() {
                  _nameController.text = autocompleteController.text;
                });
                return TextField(
                  controller: autocompleteController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Nom du médicament',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Dosage + switch injection
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _doseController,
                    decoration: InputDecoration(
                      labelText: 'Dosage (ex: 500mg)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Text('Injection',
                        style: TextStyle(fontSize: 12, color: t.textDim)),
                    Switch(
                      value: _isInjection,
                      onChanged: (v) => setState(() => _isInjection = v),
                      activeColor: AppColors.meds,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sélecteur fréquence
            Text('Fréquence',
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: t.textDim)),
            const SizedBox(height: 10),

            Row(
              children: [
                // Sélecteur nombre de prises
                Container(
                  decoration: BoxDecoration(
                    color: t.bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.border),
                  ),
                  child: Row(
                    children: [
                      _CountBtn(
                        icon: Icons.remove_rounded,
                        onTap: _takesCount > 1
                            ? () => setState(() => _takesCount--)
                            : null,
                        t: t,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text('$_takesCount',
                            style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: t.text)),
                      ),
                      _CountBtn(
                        icon: Icons.add_rounded,
                        onTap: _takesCount < 8
                            ? () => setState(() => _takesCount++)
                            : null,
                        t: t,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Sélecteur période
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: t.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: t.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _period,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        borderRadius: BorderRadius.circular(14),
                        dropdownColor: t.surface,
                        items: _periods
                            .map((p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(
                                    _periodLabels[p]!,
                                    style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: t.text),
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _period = v!),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Aperçu fréquence
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.meds.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: AppColors.meds),
                  const SizedBox(width: 8),
                  Text(
                    _frequencyLabel,
                    style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.meds),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Couleur
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: MedColor.values.map((c) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: Container(
                    width: 35, height: 35,
                    decoration: BoxDecoration(
                      color: _getColor(c),
                      shape: BoxShape.circle,
                      border: _selectedColor == c
                          ? Border.all(color: t.text, width: 2)
                          : null,
                    ),
                    child: _selectedColor == c
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Bouton enregistrer
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.meds,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  if (_nameController.text.isEmpty) return;
                  final newMed = Medication(
                    name: _nameController.text,
                    dose: _doseController.text,
                    frequency: _frequencyLabel,
                    totalToday: _period == 'jour' ? _takesCount : 0,
                    isInjection: _isInjection,
                    color: _selectedColor,
                    takenToday: 0,
                  );
                  final success = await MedicationService()
                      .addMed(newMed, AppConstants.currentUserId);
                  if (success && mounted) Navigator.pop(context, true);
                },
                child: const Text(
                  'Enregistrer le traitement',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
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

class _CountBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final AppThemeExtension t;
  const _CountBtn({required this.icon, required this.onTap, required this.t});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            size: 20,
            color: onTap != null ? t.text : t.textMuted),
      ),
    );
  }
}
