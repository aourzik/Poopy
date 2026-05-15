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
  int _frequency = 1;
  MedColor _selectedColor = MedColor.amber;
  bool _isInjection = false;

  final List<String> _suggestions = [
    'Pentasa', 'Fivasa', 'Mezavant', 'Rowasa', 
    'Imurel', 'Purinethol', 'Méthotrexate', 
    'Humira', 'Remicade', 'Stelara', 'Entyvio',
    'Solupred', 'Entocort'
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Petite barre de drag en haut
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: t.textMuted.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Nouveau traitement', 
                  style: TextStyle(
                    fontFamily: 'Quicksand', 
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: t.text
                  )
                ),
                const SizedBox(height: 20),

                // Champ Nom avec suggestions
                Autocomplete<String>(
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                    return _suggestions.where((s) => s.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (selection) => _nameController.text = selection,
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Nom du médicament',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
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
                        Text('Injection', style: TextStyle(fontSize: 12, color: t.textDim)),
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
                
                Text('Nombre de prises par jour : $_frequency', 
                  style: TextStyle(fontWeight: FontWeight.w600, color: t.text)),
                Slider(
                  value: _frequency.toDouble(),
                  min: 1, max: 6, divisions: 5,
                  label: _frequency.toString(),
                  onChanged: (v) => setState(() => _frequency = v.round()),
                ),

                const SizedBox(height: 20),
                
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
                          border: _selectedColor == c ? Border.all(color: t.text, width: 2) : null,
                        ),
                        child: _selectedColor == c 
                          ? const Icon(Icons.check, size: 20, color: Colors.white) 
                          : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),
                
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.meds,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)
                      ),
                    ),
                    onPressed: () async { // <--- async ici
  if (_nameController.text.isEmpty) return;

  final newMed = Medication(
    name: _nameController.text,
    dose: _doseController.text,
    frequency: '$_frequency prise(s)/jour',
    totalToday: _frequency,
    isInjection: _isInjection,
    color: _selectedColor,
    takenToday: 0,
  );

  final service = MedicationService();
  
  // ICI : On attend que le serveur réponde avant de fermer
  final success = await service.addMed(newMed, AppConstants.currentUserId);

  if (success && mounted) {
    Navigator.pop(context, true); // Le 'true' dit à l'écran précédent de se rafraîchir
  }
},
                    child: const Text(
                      'Enregistrer le traitement', 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ],
            ),
          ),
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