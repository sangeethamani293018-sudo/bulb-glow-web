import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const BulbApp());
}

class BulbApp extends StatelessWidget {
  const BulbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GSP Bulb App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BulbHomePage(),
    );
  }
}

class BulbHomePage extends StatefulWidget {
  const BulbHomePage({super.key});

  @override
  State<BulbHomePage> createState() => _BulbHomePageState();
}

class _BulbHomePageState extends State<BulbHomePage>
    with TickerProviderStateMixin {
  Color? _activeColor;
  String _colorName = '';
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _colorButtons = [
    {
      'color': const Color(0xFFFF3D3D),
      'name': 'Red',
      'gradient': [const Color(0xFFFF3D3D), const Color(0xFFFF0000)],
      'glow': const Color(0xFFFF3D3D),
      'icon': Icons.whatshot,
    },
    {
      'color': const Color(0xFF00E676),
      'name': 'Green',
      'gradient': [const Color(0xFF00E676), const Color(0xFF00C853)],
      'glow': const Color(0xFF00E676),
      'icon': Icons.eco,
    },
    {
      'color': const Color(0xFF2979FF),
      'name': 'Blue',
      'gradient': [const Color(0xFF2979FF), const Color(0xFF1565C0)],
      'glow': const Color(0xFF2979FF),
      'icon': Icons.water_drop,
    },
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOutCubic),
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _activateColor(Map<String, dynamic> btn) {
    setState(() {
      _activeColor = btn['color'] as Color;
      _colorName = btn['name'] as String;
    });
    _glowController.forward(from: 0.0);
  }

  void _turnOff() {
    setState(() {
      _activeColor = null;
      _colorName = '';
    });
    _glowController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - 60,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWeb ? size.width * 0.2 : 20,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        // Title
                        _buildTitle(),
                        const SizedBox(height: 50),
                        // Bulb Section
                        _buildBulbSection(),
                        const SizedBox(height: 40),
                        // Status text
                        _buildStatusText(),
                        const SizedBox(height: 50),
                        // Color Buttons
                        _buildColorButtons(isWeb),
                        const SizedBox(height: 30),
                        // Off Button
                        _buildOffButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
          ).createShader(bounds),
          child: const Text(
            'SMART BULB',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 10,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Color Controller',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B6B8A),
            letterSpacing: 4,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildBulbSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _pulseAnimation]),
      builder: (context, child) {
        final glowVal = _activeColor != null ? _glowAnimation.value : 0.0;
        final pulseVal = _activeColor != null ? _pulseAnimation.value : 1.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            if (_activeColor != null)
              Container(
                width: 220 * pulseVal,
                height: 220 * pulseVal,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _activeColor!.withOpacity(0.15 * glowVal),
                      blurRadius: 60,
                      spreadRadius: 30,
                    ),
                  ],
                  gradient: RadialGradient(
                    colors: [
                      _activeColor!.withOpacity(0.1 * glowVal),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

            // Bulb container
            Transform.scale(
              scale: _activeColor != null ? pulseVal : 1.0,
              child: Container(
                width: 160,
                height: 200,
                child: CustomPaint(
                  painter: BulbPainter(
                    glowColor: _activeColor,
                    glowIntensity: glowVal,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _activeColor != null
          ? Container(
              key: ValueKey(_colorName),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _activeColor!.withOpacity(0.5),
                  width: 1,
                ),
                color: _activeColor!.withOpacity(0.1),
              ),
              child: Text(
                '✦  $_colorName Light Active  ✦',
                style: TextStyle(
                  color: _activeColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            )
          : Container(
              key: const ValueKey('off'),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white12,
                  width: 1,
                ),
              ),
              child: const Text(
                '◌  Bulb is OFF',
                style: TextStyle(
                  color: Color(0xFF4A4A6A),
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ),
    );
  }

  Widget _buildColorButtons(bool isWeb) {
    return isWeb
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _colorButtons
                .map((btn) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _buildColorButton(btn),
                    ))
                .toList(),
          )
        : Column(
            children: _colorButtons
                .map((btn) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _buildColorButton(btn),
                    ))
                .toList(),
          );
  }

  Widget _buildColorButton(Map<String, dynamic> btn) {
    final isActive = _activeColor == btn['color'];
    final color = btn['color'] as Color;
    final gradients = btn['gradient'] as List<Color>;

    return GestureDetector(
      onTap: () => _activateColor(btn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isActive
                ? gradients
                : [
                    color.withOpacity(0.15),
                    color.withOpacity(0.08),
                  ],
          ),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.3),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              btn['icon'] as IconData,
              color: isActive ? Colors.white : color,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              btn['name'] as String,
              style: TextStyle(
                color: isActive ? Colors.white : color,
                fontSize: 16,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffButton() {
    return GestureDetector(
      onTap: _turnOff,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _activeColor == null
                ? const Color(0xFF3A3A5A)
                : Colors.white24,
            width: 1,
          ),
          color: Colors.white.withOpacity(0.04),
        ),
        child: Center(
          child: Text(
            'TURN OFF',
            style: TextStyle(
              color: _activeColor == null
                  ? const Color(0xFF3A3A5A)
                  : Colors.white60,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF1A1A2E), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Powered by ',
            style: TextStyle(
              color: Color(0xFF4A4A6A),
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
            ).createShader(bounds),
            child: const Text(
              'GSP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BulbPainter extends CustomPainter {
  final Color? glowColor;
  final double glowIntensity;

  BulbPainter({this.glowColor, required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final bulbRadius = size.width * 0.38;
    final bulbCenterY = size.height * 0.40;

    // Base color
    final isOn = glowColor != null && glowIntensity > 0;
    final baseColor = isOn
        ? Color.lerp(const Color(0xFF2A2A3A), glowColor!, glowIntensity)!
        : const Color(0xFF1E1E2E);

    // Draw glow effect
    if (isOn) {
      final glowPaint = Paint()
        ..color = glowColor!.withOpacity(0.3 * glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      canvas.drawCircle(
          Offset(cx, bulbCenterY), bulbRadius * 1.4, glowPaint);

      final innerGlowPaint = Paint()
        ..color = glowColor!.withOpacity(0.2 * glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(
          Offset(cx, bulbCenterY), bulbRadius * 1.1, innerGlowPaint);
    }

    // Draw bulb body (circle part)
    final bulbPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.9,
        colors: isOn
            ? [
                Color.lerp(Colors.white, glowColor!, 0.4)!
                    .withOpacity(glowIntensity),
                glowColor!,
                Color.lerp(glowColor!, Colors.black, 0.4)!,
              ]
            : [
                const Color(0xFF3A3A50),
                const Color(0xFF252535),
                const Color(0xFF151520),
              ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(
          center: Offset(cx, bulbCenterY), radius: bulbRadius));

    canvas.drawCircle(Offset(cx, bulbCenterY), bulbRadius, bulbPaint);

    // Bulb neck/base
    final neckTop = bulbCenterY + bulbRadius * 0.55;
    final neckBottom = size.height * 0.80;
    final neckWidth = size.width * 0.22;

    final neckPath = Path();
    neckPath.moveTo(cx - neckWidth * 0.8, neckTop);
    neckPath.quadraticBezierTo(
        cx - neckWidth * 0.9, neckTop + (neckBottom - neckTop) * 0.3,
        cx - neckWidth * 0.7, neckBottom);
    neckPath.lineTo(cx + neckWidth * 0.7, neckBottom);
    neckPath.quadraticBezierTo(
        cx + neckWidth * 0.9, neckTop + (neckBottom - neckTop) * 0.3,
        cx + neckWidth * 0.8, neckTop);
    neckPath.close();

    final neckPaint = Paint()
      ..shader = LinearGradient(
        colors: isOn
            ? [
                glowColor!.withOpacity(0.6),
                glowColor!.withOpacity(0.3),
              ]
            : [
                const Color(0xFF2A2A3A),
                const Color(0xFF1A1A28),
              ],
      ).createShader(
          Rect.fromLTRB(cx - neckWidth, neckTop, cx + neckWidth, neckBottom));
    canvas.drawPath(neckPath, neckPaint);

    // Base lines (screw threads)
    final threadPaint = Paint()
      ..color = isOn
          ? glowColor!.withOpacity(0.4)
          : const Color(0xFF252535)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final y = neckBottom -
          (i * (neckBottom - neckTop - 10) / 3) -
          10;
      canvas.drawLine(
        Offset(cx - neckWidth * 0.6, y),
        Offset(cx + neckWidth * 0.6, y),
        threadPaint,
      );
    }

    // Highlight on bulb
    if (isOn) {
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.35 * glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx - bulbRadius * 0.25, bulbCenterY - bulbRadius * 0.3),
          width: bulbRadius * 0.4,
          height: bulbRadius * 0.25,
        ),
        highlightPaint,
      );
    } else {
      // Subtle highlight when off
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.08);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx - bulbRadius * 0.25, bulbCenterY - bulbRadius * 0.3),
          width: bulbRadius * 0.35,
          height: bulbRadius * 0.2,
        ),
        highlightPaint,
      );
    }

    // Filament (visible when off)
    if (!isOn) {
      final filamentPaint = Paint()
        ..color = const Color(0xFF3A3A50)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(cx, bulbCenterY + bulbRadius * 0.2);
      path.quadraticBezierTo(
          cx - 10, bulbCenterY - 5, cx, bulbCenterY - 10);
      path.quadraticBezierTo(
          cx + 10, bulbCenterY - 25, cx, bulbCenterY - 30);
      canvas.drawPath(path, filamentPaint);
    } else {
      // Glowing filament
      final filamentPaint = Paint()
        ..color = Colors.white.withOpacity(0.9 * glowIntensity)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * glowIntensity);

      final path = Path();
      path.moveTo(cx, bulbCenterY + bulbRadius * 0.2);
      path.quadraticBezierTo(
          cx - 10, bulbCenterY - 5, cx, bulbCenterY - 10);
      path.quadraticBezierTo(
          cx + 10, bulbCenterY - 25, cx, bulbCenterY - 30);
      canvas.drawPath(path, filamentPaint);
    }
  }

  @override
  bool shouldRepaint(BulbPainter oldDelegate) =>
      oldDelegate.glowColor != glowColor ||
      oldDelegate.glowIntensity != glowIntensity;
}
