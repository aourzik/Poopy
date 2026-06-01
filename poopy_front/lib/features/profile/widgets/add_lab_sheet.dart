import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/poopy_widgets.dart';
import '../services/profile_service.dart';
import '../services/scan_service.dart';
import '../../../core/constants/app_constants.dart';

class AddLabSheet extends StatefulWidget {
  final VoidCallback onAdded;
  final int initialTab; // 0=Sang, 1=Calpro

  const AddLabSheet({super.key, required this.onAdded, this.initialTab = 0});

  @override
  State<AddLabSheet> createState() => _AddLabSheetState();
}

class _AddLabSheetState extends State<AddLabSheet> {
  final ProfileService _service = ProfileService();
  late int _tab;
  bool _isScanning = false;
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();

  // Blood fields
  final _crpCtrl = TextEditingController();
  final _b12Ctrl = TextEditingController();
  final _b9Ctrl = TextEditingController();
  final _ferritinCtrl = TextEditingController();
  final _ironCtrl = TextEditingController();

  // Calpro fields
  final _calproCtrl = TextEditingController();

  // Common
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  void dispose() {
    _crpCtrl.dispose();
    _b12Ctrl.dispose();
    _b9Ctrl.dispose();
    _ferritinCtrl.dispose();
    _ironCtrl.dispose();
    _calproCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _fillFromScan(ScannedLabResult result) {
    if (result.crp != null) _crpCtrl.text = result.crp!.toString();
    if (result.b12 != null) _b12Ctrl.text = result.b12!.toString();
    if (result.b9 != null) _b9Ctrl.text = result.b9!.toString();
    if (result.ferritin != null) _ferritinCtrl.text = result.ferritin!.toString();
    if (result.iron != null) _ironCtrl.text = result.iron!.toString();
    if (result.calprotectin != null) _calproCtrl.text = result.calprotectin!.toString();

    // Auto-switch tab si seule la calpro est trouvée
    if (result.hasCalproValues && !result.hasBloodValues) {
      setState(() => _tab = 1);
    } else if (result.hasBloodValues) {
      setState(() => _tab = 0);
    }
  }

  Future<void> _scanWith(ImageSource source) async {
    Navigator.pop(context); // Ferme le menu source
    setState(() => _isScanning = true);

    ScannedLabResult? result;
    if (source == ImageSource.camera) {
      result = await LabScanService.scanFromCamera();
    } else {
      result = await LabScanService.scanFromGallery();
    }

    setState(() => _isScanning = false);

    if (result == null || result.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucune valeur détectée. Essaie avec une meilleure photo.'),
          ),
        );
      }
      return;
    }

    _fillFromScan(result);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Valeurs détectées ! Vérifie avant de sauvegarder.',
            style: const TextStyle(fontFamily: 'Quicksand'),
          ),
          backgroundColor: AppColors.analysesDeep,
        ),
      );
    }
  }

  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.t.border, borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Scanner une analyse',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.t.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Prends en photo ton bilan ou importe-le depuis la galerie.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 12,
                color: context.t.textDim,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Prendre en photo',
                  style: TextStyle(fontFamily: 'Quicksand', fontWeight: FontWeight.w600)),
              onTap: () => _scanWith(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Importer depuis la galerie',
                  style: TextStyle(fontFamily: 'Quicksand', fontWeight: FontWeight.w600)),
              onTap: () => _scanWith(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final isBlood = _tab == 0;
    final success = await _service.addLab(
      userId: AppConstants.currentUserId,
      type: isBlood ? LabType.blood : LabType.calprotectin,
      crp: double.tryParse(_crpCtrl.text),
      b12: double.tryParse(_b12Ctrl.text),
      b9: double.tryParse(_b9Ctrl.text),
      ferritin: double.tryParse(_ferritinCtrl.text),
      iron: double.tryParse(_ironCtrl.text),
      calprotectin: double.tryParse(_calproCtrl.text),
      notes: _notesCtrl.text,
      date: _selectedDate,
    );

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        widget.onAdded();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la sauvegarde')),
        );
      }
    }
  }

  Widget _numField(TextEditingController ctrl, String label, String unit) {
    final t = context.t;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: PoopyTextField(
              label: label,
              placeholder: '0.0',
              controller: ctrl,
              icon: Icons.science_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: t.border),
            ),
            child: Text(unit,
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.textDim)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final bottomPad = keyboard > 0 ? keyboard + 16.0 : safeBottom + 100.0;

    return Container(
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPad),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: t.border, borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header avec bouton scan
              Row(
                children: [
                  Expanded(
                    child: Text('Ajouter une analyse',
                        style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: t.text)),
                  ),
                  GestureDetector(
                    onTap: _isScanning ? null : _showScanOptions,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.analysesSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.analyses.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isScanning)
                            const SizedBox(
                              width: 14, height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.analysesDeep),
                            )
                          else
                            const Icon(Icons.document_scanner_outlined,
                                size: 16, color: AppColors.analysesDeep),
                          const SizedBox(width: 6),
                          Text(
                            _isScanning ? 'Scan...' : 'Scanner',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.analysesDeep,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Onglets Sang / Calpro
              PoopySegmented(
                options: const ['Sang', 'Calpro'],
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
                accentColor: AppColors.analyses,
              ),
              const SizedBox(height: 16),

              // Date
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 18, color: t.textDim),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('dd MMMM yyyy', 'fr_FR').format(_selectedDate),
                        style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: t.text),
                      ),
                      const Spacer(),
                      Icon(Icons.edit_outlined, size: 16, color: t.textDim),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Champs selon l'onglet
              if (_tab == 0) ...[
                _numField(_crpCtrl, 'CRP', 'mg/L'),
                _numField(_b12Ctrl, 'Vitamine B12', 'pg/mL'),
                _numField(_b9Ctrl, 'Vitamine B9 / Folate', 'µg/L'),
                _numField(_ferritinCtrl, 'Ferritine', 'ng/mL'),
                _numField(_ironCtrl, 'Fer sérique', 'µmol/L'),
              ] else ...[
                _numField(_calproCtrl, 'Calprotectine fécale', 'µg/g'),
              ],

              // Notes
              PoopyTextField(
                label: 'Notes (optionnel)',
                placeholder: 'Laboratoire, contexte...',
                controller: _notesCtrl,
                icon: Icons.notes_outlined,
              ),
              const SizedBox(height: 20),

              PoopyButton(
                label: _isSaving ? 'Sauvegarde...' : 'Ajouter l\'analyse',
                onPressed: _isSaving ? null : _save,
                disabled: _isSaving,
              ),
            ],
          ),
        ),
    );
  }
}
