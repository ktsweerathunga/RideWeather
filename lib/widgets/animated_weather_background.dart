import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedWeatherBackground extends StatefulWidget {
  final String weatherCondition;
  final Widget child;

  const AnimatedWeatherBackground({
    super.key,
    required this.weatherCondition,
    required this.child,
  });

  @override
  State<AnimatedWeatherBackground> createState() => _AnimatedWeatherBackgroundState();
}

class _AnimatedWeatherBackgroundState extends State<AnimatedWeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _rainController;
  late AnimationController _cloudController;
  late AnimationController _sunController;
  late List<RainDrop> _rainDrops;
  late List<Cloud> _clouds;

  @override
  void initState() {
    super.initState();
    
    _rainController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _cloudController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _sunController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _rainDrops = List.generate(50, (index) => RainDrop());
    _clouds = List.generate(3, (index) => Cloud(index));
  }

  void _startAnimations() {
    final condition = widget.weatherCondition.toLowerCase();
    
    if (condition.contains('rain') || condition.contains('drizzle')) {
      _rainController.repeat();
    }
    
    if (condition.contains('cloud') || condition.contains('overcast')) {
      _cloudController.repeat();
    }
    
    if (condition.contains('clear') || condition.contains('sunny')) {
      _sunController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedWeatherBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weatherCondition != widget.weatherCondition) {
      _stopAllAnimations();
      _startAnimations();
    }
  }

  void _stopAllAnimations() {
    _rainController.stop();
    _cloudController.stop();
    _sunController.stop();
  }

  @override
  void dispose() {
    _rainController.dispose();
    _cloudController.dispose();
    _sunController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: _getBackgroundGradient(),
          ),
        ),
        
        // Weather animations
        if (widget.weatherCondition.toLowerCase().contains('rain'))
          _buildRainAnimation(),
        
        if (widget.weatherCondition.toLowerCase().contains('cloud'))
          _buildCloudAnimation(),
        
        if (widget.weatherCondition.toLowerCase().contains('clear') ||
            widget.weatherCondition.toLowerCase().contains('sunny'))
          _buildSunAnimation(),
        
        // Main content
        widget.child,
      ],
    );
  }

  LinearGradient _getBackgroundGradient() {
    final condition = widget.weatherCondition.toLowerCase();
    
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1E3A8A), // Deep blue
          Color(0xFF3B82F6), // Blue
          Color(0xFF60A5FA), // Light blue
        ],
      );
    } else if (condition.contains('cloud')) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF6B7280), // Gray
          Color(0xFF9CA3AF), // Light gray
          Color(0xFFD1D5DB), // Very light gray
        ],
      );
    } else if (condition.contains('clear') || condition.contains('sunny')) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFBBF24), // Yellow
          Color(0xFFF59E0B), // Orange
          Color(0xFFEA580C), // Deep orange
        ],
      );
    }
    
    // Default gradient
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF3B82F6),
        Color(0xFF60A5FA),
        Color(0xFF93C5FD),
      ],
    );
  }

  Widget _buildRainAnimation() {
    return AnimatedBuilder(
      animation: _rainController,
      builder: (context, child) {
        return CustomPaint(
          painter: RainPainter(_rainDrops, _rainController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildCloudAnimation() {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) {
        return CustomPaint(
          painter: CloudPainter(_clouds, _cloudController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildSunAnimation() {
    return AnimatedBuilder(
      animation: _sunController,
      builder: (context, child) {
        return CustomPaint(
          painter: SunPainter(_sunController.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class RainDrop {
  late double x;
  late double y;
  late double speed;
  late double length;

  RainDrop() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = -0.1;
    speed = 0.02 + math.Random().nextDouble() * 0.03;
    length = 10 + math.Random().nextDouble() * 20;
  }

  void update() {
    y += speed;
    if (y > 1.1) {
      reset();
    }
  }
}

class Cloud {
  late double x;
  late double y;
  late double speed;
  late double size;

  Cloud(int index) {
    x = index * 0.4;
    y = 0.1 + index * 0.15;
    speed = 0.001 + math.Random().nextDouble() * 0.002;
    size = 0.8 + math.Random().nextDouble() * 0.4;
  }

  void update() {
    x += speed;
    if (x > 1.2) {
      x = -0.2;
    }
  }
}

class RainPainter extends CustomPainter {
  final List<RainDrop> rainDrops;
  final double animationValue;

  RainPainter(this.rainDrops, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (final drop in rainDrops) {
      drop.update();
      
      final startX = drop.x * size.width;
      final startY = drop.y * size.height;
      final endX = startX - 5;
      final endY = startY + drop.length;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CloudPainter extends CustomPainter {
  final List<Cloud> clouds;
  final double animationValue;

  CloudPainter(this.clouds, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (final cloud in clouds) {
      cloud.update();
      
      final centerX = cloud.x * size.width;
      final centerY = cloud.y * size.height;
      final radius = cloud.size * 30;

      // Draw cloud as multiple circles
      canvas.drawCircle(Offset(centerX, centerY), radius, paint);
      canvas.drawCircle(Offset(centerX - radius * 0.5, centerY), radius * 0.8, paint);
      canvas.drawCircle(Offset(centerX + radius * 0.5, centerY), radius * 0.8, paint);
      canvas.drawCircle(Offset(centerX, centerY - radius * 0.3), radius * 0.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SunPainter extends CustomPainter {
  final double animationValue;

  SunPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.8, size.height * 0.2);
    final radius = 40.0;
    
    final sunPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final rayPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw sun rays
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (animationValue * math.pi * 2);
      final rayStart = Offset(
        center.dx + math.cos(angle) * (radius + 10),
        center.dy + math.sin(angle) * (radius + 10),
      );
      final rayEnd = Offset(
        center.dx + math.cos(angle) * (radius + 25),
        center.dy + math.sin(angle) * (radius + 25),
      );
      
      canvas.drawLine(rayStart, rayEnd, rayPaint);
    }

    // Draw sun
    canvas.drawCircle(center, radius, sunPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
