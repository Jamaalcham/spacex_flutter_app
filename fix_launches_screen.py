#!/usr/bin/env python3
import re

# Read the launches screen file
file_path = r"c:\Users\Jamaal CHam\Desktop\spacex_flutter_app\lib\presentation\screens\launches_screen.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Replace LaunchCard with ModernCard implementation
launch_card_pattern = r'\.\.\.launchProvider\.launches\.map\(\(launch\) =>\s*LaunchCard\(\s*launch: launch,\s*onTap: \(\) \{\s*// TODO: Navigate to launch details\s*\},\s*\)\),'

modern_card_replacement = '''...launchProvider.launches.map((launch) =>
                    ModernCard(
                      isDark: isDark,
                      margin: const EdgeInsets.only(bottom: AppSpacing.m),
                      onTap: () {
                        // TODO: Navigate to launch details
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            launch.missionName,
                            style: AppTypography.getTitle(isDark),
                          ),
                          if (launch.details != null) ...[
                            AppSpacing.gapVerticalXS,
                            Text(
                              launch.details!,
                              style: AppTypography.getBody(isDark),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          AppSpacing.gapVerticalS,
                          Row(
                            children: [
                              Container(
                                padding: AppSpacing.paddingXS,
                                decoration: BoxDecoration(
                                  color: launch.success == true 
                                      ? AppColors.missionGreen
                                      : launch.success == false
                                          ? AppColors.rocketOrange
                                          : AppColors.spaceBlue,
                                  borderRadius: BorderRadius.circular(AppSpacing.s),
                                ),
                                child: Text(
                                  launch.success == true 
                                      ? 'Success'
                                      : launch.success == false
                                          ? 'Failed'
                                          : 'Upcoming',
                                  style: AppTypography.getCaption(isDark).copyWith(
                                    color: Colors.white,
                                    fontWeight: AppTypography.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (launch.dateUtc != null)
                                Text(
                                  _formatDate(launch.dateUtc!),
                                  style: AppTypography.getCaption(isDark),
                                ),
                            ],
                          ),
                          if (launch.flightNumber != null) ...[
                            AppSpacing.gapVerticalXS,
                            Text(
                              'Flight #${launch.flightNumber}',
                              style: AppTypography.getCaption(isDark),
                            ),
                          ],
                        ],
                      ),
                    )),'''

content = re.sub(launch_card_pattern, modern_card_replacement, content, flags=re.MULTILINE | re.DOTALL)

# 2. Replace padding in launches tab
content = content.replace(
    'padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),',
    'padding: AppSpacing.paddingHorizontalM,'
)

# 3. Replace button padding
content = content.replace(
    'padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),',
    'padding: AppSpacing.paddingM,'
)

# 4. Add _formatDate method before the last closing brace
format_date_method = '''
  /// Formats date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d from now';
    } else if (difference.inDays < 0) {
      return '${-difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h from now';
    } else if (difference.inHours < 0) {
      return '${-difference.inHours}h ago';
    } else {
      return 'Today';
    }
  }
'''

# Find the last closing brace and add the method before it
content = content.rstrip()
if content.endswith('}'):
    content = content[:-1] + format_date_method + '\n}'

# Write the updated content back to the file
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Successfully updated launches screen to use ModernCard consistently!")
