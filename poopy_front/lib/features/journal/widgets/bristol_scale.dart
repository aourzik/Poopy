import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BristolScale extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const BristolScale({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _types = [
    (v: 1, label: 'Dur',     color: Color(0xFF8B4F2E)),
    (v: 2, label: 'Lompé',   color: Color(0xFFA56336)),
    (v: 3, label: 'Normal',  color: AppColors.rdv),
    (v: 4, label: 'Mou',     color: AppColors.meds),
    (v: 5, label: 'Liquide', color: AppColors.selles),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _types.map((t) {
        final isActive = value == t.v;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(t.v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
              decoration: BoxDecoration(
                color: isActive ? t.color.withOpacity(0.13) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive ? t.color : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  _BristolGlyph(kind: t.v, color: t.color),
                  const SizedBox(height: 6),
                  Text(
                    '${t.v} · ${t.label}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: isActive ? t.color : t.color.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BristolGlyph extends StatelessWidget {
  final int kind;
  final Color color;

  const _BristolGlyph({required this.kind, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44, height: 31,
      child: CustomPaint(
        painter: _GlyphPainter(kind: kind, color: color),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  final int kind;
  final Color color;

  _GlyphPainter({required this.kind, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    switch (kind) {
      case 1: // nuggets
        for (final c in [
          Offset(10, 20), Offset(20, 16), Offset(30, 22),
          Offset(38, 18), Offset(14, 26),
        ]) {
          canvas.drawCircle(c, kind == 1 ? 4 : 3.5, paint);
        }
      case 2: // lumpy log
        final path = Path();
        path.moveTo(4, 18);
        path.cubicTo(8, 12, 14, 14, 14, 14);
        path.cubicTo(18, 8, 24, 12, 24, 12);
        path.cubicTo(30, 8, 34, 14, 34, 14);
        path.cubicTo(40, 12, 42, 18, 42, 18);
        path.cubicTo(40, 24, 34, 22, 34, 22);
        path.cubicTo(30, 26, 24, 22, 24, 22);
        path.cubicTo(18, 26, 14, 22, 14, 22);
        path.cubicTo(8, 24, 4, 18, 4, 18);
        canvas.drawPath(path, paint);
      case 3: // cracked log
        final rrect = RRect.fromRectAndRadius(
          const Rect.fromLTWH(4, 13, 36, 8),
          const Radius.circular(4),
        );
        canvas.drawRRect(rrect, paint);
        final linePaint = Paint()
          ..color = color.withOpacity(0.5)
          ..strokeWidth = 1.2;
        for (final x in [10.0, 18.0, 26.0, 34.0]) {
          canvas.drawLine(Offset(x, 13), Offset(x, 21), linePaint);
        }
      case 4: // soft
        final path = Path();
        path.moveTo(6, 14);
        path.cubicTo(12, 10, 18, 14, 18, 14);
        path.cubicTo(26, 10, 32, 14, 32, 14);
        path.cubicTo(40, 12, 40, 18, 40, 18);
        path.cubicTo(40, 24, 32, 22, 32, 22);
        path.cubicTo(26, 26, 18, 22, 18, 22);
        path.cubicTo(12, 26, 6, 22, 6, 22);
        path.cubicTo(2, 18, 6, 14, 6, 14);
        canvas.drawPath(path, paint);
      case 5: // liquid
        final ellipsePaint = Paint()
          ..color = color.withOpacity(0.4);
        canvas.drawOval(
          const Rect.fromLTWH(4, 18, 36, 8),
          ellipsePaint,
        );
        final path = Path();
        path.moveTo(8, 24);
        path.cubicTo(14, 18, 22, 22, 22, 22);
        path.cubicTo(30, 26, 36, 22, 36, 22);
        path.cubicTo(34, 28, 22, 28, 22, 28);
        path.cubicTo(12, 28, 8, 24, 8, 24);
        canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) => old.kind != kind || old.color != color;
}
