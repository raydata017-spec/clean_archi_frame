import 'package:flutter/material.dart';
import '../../../../app/config/dimensions.dart';

class ProfileHeaderAppBar extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;
  final Widget? leading;

  const ProfileHeaderAppBar({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: AppSizes.titleContainerHeight,
      pinned: true,
      leading: leading,
      backgroundColor: colorScheme.primary,
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final isCollapsed = top <= (MediaQuery.of(context).padding.top + kToolbarHeight);

          return FlexibleSpaceBar(
            centerTitle: false,
            title: isCollapsed
                ? Text(
                    userName,
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  )
                : null,
            background: Container(
              color: colorScheme.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingFromScreenEdge,
              ),
              alignment: Alignment.centerLeft,
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: AppSizes.profilePicLg,
                      backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.person,
                        size: AppSizes.iconLg,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spaceBtwItems),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.paddingMarginSm,
                                  vertical: AppSizes.paddingMarginXs,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.onPrimary.withValues(alpha: 0.2),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(AppSizes.borderRadiusSm),
                                  ),
                                ),
                                child: Text(
                                  userRole,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.paddingMarginXs),
                          Text(
                            userName,
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingMarginXs),
                          Text(
                            userEmail,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary.withValues(alpha: 0.8),
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
        },
      ),
    );
  }
}
