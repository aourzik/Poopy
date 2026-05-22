import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// ─── Poopy Card ───────────────────────────────────────────────────────────────

class PoopyCard extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const PoopyCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.border,
    this.boxShadow,
  });

  @override
  State<PoopyCard> createState() => _PoopyCardState();
}

class _PoopyCardState extends State<PoopyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final color = widget.backgroundColor ?? t.surface;
    final isColored = widget.backgroundColor != null;

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _controller.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel:
          widget.onTap != null ? () => _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border ??
                (isColored
                    ? null
                    : Border.all(color: t.border, width: 1)),
            boxShadow: widget.boxShadow ??
                (isColored
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: color.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ]),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────

class PoopyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? trailing;
  final bool disabled;
  final double height;
  final Color? color;

  const PoopyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailing,
    this.disabled = false,
    this.height = 60,
    this.color,
  });

  @override
  State<PoopyButton> createState() => _PoopyButtonState();
}

class _PoopyButtonState extends State<PoopyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final canPress = !widget.disabled && widget.onPressed != null;

    return GestureDetector(
      onTapDown: canPress ? (_) => _ctrl.forward() : null,
      onTapUp: canPress
          ? (_) {
              _ctrl.reverse();
              widget.onPressed!();
            }
          : null,
      onTapCancel: canPress ? () => _ctrl.reverse() : null,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.height,
          decoration: BoxDecoration(
            gradient: canPress
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.color != null
                        ? [widget.color!, widget.color!]
                        : [t.pink, t.pinkDeep],
                  )
                : null,
            color: canPress ? null : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: canPress
                ? [
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
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: canPress ? Colors.white : AppColors.textMuted,
                  letterSpacing: 0.2,
                ),
              ),
              if (widget.trailing != null && canPress) ...[
                const SizedBox(width: 10),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Chip ─────────────────────────────────────────────────────────────────────

class AppChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const AppChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Toggle row ───────────────────────────────────────────────────────────────

class ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleRow({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.08) : t.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? color.withOpacity(0.3) : t.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                  style: TextStyle(
                    fontFamily: 'Quicksand', fontSize: 13.5,
                    fontWeight: FontWeight.w700, color: t.text,
                  )),
                Text(subtitle,
                  style: TextStyle(
                    fontFamily: 'Quicksand', fontSize: 11.5,
                    fontWeight: FontWeight.w500, color: t.textDim,
                  )),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}

// ─── Eyebrow label ────────────────────────────────────────────────────────────

class EyebrowLabel extends StatelessWidget {
  final String text;

  const EyebrowLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: AppColors.textDim,
      ),
    );
  }
}

// ─── Input field ──────────────────────────────────────────────────────────────

class PoopyTextField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final bool? isValid;

  const PoopyTextField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.isValid,
  });

  @override
  State<PoopyTextField> createState() => _PoopyTextFieldState();
}

class _PoopyTextFieldState extends State<PoopyTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    Color borderColor;
    if (_focused) {
      borderColor = t.pinkDeep;
    } else if (widget.isValid == false) {
      borderColor = AppColors.selles;
    } else {
      borderColor = t.border;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(widget.label,
            style: const TextStyle(
              fontFamily: 'Quicksand', fontSize: 12,
              fontWeight: FontWeight.w700, letterSpacing: 0.4,
              color: AppColors.textDim,
            )),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: _focused
                ? [BoxShadow(color: t.pink.withOpacity(0.2), blurRadius: 0, spreadRadius: 4)]
                : null,
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(widget.icon, size: 18,
                color: _focused ? t.pinkDeep : AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Focus(
                  onFocusChange: (v) => setState(() => _focused = v),
                  child: TextFormField(
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    style: TextStyle(
                      fontFamily: 'Quicksand', fontSize: 15,
                      fontWeight: FontWeight.w500, color: t.text,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: TextStyle(color: t.textMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
              ),
              if (widget.isValid == true) ...[
                Container(
                  width: 22, height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.rdv,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stepper ─────────────────────────────────────────────────────────────────

class PoopyStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final Color color;

  const PoopyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 20,
    this.color = AppColors.selles,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: t.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          _StepBtn(
            label: '−',
            onTap: value > min ? () => onChanged(value - 1) : null,
            bg: t.surface,
            color: t.text,
          ),
          Expanded(
            child: Center(
              child: Text('$value',
                style: TextStyle(
                  fontFamily: 'Quicksand', fontSize: 22,
                  fontWeight: FontWeight.w700, color: t.text,
                )),
            ),
          ),
          _StepBtn(
            label: '+',
            onTap: value < max ? () => onChanged(value + 1) : null,
            bg: color,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color bg;
  final Color color;

  const _StepBtn({required this.label, this.onTap, required this.bg, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text(label,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: color)),
        ),
      ),
    );
  }
}

// ─── Segmented control ────────────────────────────────────────────────────────

class PoopySegmented extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? accentColor;

  const PoopySegmented({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: options.asMap().entries.map((e) {
          final isActive = e.key == selectedIndex;
          final hasAccent = accentColor != null && isActive;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isActive
                      ? (hasAccent ? accentColor : t.surface)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isActive && !hasAccent
                      ? [BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 2, offset: const Offset(0, 1),
                        )]
                      : null,
                ),
                child: Text(
                  e.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? (hasAccent ? Colors.white : t.text)
                        : t.textDim,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
