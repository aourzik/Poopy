import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_router.dart';
import '../../../shared/widgets/poopy_widgets.dart';
import '../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
    _emailCtrl.addListener(() => setState(() {}));

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
    _animCtrl.dispose();
    super.dispose();
  }

  bool get _isValidEmail =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_emailCtrl.text);

  bool get _canSubmit =>
      _nameCtrl.text.trim().length >= 2 && _isValidEmail && !_isLoading;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() { _isLoading = true; _error = null; });

    final result = await UserService().login(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
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
                              const EyebrowLabel('Connexion'),
                              const SizedBox(height: 8),
                              Text(
                                'Content de te\nretrouver !',
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
                                'Entre ton nom d\'utilisateur et ton adresse mail pour accéder à ton espace.',
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
                      label: _isLoading ? 'Connexion...' : 'Me connecter',
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
