import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme.dart';

class TitleScreen extends StatefulWidget {
  final VoidCallback onNewGame;
  final VoidCallback onLoadGame;
  final VoidCallback onSettings;

  const TitleScreen({
    super.key,
    required this.onNewGame,
    required this.onLoadGame,
    required this.onSettings,
  });

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen>
    with TickerProviderStateMixin {
  late AnimationController _flameController;
  late AnimationController _titleController;
  late AnimationController _demonController;
  late Animation<double> _titleFade;
  late Animation<double> _titleScale;
  late Animation<double> _demonPulse;

  @override
  void initState() {
    super.initState();

    _flameController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _demonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _titleScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _demonPulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _demonController,
        curve: Curves.easeInOut,
      ),
    );

    _titleController.forward();
  }

  @override
  void dispose() {
    _flameController.dispose();
    _titleController.dispose();
    _demonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // Safety check for initial render
    if (size.width == 0 || size.height == 0) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.gold),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background - Dark gothic gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A0505),
                  Color(0xFF0A0A0A),
                  Color(0xFF050505),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Animated hellfire background
          AnimatedBuilder(
            animation: _flameController,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: _HellfireBackgroundPainter(
                  animationValue: _flameController.value,
                ),
              );
            },
          ),

          // Gothic stone frame/pillars
          CustomPaint(
            size: size,
            painter: _GothicFramePainter(),
          ),

          // Demon silhouette
          AnimatedBuilder(
            animation: _demonPulse,
            builder: (context, _) {
              return Transform.scale(
                scale: _demonPulse.value,
                child: CustomPaint(
                  size: size,
                  painter: _DemonSilhouettePainter(
                    glowIntensity: (_demonPulse.value - 0.95) / 0.1,
                  ),
                ),
              );
            },
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),
                // Title
                AnimatedBuilder(
                  animation: _titleController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _titleFade.value,
                      child: Transform.scale(
                        scale: _titleScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildTitle(),
                ),
                const Spacer(flex: 3),
                // Menu buttons
                _buildMenuButtons(),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // Vignette overlay
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main title with gradient and glow
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE566),
              Color(0xFFFFD700),
              Color(0xFFFF8C00),
              Color(0xFFB8860B),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ).createShader(bounds),
          child: Text(
            'DEMONIA',
            style: GoogleFonts.cinzelDecorative(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 6,
              shadows: [
                const Shadow(
                  color: Colors.black,
                  blurRadius: 10,
                  offset: Offset(3, 3),
                ),
                Shadow(
                  color: AppTheme.hellfire.withOpacity(0.8),
                  blurRadius: 30,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Subtitle
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFAA8866),
              Color(0xFF886644),
            ],
          ).createShader(bounds),
          child: Text(
            'R  P  G',
            style: GoogleFonts.cinzel(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          _MenuButton(
            label: 'NEW GAME',
            onPressed: widget.onNewGame,
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          _MenuButton(
            label: 'LOAD GAME',
            onPressed: widget.onLoadGame,
          ),
          const SizedBox(height: 16),
          _MenuButton(
            label: 'SETTINGS',
            onPressed: widget.onSettings,
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _MenuButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _hoverController.forward();
      },
      onTapUp: (_) {
        _hoverController.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 - (_hoverController.value * 0.05),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.isPrimary
                      ? [
                          Color.lerp(
                            const Color(0xFF4A2020),
                            AppTheme.hellfire,
                            _hoverController.value,
                          )!,
                          Color.lerp(
                            const Color(0xFF2A1010),
                            const Color(0xFF8B0000),
                            _hoverController.value,
                          )!,
                        ]
                      : [
                          Color.lerp(
                            const Color(0xFF3D3020),
                            const Color(0xFF4A3828),
                            _hoverController.value,
                          )!,
                          Color.lerp(
                            const Color(0xFF1A1008),
                            const Color(0xFF2A1A10),
                            _hoverController.value,
                          )!,
                        ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color.lerp(
                    AppTheme.darkGold.withOpacity(0.5),
                    AppTheme.gold,
                    _hoverController.value,
                  )!,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isPrimary ? AppTheme.hellfire : AppTheme.gold)
                        .withOpacity(0.2 + _hoverController.value * 0.3),
                    blurRadius: 8 + _hoverController.value * 8,
                    spreadRadius: _hoverController.value * 2,
                  ),
                ],
              ),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color.lerp(
                    AppTheme.boneWhite,
                    AppTheme.gold,
                    _hoverController.value,
                  ),
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HellfireBackgroundPainter extends CustomPainter {
  final double animationValue;

  _HellfireBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);

    // Draw flames from bottom
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final baseHeight = size.height * (0.1 + random.nextDouble() * 0.2);
      final phase = random.nextDouble() * math.pi * 2;
      final speed = 0.5 + random.nextDouble() * 0.5;

      final flickerOffset =
          math.sin(animationValue * math.pi * 2 * speed + phase) * 20;
      final height = baseHeight + flickerOffset;

      final flamePath = Path();
      flamePath.moveTo(x - 20 - random.nextDouble() * 20, size.height);
      flamePath.quadraticBezierTo(
        x + math.sin(animationValue * math.pi * 4 + phase) * 10,
        size.height - height * 0.5,
        x + 5,
        size.height - height,
      );
      flamePath.quadraticBezierTo(
        x + 10 + math.sin(animationValue * math.pi * 3 + phase) * 5,
        size.height - height * 0.5,
        x + 20 + random.nextDouble() * 20,
        size.height,
      );
      flamePath.close();

      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFFFF6B00).withOpacity(0.8),
          const Color(0xFFFF4500).withOpacity(0.6),
          const Color(0xFFDC143C).withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(x - 30, size.height - height, 60, height),
        );

      canvas.drawPath(flamePath, paint);
    }

    // Add glow at the bottom
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 1),
        radius: 0.8,
        colors: [
          AppTheme.hellfire.withOpacity(0.4),
          AppTheme.crimson.withOpacity(0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HellfireBackgroundPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}

class _GothicFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Left pillar
    const leftPillarGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFF2A2A2A),
        const Color(0xFF1A1A1A),
        const Color(0xFF0A0A0A),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    paint.shader = leftPillarGradient.createShader(
      Rect.fromLTWH(0, 0, size.width * 0.12, size.height),
    );

    final leftPillar = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.1, 0)
      ..lineTo(size.width * 0.12, size.height * 0.05)
      ..lineTo(size.width * 0.12, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(leftPillar, paint);

    // Right pillar
    paint.shader = leftPillarGradient.createShader(
      Rect.fromLTWH(size.width * 0.88, 0, size.width * 0.12, size.height),
    );

    final rightPillar = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width * 0.9, 0)
      ..lineTo(size.width * 0.88, size.height * 0.05)
      ..lineTo(size.width * 0.88, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(rightPillar, paint);

    // Gothic arch at top
    const archGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF2A2020),
        const Color(0xFF1A1010),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    paint.shader = archGradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.4),
    );

    final arch = Path()
      ..moveTo(size.width * 0.12, 0)
      ..lineTo(size.width * 0.12, size.height * 0.1)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.35,
        size.width * 0.88,
        size.height * 0.1,
      )
      ..lineTo(size.width * 0.88, 0)
      ..close();

    canvas.drawPath(arch, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DemonSilhouettePainter extends CustomPainter {
  final double glowIntensity;

  _DemonSilhouettePainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final baseY = size.height * 0.85;

    // Draw demon silhouette
    final silhouettePath = Path();

    // Body
    silhouettePath.moveTo(centerX - size.width * 0.15, baseY);
    silhouettePath.lineTo(centerX - size.width * 0.12, baseY - size.height * 0.25);
    silhouettePath.lineTo(centerX - size.width * 0.08, baseY - size.height * 0.35);

    // Left shoulder/wing
    silhouettePath.lineTo(centerX - size.width * 0.25, baseY - size.height * 0.35);
    silhouettePath.lineTo(centerX - size.width * 0.35, baseY - size.height * 0.25);
    silhouettePath.lineTo(centerX - size.width * 0.3, baseY - size.height * 0.38);
    silhouettePath.lineTo(centerX - size.width * 0.2, baseY - size.height * 0.4);

    // Head
    silhouettePath.lineTo(centerX - size.width * 0.06, baseY - size.height * 0.42);

    // Left horn
    silhouettePath.lineTo(centerX - size.width * 0.08, baseY - size.height * 0.48);
    silhouettePath.lineTo(centerX - size.width * 0.12, baseY - size.height * 0.55);
    silhouettePath.lineTo(centerX - size.width * 0.04, baseY - size.height * 0.47);

    // Top of head
    silhouettePath.lineTo(centerX, baseY - size.height * 0.45);

    // Right horn
    silhouettePath.lineTo(centerX + size.width * 0.04, baseY - size.height * 0.47);
    silhouettePath.lineTo(centerX + size.width * 0.12, baseY - size.height * 0.55);
    silhouettePath.lineTo(centerX + size.width * 0.08, baseY - size.height * 0.48);

    silhouettePath.lineTo(centerX + size.width * 0.06, baseY - size.height * 0.42);

    // Right shoulder/wing
    silhouettePath.lineTo(centerX + size.width * 0.2, baseY - size.height * 0.4);
    silhouettePath.lineTo(centerX + size.width * 0.3, baseY - size.height * 0.38);
    silhouettePath.lineTo(centerX + size.width * 0.35, baseY - size.height * 0.25);
    silhouettePath.lineTo(centerX + size.width * 0.25, baseY - size.height * 0.35);

    silhouettePath.lineTo(centerX + size.width * 0.08, baseY - size.height * 0.35);
    silhouettePath.lineTo(centerX + size.width * 0.12, baseY - size.height * 0.25);
    silhouettePath.lineTo(centerX + size.width * 0.15, baseY);

    silhouettePath.close();

    // Draw glow behind silhouette
    final glowPaint = Paint()
      ..color = AppTheme.crimson.withOpacity(0.3 + glowIntensity * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawPath(silhouettePath, glowPaint);

    // Draw silhouette
    final silhouettePaint = Paint()
      ..color = const Color(0xFF0A0505);

    canvas.drawPath(silhouettePath, silhouettePaint);

    // Draw glowing eyes
    final eyePaint = Paint()
      ..color = AppTheme.hellfire.withOpacity(0.8 + glowIntensity * 0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + glowIntensity * 4);

    canvas.drawCircle(
      Offset(centerX - size.width * 0.025, baseY - size.height * 0.43),
      3 + glowIntensity * 2,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(centerX + size.width * 0.025, baseY - size.height * 0.43),
      3 + glowIntensity * 2,
      eyePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DemonSilhouettePainter oldDelegate) {
    return glowIntensity != oldDelegate.glowIntensity;
  }
}
