import 'package:flutter/material.dart';
import '../../../core/utils/animations.dart';

/// Animated card widget with entrance animations and hover effects
/// 
/// This widget provides smooth animations for card entrance and interactions,
/// enhancing the overall user experience with space-themed animations.
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final bool enableHover;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  
  const AnimatedCard({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.enableHover = true,
    this.onTap,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.border,
  });
  
  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _hoverController;
  late Animation<double> _entranceAnimation;
  late Animation<double> _hoverAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Entrance animation
    _entranceController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: AppAnimations.fastOutSlowIn,
    );
    
    // Hover animation
    _hoverController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: AppAnimations.easeOut,
    ));
    
    // Start entrance animation with delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _entranceController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _entranceController.dispose();
    _hoverController.dispose();
    super.dispose();
  }
  
  void _onHoverEnter() {
    if (widget.enableHover) {
      _hoverController.forward();
    }
  }
  
  void _onHoverExit() {
    if (widget.enableHover) {
      _hoverController.reverse();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AppAnimations.slideFromBottom(
      animation: _entranceAnimation,
      offset: 0.3,
      child: FadeTransition(
        opacity: _entranceAnimation,
        child: ScaleTransition(
          scale: _hoverAnimation,
          child: MouseRegion(
            onEnter: (_) => _onHoverEnter(),
            onExit: (_) => _onHoverExit(),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                margin: widget.margin,
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: widget.borderRadius,
                  boxShadow: widget.boxShadow,
                  border: widget.border,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Staggered list animation widget
class StaggeredAnimationList extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Axis scrollDirection;
  final EdgeInsets? padding;
  
  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.staggerDelay = AppAnimations.staggerDelay,
    this.scrollDirection = Axis.vertical,
    this.padding,
  });
  
  @override
  State<StaggeredAnimationList> createState() => _StaggeredAnimationListState();
}

class _StaggeredAnimationListState extends State<StaggeredAnimationList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(
        milliseconds: AppAnimations.medium.inMilliseconds + 
                     (widget.children.length * widget.staggerDelay.inMilliseconds),
      ),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.fastOutSlowIn,
    );
    
    // Start animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AppAnimations.staggeredListItem(
          child: widget.children[index],
          index: index,
          animation: _animation,
        );
      },
    );
  }
}

/// Animated loading widget with space-themed effects
class AnimatedSpaceLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  
  const AnimatedSpaceLoader({
    super.key,
    this.size = 50.0,
    this.color,
    this.duration = const Duration(seconds: 2),
  });
  
  @override
  State<AnimatedSpaceLoader> createState() => _AnimatedSpaceLoaderState();
}

class _AnimatedSpaceLoaderState extends State<AnimatedSpaceLoader>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppAnimations.spaceFloat,
    ));
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.8),
                      color.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.rocket_launch,
                    color: Colors.white,
                    size: widget.size * 0.4,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Hero animation wrapper for navigation
class SpaceHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final Duration duration;
  
  const SpaceHero({
    super.key,
    required this.tag,
    required this.child,
    this.duration = AppAnimations.medium,
  });
  
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (context, animation, direction, fromContext, toContext) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AppAnimations.rocketLaunch,
          )),
          child: child,
        );
      },
      child: child,
    );
  }
}
