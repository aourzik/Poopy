import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_router.dart';
import '../../../shared/widgets/poopy_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
    _emailCtrl.addListener(() => setState(() {}));

    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  bool get _isValidEmail =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_emailCtrl.text);

  bool get _canSubmit =>
      _nameCtrl.text.trim().length >= 2 && _isValidEmail;

  void _submit() {
    if (_canSubmit) {
      // TODO: Call auth API here, then navigate
      context.go(AppRoutes.dashboard);
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
            // Decorative blob
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
                              // Mascot mini
                              Container(
                                width: 32, height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFEF7EF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text('💩', style: TextStyle(fontSize: 18)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Poopy',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: t.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 42), // Balance
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
                                'On fait connaissance\u00a0?',
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
                                'Deux infos suffisent pour démarrer.\nTes données restent chiffrées sur ton appareil.',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: t.textDim,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Fields
                              PoopyTextField(
                                label: "Nom d'utilisateur",
                                placeholder: 'Ex. Alex',
                                controller: _nameCtrl,
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 14),
                              PoopyTextField(
                                label: 'E-mail',
                                placeholder: 'alex@email.fr',
                                controller: _emailCtrl,
                                icon: Icons.notifications_none_rounded,
                                keyboardType: TextInputType.emailAddress,
                                isValid: _emailCtrl.text.isEmpty
                                    ? null
                                    : _isValidEmail,
                              ),
                              const SizedBox(height: 22),

                              // Consent box
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
                                      child: const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: AppColors.pinkDeep,
                                      ),
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
                                            const TextSpan(text: 'En continuant, j\'accepte les '),
                                            TextSpan(
                                              text: 'conditions d\'utilisation',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: t.text,
                                              ),
                                            ),
                                            const TextSpan(text: ' et la '),
                                            TextSpan(
                                              text: 'politique de confidentialité',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: t.text,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: '. Mes données médicales me restent strictement personnelles.',
                                            ),
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
                      22, 16, 22,
                      MediaQuery.of(context).padding.bottom + 20,
                    ),
                    child: PoopyButton(
                      label: 'Créer mon compte',
                      onPressed: _canSubmit ? _submit : null,
                      disabled: !_canSubmit,
                      trailing: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
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
