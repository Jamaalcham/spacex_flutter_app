import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../core/utils/localization/language_constants.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _rocketController;
  late AnimationController _planetController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rocketAnimation;
  late Animation<double> _planetRotationAnimation;
  late Animation<double> _particleAnimation;

  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateParticles();
    _navigateToHome();
  }

  void _setupAnimations() {
    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Rocket animation controller
    _rocketController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Planet rotation controller
    _planetController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Main animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    // Rocket launch animation
    _rocketAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rocketController, curve: Curves.easeInOut),
    );

    // Planet rotation animation
    _planetRotationAnimation =
        Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _planetController, curve: Curves.linear),
    );

    // Particle animation
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    // Start animations
    _mainController.forward();
    _particleController.repeat();
    _rocketController.forward();
    _planetController.repeat();
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 3 + 1,
        speed: random.nextDouble() * 0.5 + 0.1,
        opacity: random.nextDouble() * 0.8 + 0.2,
      ));
    }
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 4), () {
      Get.offAll(() => const MainNavigationScreen());
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _rocketController.dispose();
    _planetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF24243e),
              Color(0xFF302B63),
              Color(0xFF0F0C29),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            AnimatedBuilder(
              animation: _particleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter:
                      ParticlePainter(_particles, _particleAnimation.value),
                  size: Size.infinite,
                );
              },
            ),

            // Rotating planets
            Positioned(
              top: 100,
              right: 50,
              child: AnimatedBuilder(
                animation: _planetRotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _planetRotationAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A90E2).withValues(alpha:0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.public,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Smaller planet
            Positioned(
              bottom: 150,
              left: 30,
              child: AnimatedBuilder(
                animation: _planetRotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -_planetRotationAnimation.value * 0.5,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B6B).withValues(alpha:0.5),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.radio_button_unchecked,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated rocket
                      AnimatedBuilder(
                        animation: _rocketAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -20 * _rocketAnimation.value),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha:0.3),
                                    Colors.white.withValues(alpha:0.1),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Rocket icon
                                  const Icon(
                                    Icons.rocket_launch,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                  // Animated flame effect
                                  if (_rocketAnimation.value > 0.3)
                                    Positioned(
                                      bottom: 10,
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: 40,
                                        height: 20 * _rocketAnimation.value,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0xFFFF6B35),
                                              Color(0xFFFF8E53),
                                              Color(0xFFFFA500),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // App title
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getTranslated(context, 'app_title') ??
                              'SpaceX Explorer',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        getTranslated(context, 'app_subtitle') ??
                            'Discover the future of space exploration',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha:0.8),
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 60),

                      // Animated loading indicator
                      AnimatedBuilder(
                        animation: _mainController,
                        builder: (context, child) {
                          return SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha:0.8),
                              ),
                              strokeWidth: 3,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Particle class for background animation
class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

// Custom painter for particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.screen;

    for (final particle in particles) {
      final animatedY = (particle.y + animationValue * particle.speed) % 1.0;

      paint.color = Colors.white.withValues(alpha:particle.opacity * 0.6);

      canvas.drawCircle(
        Offset(particle.x * size.width, animatedY * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
