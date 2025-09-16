import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/spacing.dart';
import '../../core/utils/typography.dart';
import '../../domain/entities/rocket_entity.dart';
import '../providers/rocket_provider.dart';
import '../widgets/common/glass_background.dart';
import '../widgets/common/modern_card.dart';
import '../widgets/common/network_error_widget.dart';

// Rocket Detail Screen
/// Displays detailed information about a specific rocket including
/// image carousel, specifications, and technical details.
class RocketDetailScreen extends StatefulWidget {
  final String rocketId;
  final RocketEntity? rocket;

  const RocketDetailScreen({
    super.key,
    required this.rocketId,
    this.rocket,
  });

  @override
  State<RocketDetailScreen> createState() => _RocketDetailScreenState();
}

class _RocketDetailScreenState extends State<RocketDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  RocketEntity? _rocket;
  bool _isLoading = false;
  String? _error;
  Timer? _autoSlideTimer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _rocket = widget.rocket;
    if (_rocket == null) {
      _fetchRocketDetails();
    } else {
      _startAutoSlide();
    }
  }

  /// Fetches rocket details if not provided
  Future<void> _fetchRocketDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<RocketProvider>();
      final rocket = await provider.getRocketById(widget.rocketId);
      
      if (rocket != null) {
        setState(() {
          _rocket = rocket;
        });
        _startAutoSlide();
      } else {
        setState(() {
          _error = 'Rocket not found';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load rocket details';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(isDark),
              
              // Content
              Expanded(
                child: _buildContent(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Starts auto-slide timer for carousel
  void _startAutoSlide() {
    if (_rocket?.flickrImages == null || _rocket!.flickrImages!.isEmpty) return;
    
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isUserInteracting && mounted) {
        final nextIndex = (_currentImageIndex + 1) % _rocket!.flickrImages!.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Stops auto-slide timer
  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
  }

  /// Resumes auto-slide after user interaction
  void _resumeAutoSlide() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isUserInteracting = false;
        });
        _startAutoSlide();
      }
    });
  }

  /// Builds custom app bar
  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: isDark ? Colors.white : Colors.black87,
                size: 20.sp,
              ),
            ),
          ),
          
          SizedBox(width: 4.w),
          
          // Title
          Expanded(
            child: Text(
              _rocket?.name ?? 'Rocket Details',
              style: AppTypography.getTitle(isDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Share button
          InkWell(
            onTap: () => _shareRocket(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
              child: Icon(
                Icons.share,
                color: isDark ? Colors.white : Colors.black87,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds main content
  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_error != null) {
      return NetworkErrorWidget(
        onRetry: _fetchRocketDetails,
      );
    }

    if (_rocket == null) {
      return Center(
        child: Text(
          'No rocket data available',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 16.sp,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Carousel
          _buildImageCarousel(),
          
          // Rocket Information
          _buildRocketInfo(isDark),
          
          // Specifications
          _buildSpecifications(isDark),

          // Engines Information
          _buildEnginesInfo(isDark),
          
          // Payload Information
          _buildPayloadInfo(isDark),
          
          // Additional Details
          _buildAdditionalDetails(isDark),
          
          SizedBox(height: 4.w),
        ],
      ),
    );
  }

  /// Builds image carousel
  Widget _buildImageCarousel() {
    final images = _rocket?.flickrImages ?? [];
    
    if (images.isEmpty) {
      return Container(
        height: 50.h,
        margin: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rocket_launch,
                size: 20.w,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              SizedBox(height: 2.w),
              Text(
                'No Images Available',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Custom Image Carousel using PageView
        Container(
          height: 50.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          child: GestureDetector(
            onPanStart: (_) {
              setState(() {
                _isUserInteracting = true;
              });
              _stopAutoSlide();
            },
            onPanEnd: (_) {
              _resumeAutoSlide();
            },
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GestureDetector(
                    onTap: () => _openImageViewer(imageUrl, index),
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 3.0,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF1E3A8A),
                            const Color(0xFF3B82F6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white.withValues(alpha: 0.7),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF1E3A8A),
                            const Color(0xFF3B82F6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 15.w,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                      ),
                    ),
                  ),
                ),
              );
            },
            ),
          )),
        
        // Image indicators
        if (images.length > 1) ...[
          SizedBox(height: 3.w),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              return Container(
                width: _currentImageIndex == entry.key ? 8.w : 2.w,
                height: 2.w,
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.w),
                  color: _currentImageIndex == entry.key
                      ? AppColors.spaceBlue
                      : Colors.white.withValues(alpha: 0.3),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// Builds rocket information section
  Widget _buildRocketInfo(bool isDark) {
    return ModernCard(
      isDark: isDark,
      margin: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _rocket!.name ?? 'Unknown Rocket',
            style: AppTypography.getHeadline(isDark),
          ),
          
          SizedBox(height: 2.w),
          
          // Status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
            decoration: BoxDecoration(
              color: _rocket!.active == true
                  ? AppColors.missionGreen
                  : AppColors.textSecondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _rocket!.active == true ? 'ACTIVE' : 'RETIRED',
              style: AppTypography.captionLight.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          SizedBox(height: 4.w),
          
          // Description
          Text(
            _rocket!.description ?? 'No description available',
            style: AppTypography.getBody(isDark),
          ),
          
          SizedBox(height: 4.w),
          
          // Basic info grid
          _buildInfoGrid([
            _InfoItem('Country', _rocket!.country ?? 'Unknown'),
            _InfoItem('Company', _rocket!.company ?? 'Unknown'),
            _InfoItem('First Flight', _rocket!.firstFlight ?? 'Unknown'),
            _InfoItem('Success Rate', '${_rocket!.successRatePct?.toInt() ?? 0}%'),
          ], isDark),
        ],
      ),
    );
  }

  /// Builds specifications section
  Widget _buildSpecifications(bool isDark) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specifications',
            style: AppTypography.getTitle(isDark),
          ),
          
          SizedBox(height: 4.w),
          
          _buildInfoGrid([
            _InfoItem('Height', '${_rocket!.height?.meters?.toStringAsFixed(1) ?? 'Unknown'} m'),
            _InfoItem('Diameter', '${_rocket!.diameter?.meters?.toStringAsFixed(1) ?? 'Unknown'} m'),
            _InfoItem('Mass', '${_rocket!.mass?.kg?.toStringAsFixed(0) ?? 'Unknown'} kg'),
            _InfoItem('Stages', '${_rocket!.stages ?? 'Unknown'}'),
            _InfoItem('Boosters', '${_rocket!.boosters ?? 0}'),
            _InfoItem('Cost per Launch', '\$${_formatCurrency(_rocket!.costPerLaunch)}'),
          ], isDark),
        ],
      ),
    );
  }

  /// Builds engines information section
  Widget _buildEnginesInfo(bool isDark) {
    final engines = _rocket!.engines;
    if (engines == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engines',
            style: AppTypography.getTitle(isDark),
          ),
          
          SizedBox(height: 4.w),
          
          _buildInfoGrid([
            _InfoItem('Number', '${engines.number ?? 'Unknown'}'),
            _InfoItem('Type', engines.type ?? 'Unknown'),
            _InfoItem('Version', engines.version ?? 'Unknown'),
            _InfoItem('Layout', engines.layout ?? 'Unknown'),
            _InfoItem('Propellant 1', engines.propellant1 ?? 'Unknown'),
            _InfoItem('Propellant 2', engines.propellant2 ?? 'Unknown'),
          ], isDark),
          
          if (engines.thrustSeaLevel != null) ...[
            SizedBox(height: 3.w),
            Text(
              'Thrust (Sea Level)',
              style: AppTypography.getBody(isDark).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.w),
            _buildInfoGrid([
              _InfoItem('kN', '${engines.thrustSeaLevel!.kN?.toStringAsFixed(0) ?? 'Unknown'}'),
              _InfoItem('lbf', '${engines.thrustSeaLevel!.lbf?.toStringAsFixed(0) ?? 'Unknown'}'),
            ], isDark),
          ],
          
          if (engines.thrustVacuum != null) ...[
            SizedBox(height: 3.w),
            Text(
              'Thrust (Vacuum)',
              style: AppTypography.getBody(isDark).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.w),
            _buildInfoGrid([
              _InfoItem('kN', '${engines.thrustVacuum!.kN?.toStringAsFixed(0) ?? 'Unknown'}'),
              _InfoItem('lbf', '${engines.thrustVacuum!.lbf?.toStringAsFixed(0) ?? 'Unknown'}'),
            ], isDark),
          ],
        ],
      ),
    );
  }

  /// Builds payload information section
  Widget _buildPayloadInfo(bool isDark) {
    final payloads = _rocket!.payloadWeights;
    if (payloads == null || payloads.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payload Weights',
            style: AppTypography.getTitle(isDark),
          ),
          
          SizedBox(height: 4.w),
          
          ...payloads.map((payload) => Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 3.w),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payload.name ?? 'Unknown',
                  style: AppTypography.getBody(isDark).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.w),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Weight: ${payload.kg?.toStringAsFixed(0) ?? 'Unknown'} kg',
                        style: AppTypography.getCaption(isDark),
                      ),
                    ),
                    Text(
                      '${payload.lb?.toStringAsFixed(0) ?? 'Unknown'} lb',
                      style: AppTypography.getCaption(isDark),
                    ),
                  ],
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  /// Builds additional details section
  Widget _buildAdditionalDetails(bool isDark) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: AppTypography.getTitle(isDark),
          ),
          
          SizedBox(height: 4.w),
          
          if (_rocket!.wikipedia != null) ...[
            _buildActionButton(
              'View on Wikipedia',
              Icons.language,
              () => _openUrl(_rocket!.wikipedia!),
              isDark,
            ),
            SizedBox(height: 3.w),
          ],
          
          _buildActionButton(
            '3D Model Coming Soon!',
            Icons.view_in_ar,
            () => Get.snackbar(
              '3D Model',
              'Coming soon in future updates!',
              backgroundColor: AppColors.spaceBlue.withValues(alpha: 0.8),
              colorText: Colors.white,
            ),
            isDark,
          ),
        ],
      ),
    );
  }

  /// Builds info grid
  Widget _buildInfoGrid(List<_InfoItem> items, bool isDark) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2) ...[
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(items[i], isDark),
              ),
              if (i + 1 < items.length) ...[
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildInfoItem(items[i + 1], isDark),
                ),
              ] else ...[
                Expanded(child: Container()),
              ],
            ],
          ),
          if (i + 2 < items.length) SizedBox(height: 3.w),
        ],
      ],
    );
  }

  /// Builds individual info item
  Widget _buildInfoItem(_InfoItem item, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: AppTypography.getCaption(isDark).copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.w),
        Text(
          item.value,
          style: AppTypography.getBody(isDark).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Builds action button
  Widget _buildActionButton(String text, IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.spaceBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.3)
                : AppColors.spaceBlue.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white : AppColors.spaceBlue,
              size: 20.sp,
            ),
            SizedBox(width: 3.w),
            Text(
              text,
              style: AppTypography.getBody(isDark).copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.spaceBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats currency
  String _formatCurrency(int? amount) {
    if (amount == null) return 'Unknown';
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }

  /// Opens fullscreen image viewer
  void _openImageViewer(String imageUrl, int initialIndex) {
    Get.to(
      () => _FullscreenImageViewer(
        images: _rocket!.flickrImages!,
        initialIndex: initialIndex,
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  /// Shares rocket information
  void _shareRocket() {
    Get.snackbar(
      'Share',
      'Rocket ${_rocket?.name} details shared!',
      backgroundColor: AppColors.spaceBlue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Opens URL
  void _openUrl(String url) {
    Get.snackbar(
      'External Link',
      'Opening external links coming soon!',
      backgroundColor: AppColors.spaceBlue.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
  }
}

/// Info item class for displaying key-value pairs
class _InfoItem {
  final String label;
  final String value;

  _InfoItem(this.label, this.value);
}

/// Fullscreen image viewer with zoom functionality
class _FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullscreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 5.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
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
