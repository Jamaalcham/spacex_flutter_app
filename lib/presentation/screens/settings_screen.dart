import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/spacing.dart';
import '../../core/utils/typography.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/common/glass_background.dart';
import '../widgets/common/custom_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar without back arrow
              CustomAppBar.settings(),
              
              // Settings Content
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.paddingHorizontalM,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 3.h),
                      
                      // APPEARANCE Section
                      _buildSectionLabel('APPEARANCE'),
                      SizedBox(height: 2.h),
                      _buildAppearanceSection(),
                      SizedBox(height: 4.h),
                      
                      // GENERAL Section
                      _buildSectionLabel('GENERAL'),
                      SizedBox(height: 2.h),
                      _buildGeneralSection(),
                      SizedBox(height: 4.h),
                      
                      // ABOUT Section
                      _buildSectionLabel('ABOUT'),
                      SizedBox(height: 2.h),
                      _buildAboutSection(),
                      SizedBox(height: 10.h), // Bottom padding for navigation
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSectionLabel(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: AppTypography.getCaption(isDark).copyWith(
        fontWeight: AppTypography.medium,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha:0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha:0.1) : Colors.black.withValues(alpha:0.1),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              _buildSettingItem(
                icon: themeProvider.themeMode == ThemeMode.dark 
                    ? Icons.dark_mode 
                    : Icons.light_mode_outlined,
                title: 'Dark Mode',
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                  activeColor: isDark ? Colors.grey[400] :AppColors.spaceBlue,
                  inactiveThumbColor: isDark ? Colors.grey[400] : Colors.grey[600],
                  inactiveTrackColor: isDark
                      ? Colors.grey[800]
                      : Colors.grey[300],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGeneralSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha:0.05) : Colors.white.withValues(alpha:0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha:0.1) : Colors.black.withValues(alpha:0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () {
              // Handle notifications tap
            },
          ),
          _buildDivider(),
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, child) {
              return _buildSettingItem(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: languageProvider.currentLanguageName,
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
                onTap: () => _showLanguageDialog(languageProvider),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha:0.05) : Colors.white.withValues(alpha:0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha:0.1) : Colors.black.withValues(alpha:0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.tag,
            title: 'Version',
            subtitle: '1.0.0',
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.shield_outlined,
            title: 'Privacy Policy',
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () {
              // Handle privacy policy tap
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
            onTap: () {
              // Handle terms of service tap
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: AppColors.spaceBlue,
                
                borderRadius: BorderRadius.circular(50)
              ),
              child: Icon(
                icon,
                size: 6.w,
                color: isDark ? Colors.white : Colors.white,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.getBody(isDark),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle,
                      style: AppTypography.getCaption(isDark),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 0.5,
      color: isDark ? Colors.white.withValues(alpha:0.1) : Colors.black.withValues(alpha:0.1),
      indent: 14.w,
    );
  }

  void _showLanguageDialog(LanguageProvider languageProvider) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1C1C1E)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Choose Language',
          style: AppTypography.getTitle(Theme.of(context).brightness == Brightness.dark).copyWith(
            fontWeight: AppTypography.medium,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              'English',
              const Locale('en', 'US'),
              languageProvider,
            ),
            _buildLanguageOption(
              'Français',
              const Locale('fr', 'FR'),
              languageProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    String title,
    Locale locale,
    LanguageProvider languageProvider,
  ) {
    final isSelected = languageProvider.locale == locale;
    
    return InkWell(
      onTap: () async {
        await languageProvider.changeLanguage(locale.languageCode, context);
        Get.back();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.symmetric(vertical: 1.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.spaceBlue.withValues(alpha:0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.spaceBlue
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: AppTypography.getBody(Theme.of(context).brightness == Brightness.dark).copyWith(
                fontWeight: isSelected ? AppTypography.medium : AppTypography.regular,
                color: isSelected
                    ? AppColors.spaceBlue
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
