import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'cnic_monitor_screen.dart';
import 'doc_guard_screen.dart';
import 'leak_finder_screen.dart';
import 'photo_shield_screen.dart';
import 'mirror_trace_screen.dart';
import 'app_cleanse_screen.dart';
import 'sms_scanner_screen.dart';

class EnhancedHomeScreen extends ConsumerStatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  ConsumerState<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends ConsumerState<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _backgroundController;
  late AnimationController _floatingController;
  int _currentPage = 0;

  // Idle Animation
  Timer? _idleTimer;
  bool _isIdle = false;
  late AnimationController _idleAnimationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);

    // Background gradient animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    // Floating elements animation
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Idle animation
    _idleAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _resetIdleTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _idleAnimationController.dispose();
    _pageController.dispose();
    _backgroundController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    if (_isIdle) {
      setState(() {
        _isIdle = false;
        _idleAnimationController.stop();
        _idleAnimationController.reset();
      });
    }

    _idleTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isIdle = true;
          _idleAnimationController.repeat(reverse: true);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Listener(
        onPointerDown: (_) => _resetIdleTimer(),
        onPointerMove: (_) => _resetIdleTimer(),
        onPointerUp: (_) => _resetIdleTimer(),
        child: Stack(
          children: [
            // Animated Background
            _buildAnimatedBackground(theme),

            // Floating Decorative Elements
            _buildFloatingElements(),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  _buildCustomAppBar(theme, isDarkMode),

                  const SizedBox(height: 10),

                  // Unified Security Dashboard
                  _buildUnifiedDashboard(theme),

                  const SizedBox(height: 24),

                  // Features Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Security Features',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_currentPage + 1}/7',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Feature Cards PageView
                  Expanded(
                    child: _buildFeaturePageView(theme),
                  ),

                  const SizedBox(height: 16),

                  // Page Indicator
                  _buildPageIndicator(theme),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(ThemeData theme) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.1),
                theme.colorScheme.tertiary.withOpacity(0.1),
              ],
              stops: [
                0.0,
                _backgroundController.value,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        return Stack(
          children: [
            // Top left floating shield
            Positioned(
              top: 50 + (_floatingController.value * 20),
              left: 20,
              child: const Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.shield,
                  size: 100,
                  color: Colors.purple,
                ),
              ),
            ),
            // Bottom right floating lock
            Positioned(
              bottom: 100 + (_floatingController.value * 30),
              right: 30,
              child: const Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.lock,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
            ),
            // Middle floating fingerprint
            Positioned(
              top: 200 + (_floatingController.value * 15),
              right: 50,
              child: const Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.fingerprint,
                  size: 120,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomAppBar(ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Text(
            'IDSentinel',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Theme Toggle
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).state = !isDarkMode;
            },
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(width: 8),
          // Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedDashboard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            const Color(0xFF6C5CE7), // Richer purple
            const Color(0xFF0984E3), // Deep blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Top Section: Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Protected',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Your Identity is\nSecure',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Shield Icon with Glow
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Divider(color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),

                // Bottom Section: Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDashboardStat(
                      label: 'Threats',
                      value: '24',
                      icon: Icons.shield_outlined,
                      color: Colors.white,
                    ),
                    Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.2)),
                    _buildDashboardStat(
                      label: 'Safety',
                      value: '87%',
                      icon: Icons.health_and_safety_outlined,
                      color: Colors.greenAccent,
                    ),
                    Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.2)),
                    _buildDashboardStat(
                      label: 'Scans',
                      value: '12',
                      icon: Icons.radar_outlined,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color.withOpacity(0.8), size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturePageView(ThemeData theme) {
    final features = [
      _FeatureData(
        title: 'LeakFinder',
        subtitle: 'Find data breaches',
        description:
            'Check if your personal information has been compromised in data breaches',
        icon: Icons.warning_amber,
        gradient: [Colors.orange, Colors.deepOrange],
        screen: () => const LeakFinderScreen(),
      ),
      _FeatureData(
        title: 'AppCleanse',
        subtitle: 'Scan risky apps',
        description:
            'Identify potentially dangerous applications with excessive permissions',
        icon: Icons.cleaning_services,
        gradient: [Colors.indigo, Colors.purple],
        screen: () => const AppCleanseScreen(),
      ),
      _FeatureData(
        title: 'CNIC Monitor',
        subtitle: 'Track your ID card usage in real-time',
        description:
            'Monitor unauthorized use of your identity card across government and private databases',
        icon: Icons.credit_card,
        gradient: [Colors.purple, Colors.deepPurple],
        screen: () => const CnicMonitorScreen(),
      ),
      _FeatureData(
        title: 'DocGuard',
        subtitle: 'Detect forged documents',
        description:
            'AI-powered document verification to identify fake or tampered documents',
        icon: Icons.document_scanner,
        gradient: [Colors.blue, Colors.cyan],
        screen: () => const DocGuardScreen(),
      ),
      _FeatureData(
        title: 'PhotoShield',
        subtitle: 'Deepfake detection',
        description:
            'Identify manipulated photos and deepfake images using advanced AI',
        icon: Icons.photo_camera,
        gradient: [Colors.teal, Colors.green],
        screen: () => const PhotoShieldScreen(),
      ),
      _FeatureData(
        title: 'MirrorTrace',
        subtitle: 'Track photo misuse',
        description:
            'Find where your photos appear online and detect unauthorized usage',
        icon: Icons.face,
        gradient: [Colors.pink, Colors.red],
        screen: () => const MirrorTraceScreen(),
      ),
      _FeatureData(
        title: 'SMS Scanner',
        subtitle: 'Detect phishing attempts',
        description:
            'Auto-detect fraudulent messages and phishing attempts in your SMS',
        icon: Icons.message,
        gradient: [Colors.amber, Colors.orange],
        screen: () => const SmsScannerScreen(),
      ),
    ];

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemCount: features.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double value = 1.0;
            if (_pageController.position.haveDimensions) {
              value = _pageController.page! - index;
              value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
            }
            return Center(
              child: Transform.scale(
                scale: Curves.easeInOut.transform(value),
                child: child,
              ),
            );
          },
          child: _buildFeatureCard(theme, features[index]),
        );
      },
    );
  }

  Widget _buildFeatureCard(ThemeData theme, _FeatureData feature) {
    return AnimatedBuilder(
      animation: _idleAnimationController,
      builder: (context, child) {
        double scale = 1.0;
        if (_isIdle) {
          scale = 1.0 + (_idleAnimationController.value * 0.05);
        }
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          final screen = feature.screen();
          if (screen != null) {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => screen,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(
                      position: offsetAnimation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: feature.gradient[0].withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: feature.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              // Decorative Pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: CustomPaint(
                    painter: CirclePatternPainter(),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with background
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        feature.icon,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Title with shadow for better readability
                    Text(
                      feature.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 6),

                    // Subtitle with shadow
                    Text(
                      feature.subtitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.4),
                            offset: const Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    // Description with background for better contrast
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        feature.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Action Button - larger and more visible
                    ElevatedButton(
                      onPressed: () {
                        final screen = feature.screen();
                        if (screen != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => screen),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: feature.gradient[0],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Open Feature',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
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
    );
  }

  Widget _buildPageIndicator(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _FeatureData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final Widget? Function() screen;

  _FeatureData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.screen,
  });
}

class CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw circles
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        20.0 + (i * 20),
        paint,
      );
    }

    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.7),
        15.0 + (i * 15),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
