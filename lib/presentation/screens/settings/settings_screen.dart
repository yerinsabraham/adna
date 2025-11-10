import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../utils/helpers.dart';
import '../../providers/auth_provider.dart';
import 'profile_screen.dart';
import 'change_password_screen.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
    );

    if (confirmed && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: AppTextStyles.h5,
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final merchant = authProvider.merchant;
          final user = authProvider.user;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.business,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            merchant?.businessName ?? 'Business Name',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Account Section
              _buildSectionTitle('Account'),
              const SizedBox(height: 8),
              _buildSettingsCard([
                _buildSettingItem(
                  context,
                  'Profile',
                  'View and edit your profile',
                  Icons.person_outline,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                ),
                const Divider(height: 24),
                _buildSettingItem(
                  context,
                  'Change Password',
                  'Update your password',
                  Icons.lock_outline,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              // Business Section
              _buildSectionTitle('Business'),
              const SizedBox(height: 8),
              _buildSettingsCard([
                _buildSettingItem(
                  context,
                  'Business Information',
                  'View your business details',
                  Icons.business_outlined,
                  () {
                    Helpers.showInfo(context, 'Feature coming soon');
                  },
                ),
                const Divider(height: 24),
                _buildSettingItem(
                  context,
                  'Bank Account',
                  'Manage settlement account',
                  Icons.account_balance,
                  () {
                    Helpers.showInfo(context, 'Feature coming soon');
                  },
                ),
                const Divider(height: 24),
                _buildSettingItem(
                  context,
                  'Documents',
                  'View KYC documents',
                  Icons.folder_outlined,
                  () {
                    Helpers.showInfo(context, 'Feature coming soon');
                  },
                ),
              ]),
              const SizedBox(height: 16),
              // Support Section
              _buildSectionTitle('Support'),
              const SizedBox(height: 8),
              _buildSettingsCard([
                _buildSettingItem(
                  context,
                  'Help Center',
                  'Get help and support',
                  Icons.help_outline,
                  () {
                    Helpers.showInfo(context, 'Contact support@adna.ng');
                  },
                ),
                const Divider(height: 24),
                _buildSettingItem(
                  context,
                  'Terms & Conditions',
                  'Read our terms',
                  Icons.description_outlined,
                  () {
                    Helpers.showInfo(context, 'Feature coming soon');
                  },
                ),
                const Divider(height: 24),
                _buildSettingItem(
                  context,
                  'Privacy Policy',
                  'Read our privacy policy',
                  Icons.privacy_tip_outlined,
                  () {
                    Helpers.showInfo(context, 'Feature coming soon');
                  },
                ),
              ]),
              const SizedBox(height: 24),
              // Sign Out Button
              _buildSettingsCard([
                _buildSettingItem(
                  context,
                  'Sign Out',
                  'Sign out of your account',
                  Icons.logout,
                  () => _handleSignOut(context),
                  isDestructive: true,
                ),
              ]),
              const SizedBox(height: 16),
              // Version
              Center(
                child: Text(
                  'Adna v1.0.0',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
    Color? color,
  }) {
    final textColor = isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconColor = color ?? (isDestructive ? AppColors.error : AppColors.primary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
