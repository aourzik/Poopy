import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_router.dart';
import '../../../shared/widgets/poopy_widgets.dart';
import '../services/user_service.dart';
import 'terms_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl    = TextEditingController();
  final _pw2Ctrl   = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  String? _selectedDiagnosis;
  bool _isLoading = false;
  bool _obscure1  = true;
  bool _obscure2  = true;
  String? _error;

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
    _nameCtrl.addListener(() => setState(() {}));
    _emailCtrl.addListener(() => setState(() {}));
    _pwCtrl.addListener(() => setState(() {}));
    _pw2Ctrl.addListener(() => setState(() {}));

    _animCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _pw2Ctrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  bool get _isValidEmail =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_emailCtrl.text);

  bool get _canSubmit =>
      _nameCtrl.text.trim().length >= 2 &&
      _isValidEmail &&
      _pwCtrl.text.length >= 8 &&
      _pwCtrl.text == _pw2Ctrl.text &&
      _selectedDiagnosis != null &&
      !_isLoading;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() { _isLoading = true; _error = null; });

    final result = await UserService().register(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _pwCtrl.text,
      diagnosis: _selectedDiagnosis,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      context.go(AppRoutes.dashboard);
    } else {
      setState(() => _error = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.bg, t.bgGradientEnd],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60, right: -80,
              child: Container(
                width: 280, height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.pink.withOpacity(0.27), Colors.transparent],
                    radius: 0.65,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: t.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: t.border),
                            ),
                            child: Icon(Icons.chevron_left_rounded, color: t.text),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFEF7EF),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Transform.scale(
                                    scale: 1.3,
                                    child: Image.asset(
                                      'assets/poopy_logo_dash.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('Poopy',
                                  style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: t.text)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 42),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(26, 24, 26, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const EyebrowLabel('Bienvenue'),
                              const SizedBox(height: 8),
                              Text(
                                'On fait connaissance ?',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w500,
                                  color: t.text,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Quelques infos pour personnaliser ton expérience.',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: t.textDim,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 28),

                              PoopyTextField(
                                label: 'Nom d\'utilisateur',
                                placeholder: 'Ton prénom ou pseudo',
                                controller: _nameCtrl,
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 14),
                              PoopyTextField(
                                label: 'Adresse e-mail',
                                placeholder: 'ton@email.fr',
                                controller: _emailCtrl,
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                isValid: _emailCtrl.text.isEmpty ? null : _isValidEmail,
                              ),
                              const SizedBox(height: 14),
                              PoopyTextField(
                                label: 'Mot de passe',
                                placeholder: '8 caractères minimum',
                                controller: _pwCtrl,
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscure1,
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() => _obscure1 = !_obscure1),
                                  child: Icon(
                                    _obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 18, color: context.t.textDim,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              PoopyTextField(
                                label: 'Confirme le mot de passe',
                                placeholder: 'Répète ton mot de passe',
                                controller: _pw2Ctrl,
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscure2,
                                isValid: _pw2Ctrl.text.isEmpty ? null : _pwCtrl.text == _pw2Ctrl.text,
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() => _obscure2 = !_obscure2),
                                  child: Icon(
                                    _obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 18, color: context.t.textDim,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Sélecteur maladie
                              Text('Ta maladie',
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
                                  border: Border.all(
                                    color: _selectedDiagnosis != null
                                        ? AppColors.pink
                                        : t.border,
                                    width: _selectedDiagnosis != null ? 1.5 : 1,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedDiagnosis,
                                    hint: Text('Sélectionner ta maladie...',
                                        style: TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontSize: 14,
                                            color: t.textDim)),
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

                              if (_error != null) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.sellesSoft,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded,
                                          size: 16, color: AppColors.sellesDeep),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(_error!,
                                            style: const TextStyle(
                                                fontFamily: 'Quicksand',
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.sellesDeep)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 22),

                              // Mention RGPD
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: t.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: t.border),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 22, height: 22,
                                      decoration: BoxDecoration(
                                        color: AppColors.pink.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: const Icon(Icons.check_rounded,
                                          size: 14, color: AppColors.pinkDeep),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                            color: t.textDim,
                                            height: 1.45,
                                          ),
                                          children: [
                                            const TextSpan(text: 'En continuant, tu acceptes les '),
                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => const TermsScreen(),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'conditions d\'utilisation',
                                                  style: TextStyle(
                                                    fontFamily: 'Quicksand',
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.pinkDeep,
                                                    height: 1.45,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const TextSpan(text: '. Tes données médicales te restent strictement personnelles.'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Submit
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        22, 16, 22, MediaQuery.of(context).padding.bottom + 20),
                    child: PoopyButton(
                      label: _isLoading ? 'Création...' : 'Créer mon compte',
                      onPressed: _canSubmit ? _submit : null,
                      disabled: !_canSubmit,
                      trailing: _isLoading
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
