import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_router.dart';
import '../../../shared/widgets/poopy_widgets.dart';
import '../services/user_service.dart';
import '../../../core/services/user_session.dart';

class SetPasswordScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const SetPasswordScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _pwCtrl  = TextEditingController();
  final _pw2Ctrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  bool _isLoading = false;
  bool _obscure1  = true;
  bool _obscure2  = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pwCtrl.addListener(() => setState(() {}));
    _pw2Ctrl.addListener(() => setState(() {}));

    _animCtrl = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _pwCtrl.dispose();
    _pw2Ctrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _pwCtrl.text.length >= 8 &&
      _pwCtrl.text == _pw2Ctrl.text &&
      !_isLoading;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    if (_pwCtrl.text != _pw2Ctrl.text) {
      setState(() => _error = 'Les mots de passe ne correspondent pas.');
      return;
    }
    setState(() { _isLoading = true; _error = null; });

    final result = await UserService().setPassword(
      userId: widget.userId,
      password: _pwCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      await UserSession.save(widget.userId);
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
                    child: Row(
                      children: [
                        const SizedBox(width: 42),
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
                              const EyebrowLabel('Sécurité'),
                              const SizedBox(height: 8),
                              Text(
                                'Bonjour ${widget.userName} !',
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
                                'Pour sécuriser ton compte, choisis un mot de passe. Tu n\'auras à faire ça qu\'une seule fois.',
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
                                label: 'Mot de passe',
                                placeholder: '8 caractères minimum',
                                controller: _pwCtrl,
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscure1,
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() => _obscure1 = !_obscure1),
                                  child: Icon(
                                    _obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 18, color: t.textDim,
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
                                isValid: _pw2Ctrl.text.isEmpty
                                    ? null
                                    : _pwCtrl.text == _pw2Ctrl.text,
                                suffixIcon: GestureDetector(
                                  onTap: () => setState(() => _obscure2 = !_obscure2),
                                  child: Icon(
                                    _obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 18, color: t.textDim,
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        22, 16, 22, MediaQuery.of(context).padding.bottom + 20),
                    child: PoopyButton(
                      label: _isLoading ? 'Enregistrement...' : 'Créer mon mot de passe',
                      onPressed: _canSubmit ? _submit : null,
                      disabled: !_canSubmit,
                      trailing: _isLoading
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_rounded,
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
