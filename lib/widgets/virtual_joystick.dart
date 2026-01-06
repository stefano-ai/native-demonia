import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum JoystickDirection { none, up, down, left, right }

class VirtualJoystick extends StatefulWidget {
  final void Function(JoystickDirection direction) onDirectionChanged;
  final double size;

  const VirtualJoystick({
    super.key,
    required this.onDirectionChanged,
    this.size = 120,
  });

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _knobPosition = Offset.zero;
  JoystickDirection _currentDirection = JoystickDirection.none;
  Timer? _moveTimer;

  double get _maxDistance => widget.size / 3;

  @override
  void dispose() {
    _moveTimer?.cancel();
    super.dispose();
  }

  void _updateKnobPosition(Offset localPosition) {
    final center = Offset(widget.size / 2, widget.size / 2);
    var delta = localPosition - center;

    // Clamp to circle
    if (delta.distance > _maxDistance) {
      delta = Offset.fromDirection(delta.direction, _maxDistance);
    }

    setState(() {
      _knobPosition = delta;
    });

    // Determine direction
    JoystickDirection newDirection = JoystickDirection.none;
    if (delta.distance > _maxDistance * 0.3) {
      final angle = delta.direction;
      if (angle > -0.785 && angle <= 0.785) {
        newDirection = JoystickDirection.right;
      } else if (angle > 0.785 && angle <= 2.356) {
        newDirection = JoystickDirection.down;
      } else if (angle > -2.356 && angle <= -0.785) {
        newDirection = JoystickDirection.up;
      } else {
        newDirection = JoystickDirection.left;
      }
    }

    if (newDirection != _currentDirection) {
      _currentDirection = newDirection;
      _moveTimer?.cancel();

      if (newDirection != JoystickDirection.none) {
        widget.onDirectionChanged(newDirection);
        _moveTimer = Timer.periodic(
          const Duration(milliseconds: 200),
          (_) => widget.onDirectionChanged(newDirection),
        );
      }
    }
  }

  void _resetKnob() {
    _moveTimer?.cancel();
    setState(() {
      _knobPosition = Offset.zero;
      _currentDirection = JoystickDirection.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        onPanStart: (details) => _updateKnobPosition(details.localPosition),
        onPanUpdate: (details) => _updateKnobPosition(details.localPosition),
        onPanEnd: (_) => _resetKnob(),
        onPanCancel: _resetKnob,
        child: CustomPaint(
          painter: _JoystickPainter(
            knobPosition: _knobPosition,
            baseColor: AppTheme.stoneGray.withOpacity(0.5),
            knobColor: AppTheme.gold,
            highlightColor: AppTheme.hellfire,
            isActive: _currentDirection != JoystickDirection.none,
          ),
        ),
      ),
    );
  }
}

class _JoystickPainter extends CustomPainter {
  final Offset knobPosition;
  final Color baseColor;
  final Color knobColor;
  final Color highlightColor;
  final bool isActive;

  _JoystickPainter({
    required this.knobPosition,
    required this.baseColor,
    required this.knobColor,
    required this.highlightColor,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;
    final knobRadius = size.width / 5;

    // Draw base circle
    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius, basePaint);

    // Draw base border
    final borderPaint = Paint()
      ..color = AppTheme.darkGold.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, baseRadius, borderPaint);

    // Draw direction indicators
    final indicatorPaint = Paint()
      ..color = AppTheme.gold.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final indicatorSize = size.width / 8;
    final indicatorOffset = baseRadius * 0.6;

    // Up
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - indicatorOffset - indicatorSize)
        ..lineTo(center.dx - indicatorSize / 2, center.dy - indicatorOffset)
        ..lineTo(center.dx + indicatorSize / 2, center.dy - indicatorOffset)
        ..close(),
      indicatorPaint,
    );

    // Down
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy + indicatorOffset + indicatorSize)
        ..lineTo(center.dx - indicatorSize / 2, center.dy + indicatorOffset)
        ..lineTo(center.dx + indicatorSize / 2, center.dy + indicatorOffset)
        ..close(),
      indicatorPaint,
    );

    // Left
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - indicatorOffset - indicatorSize, center.dy)
        ..lineTo(center.dx - indicatorOffset, center.dy - indicatorSize / 2)
        ..lineTo(center.dx - indicatorOffset, center.dy + indicatorSize / 2)
        ..close(),
      indicatorPaint,
    );

    // Right
    canvas.drawPath(
      Path()
        ..moveTo(center.dx + indicatorOffset + indicatorSize, center.dy)
        ..lineTo(center.dx + indicatorOffset, center.dy - indicatorSize / 2)
        ..lineTo(center.dx + indicatorOffset, center.dy + indicatorSize / 2)
        ..close(),
      indicatorPaint,
    );

    // Draw knob shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(
      center + knobPosition + const Offset(2, 2),
      knobRadius,
      shadowPaint,
    );

    // Draw knob
    final knobPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          isActive ? highlightColor : knobColor,
          isActive ? knobColor : AppTheme.darkGold,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(
        center: center + knobPosition,
        radius: knobRadius,
      ));
    canvas.drawCircle(center + knobPosition, knobRadius, knobPaint);

    // Draw knob highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      center + knobPosition + Offset(-knobRadius * 0.3, -knobRadius * 0.3),
      knobRadius * 0.3,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _JoystickPainter oldDelegate) {
    return knobPosition != oldDelegate.knobPosition ||
        isActive != oldDelegate.isActive;
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (color ?? AppTheme.hellfire).withOpacity(0.8),
                  (color ?? AppTheme.darkCrimson),
                ],
              ),
              border: Border.all(
                color: AppTheme.gold.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (color ?? AppTheme.hellfire).withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppTheme.boneWhite,
              size: size * 0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.boneWhite,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
