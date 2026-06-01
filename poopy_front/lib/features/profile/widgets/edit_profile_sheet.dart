import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/poopy_widgets.dart';
import '../services/profile_service.dart';
import '../../../core/constants/app_constants.dart';

class EditProfileSheet extends StatefulWidget {
  final UserModel user;
  final VoidCallback onSaved;

  const EditProfileSheet({super.key, required this.user, required this.onSaved});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  final ProfileService _service = ProfileService();
  final ImagePicker _picker = ImagePicker();

  String? _selectedDiagnosis;
  String? _pendingAvatarBase64;
  bool _isSaving = false;

  static const _diagnoses = [
    'Maladie de Crohn',
    'Rectocolite hémorragique (RCH)',
    'MICI indéterminée',
    'Syndrome de l\'intestin irritable',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _selectedDiagnosis = widget.user.diagnosis;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    Navigator.pop(context);
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 75,
      );
      if (picked != null) {
        final bytes = await File(picked.path).readAsBytes();
        setState(() => _pendingAvatarBase64 = base64Encode(bytes));
      }
    } catch (e) {
      print("❌ Erreur photo: $e");
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
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
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Prendre une photo',
                  style: TextStyle(fontFamily: 'Quicksand', fontWeight: FontWeight.w600)),
              onTap: () => _pickPhoto(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir depuis la galerie',
                  style: TextStyle(fontFamily: 'Quicksand', fontWeight: FontWeight.w600)),
              onTap: () => _pickPhoto(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _isSaving = true);

    final updated = await _service.updateUser(
      userId: AppConstants.currentUserId,
      name: _nameCtrl.text.trim(),
      diagnosis: _selectedDiagnosis,
      avatarUrl: _pendingAvatarBase64,
    );

    setState(() => _isSaving = false);

    if (mounted) {
      if (updated != null) {
        widget.onSaved();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la sauvegarde. Lance bunx prisma db push côté backend.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    // 100 = hauteur approximative de la nav bar flottante
    final bottomPad = keyboard > 0 ? keyboard + 16.0 : safeBottom + 100.0;

    final avatarBytes = _pendingAvatarBase64 != null
        ? base64Decode(_pendingAvatarBase64!)
        : (widget.user.avatarUrl != null && widget.user.avatarUrl!.isNotEmpty
            ? base64Decode(widget.user.avatarUrl!)
            : null);

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
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: t.border, borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text('Modifier le profil',
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: t.text)),
            const SizedBox(height: 20),

            // Avatar
            Center(
              child: GestureDetector(
                onTap: _showPhotoOptions,
                child: Stack(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.analyses.withOpacity(0.15),
                        border: Border.all(color: AppColors.analyses, width: 2),
                      ),
                      child: ClipOval(
                        child: avatarBytes != null
                            ? Image.memory(avatarBytes, fit: BoxFit.cover)
                            : Center(
                                child: Text(
                                  widget.user.initial,
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.analysesDeep,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 26, height: 26,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.analysesDeep,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nom
            PoopyTextField(
              label: 'Nom',
              placeholder: 'Ton prénom ou pseudo',
              controller: _nameCtrl,
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 14),

            // Diagnostic
            Text('Diagnostic',
                style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.textDim)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _diagnoses.contains(_selectedDiagnosis) ? _selectedDiagnosis : null,
                  hint: Text('Sélectionner...',
                      style: TextStyle(
                          fontFamily: 'Quicksand', fontSize: 14, color: t.textDim)),
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  borderRadius: BorderRadius.circular(14),
                  dropdownColor: t.surface,
                  items: _diagnoses.map((d) => DropdownMenuItem(
                    value: d,
                    child: Text(d,
                        style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: t.text)),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedDiagnosis = v),
                ),
              ),
            ),
            const SizedBox(height: 24),

            PoopyButton(
              label: _isSaving ? 'Sauvegarde...' : 'Sauvegarder',
              onPressed: _isSaving ? null : _save,
              disabled: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
