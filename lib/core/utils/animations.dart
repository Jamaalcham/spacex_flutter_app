import 'package:flutter/material.dart';

// Animation utilities and constants for the SpaceX app

class AppAnimations {
  // Animation Durations
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // Animation Curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  
  // Space-themed custom curves
  static const Curve rocketLaunch = Curves.easeInExpo;
  static const Curve satelliteOrbit = Curves.easeInOutCubic;
  static const Curve spaceFloat = Curves.easeInOutSine;
  
  // Stagger delays for list animations
  static const Duration staggerDelay = Duration(milliseconds: 100);
  static const Duration microStagger = Duration(milliseconds: 50);
  
  // Creates a slide transition from bottom
  static Widget slideFromBottom({
    required Widget child,
    required Animation<double> animation,
    double offset = 1.0,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0.0, offset),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: fastOutSlowIn,
      )),
      child: child,
    );
  }
  
  // Creates a slide transition from right
  static Widget slideFromRight({
    required Widget child,
    required Animation<double> animation,
    double offset = 1.0,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(offset, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: fastOutSlowIn,
      )),
      child: child,
    );
  }
  
  // Creates a fade and scale transition
  static Widget fadeAndScale({
    required Widget child,
    required Animation<double> animation,
    double scaleBegin = 0.8,
  }) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: scaleBegin,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: easeOut,
        )),
        child: child,
      ),
    );
  }
  
  // Creates a staggered list animation
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    required Animation<double> animation,
  }) {
    final delay = index * staggerDelay.inMilliseconds;
    final delayedAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Interval(
        delay / 1000.0,
        1.0,
        curve: fastOutSlowIn,
      ),
    ));
    
    return slideFromBottom(
      child: FadeTransition(
        opacity: delayedAnimation,
        child: child,
      ),
      animation: delayedAnimation,
      offset: 0.3,
    );
  }
  
  // Creates a rocket launch animation (scale + slide)
  static Widget rocketLaunchAnimation({
    required Widget child,
    required Animation<double> animation,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: rocketLaunch,
      )),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.3,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: elasticOut,
        )),
        child: child,
      ),
    );
  }
  
  // Creates a floating animation for space elements
  static Widget floatingAnimation({
    required Widget child,
    required AnimationController controller,
  }) {
    final animation = Tween<double>(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: spaceFloat,
    ));
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: child,
        );
      },
      child: child,
    );
  }
}

// Custom page route with smooth transitions
class SpacePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final PageTransitionType transitionType;
  
  SpacePageRoute({
    required this.child,
    this.duration = AppAnimations.medium,
    this.curve = AppAnimations.fastOutSlowIn,
    this.transitionType = PageTransitionType.slideFromRight,
    super.settings,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
  );
  
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (transitionType) {
      case PageTransitionType.slideFromRight:
        return AppAnimations.slideFromRight(
          child: child,
          animation: animation,
        );
      case PageTransitionType.slideFromBottom:
        return AppAnimations.slideFromBottom(
          child: child,
          animation: animation,
        );
      case PageTransitionType.fadeAndScale:
        return AppAnimations.fadeAndScale(
          child: child,
          animation: animation,
        );
      case PageTransitionType.rocketLaunch:
        return AppAnimations.rocketLaunchAnimation(
          child: child,
          animation: animation,
        );
    }
  }
}

// Page transition types
enum PageTransitionType {
  slideFromRight,
  slideFromBottom,
  fadeAndScale,
  rocketLaunch,
}

// Animated button with micro-interactions
class AnimatedSpaceButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double scaleDown;
  
  const AnimatedSpaceButton({
    super.key,
    required this.child,
    this.onTap,
    this.duration = AppAnimations.ultraFast,
    this.scaleDown = 0.95,
  });
  
  @override
  State<AnimatedSpaceButton> createState() => _AnimatedSpaceButtonState();
}

class _AnimatedSpaceButtonState extends State<AnimatedSpaceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
