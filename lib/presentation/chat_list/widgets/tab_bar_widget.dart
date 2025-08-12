import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TabBarWidget extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;

  const TabBarWidget({
    Key? key,
    required this.tabController,
    required this.tabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        tabs: tabs
            .map((tab) => Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      tab,
                      style: AppTheme.lightTheme.textTheme.labelLarge,
                    ),
                  ),
                ))
            .toList(),
        labelColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        indicatorColor: AppTheme.lightTheme.colorScheme.primary,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle:
            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        overlayColor: WidgetStateProperty.all(
          AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}
