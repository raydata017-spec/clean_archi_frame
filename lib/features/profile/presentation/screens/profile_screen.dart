import 'package:flutter/material.dart';

import '../../../../app/config/dimensions.dart';
import '../../../../app/config/localization/generated/translations.g.dart';
import '../../../../core/utils/extensions/app_bar_extension.dart';
import '../widgets/profile_action_row.dart';
import '../widgets/profile_header_app_bar.dart';
import '../widgets/profile_info_row.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Static Mock Data for User Information
    const String userName = 'Jane Doe';
    const String userEmail = 'jane.doe@example.com';
    const String userPhone = '+95 9 123 456 789';
    const String userJoined = 'September 12, 2025';
    const String userRole = 'Commercial Pro';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          ProfileHeaderAppBar(
            userName: userName,
            userEmail: userEmail,
            userRole: userRole,
            leading: context.drawerLeading,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.paddingFromScreenEdge),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const ProfileSectionHeader(title: 'Personal Information'),
                  const SizedBox(height: AppSizes.spaceBtwTexts),
                  const ProfileSectionCard(
                    children: [
                      ProfileInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: userEmail,
                      ),
                      ProfileInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: userPhone,
                      ),
                      ProfileInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Joined',
                        value: userJoined,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  const ProfileSectionHeader(title: 'Settings & Security'),
                  const SizedBox(height: AppSizes.spaceBtwTexts),
                  ProfileSectionCard(
                    children: [
                      ProfileActionRow(
                        icon: Icons.person_outline,
                        title: 'Edit Profile Details',
                        onTap: () {},
                      ),
                      ProfileActionRow(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        onTap: () {},
                      ),
                      ProfileActionRow(
                        icon: Icons.notifications_none,
                        title: t.setting.notificationSetting,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  ProfileSectionCard(
                    children: [
                      ProfileActionRow(
                        icon: Icons.logout,
                        title: t.auth.logout,
                        iconColor: colorScheme.error,
                        textColor: colorScheme.error,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
