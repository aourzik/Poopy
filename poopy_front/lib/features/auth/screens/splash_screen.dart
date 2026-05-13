import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _slideUp = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.bg, t.bgGradientEnd],
          ),
        ),
        child: Stack(
          children: [
            // Decorative top blob
            Positioned(
              top: -80, left: -60, right: -60,
              child: Container(
                height: 320,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [AppColors.pink.withOpacity(0.2), Colors.transparent],
                    radius: 0.65,
                  ),
                ),
              ),
            ),
            // Decorative bottom-right blob
            Positioned(
              bottom: -60, right: -80,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.poids.withOpacity(0.13), Colors.transparent],
                    radius: 0.7,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
                child: Column(
                  children: [
                    // Beta tag
                    FadeTransition(
                      opacity: _fadeIn,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: t.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: t.border),
                        ),
                        child: const Text(
                          'V1.0 · BÊTA',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: AppColors.textDim,
                          ),
                        ),
                      ),
                    ),

                    // Logo block
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeIn,
                        child: SlideTransition(
                          position: _slideUp,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Mascot circle
                                Container(
                                  width: 218, height: 218,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFEF7EF),
                                    border: Border.all(color: t.text, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.pinkDeep.withOpacity(0.35),
                                        blurRadius: 60,
                                        offset: const Offset(0, 30),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  // TODO: Replace with your actual mascot image
                                  // child: ClipOval(child: Image.asset('assets/images/mascot.png', fit: BoxFit.cover)),
                                  child: const _MascotPlaceholder(),
                                ),
                                const SizedBox(height: 24),
                                // App name
                                Text(
                                  'Poopy',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 68,
                                    fontWeight: FontWeight.w600,
                                    color: t.text,
                                    letterSpacing: -0.5,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'TON ALLIÉ MICI\nAU QUOTIDIEN',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.4,
                                    color: t.textDim,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // CTA
                    FadeTransition(
                      opacity: _fadeIn,
                      child: Column(
                        children: [
                          // Primary button
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.register),
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [t.pink, t.pinkDeep],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: t.pinkDeep.withOpacity(0.4),
                                    blurRadius: 32,
                                    offset: const Offset(0, 14),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Commencer',
                                    style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Login link
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: t.textMuted,
                              ),
                              children: [
                                const TextSpan(text: "J'ai déjà un compte · "),
                                TextSpan(
                                  text: 'Se connecter',
                                  style: TextStyle(
                                    color: t.pinkDeep,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for the mascot until you add the real image
class _MascotPlaceholder extends StatelessWidget {
  const _MascotPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('💩', style: TextStyle(fontSize: 90)),
    );
  }
}
