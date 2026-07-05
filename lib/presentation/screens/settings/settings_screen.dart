import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProv = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preference Heading
            const Text(
              'Preferences',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary, fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 12),
            
            // Dark Mode Toggle
            _buildSettingCard(
              context,
              child: SwitchListTile(
                value: themeProv.isDarkMode,
                title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                activeColor: AppColors.primary,
                onChanged: (val) {
                  themeProv.toggleTheme(val);
                },
              ),
            ),
            const SizedBox(height: 12),

            // Notifications switch
            _buildSettingCard(
              context,
              child: SwitchListTile(
                value: _notificationsEnabled,
                title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _notificationsEnabled = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),

            // Language Selector Dialog trigger
            _buildSettingCard(
              context,
              child: ListTile(
                leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                title: const Text('App Language', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selectedLanguage, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded, size: 20),
                  ],
                ),
                onTap: _showLanguagePicker,
              ),
            ),
            const SizedBox(height: 24),

            // Legal documentation Heading
            const Text(
              'Legal & Support',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary, fontFamily: 'Outfit'),
            ),
            const SizedBox(height: 12),

            // Privacy Policy
            _buildSettingCard(
              context,
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () => _showDocumentDialog('Privacy Policy'),
              ),
            ),
            const SizedBox(height: 12),

            // Terms and Conditions
            _buildSettingCard(
              context,
              child: ListTile(
                leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                title: const Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () => _showDocumentDialog('Terms & Conditions'),
              ),
            ),
            const SizedBox(height: 12),

            // Support Portal
            _buildSettingCard(
              context,
              child: ListTile(
                leading: const Icon(Icons.support_agent_rounded, color: AppColors.primary),
                title: const Text('Support Desk', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () => _showDocumentDialog('Support Desk'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: child,
    );
  }

  void _showLanguagePicker() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final languages = ['English', 'Español', 'Français', 'Deutsch', 'Hindi'];
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Choose Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((lang) {
              return RadioListTile<String>(
                value: lang,
                groupValue: _selectedLanguage,
                title: Text(lang),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedLanguage = val;
                    });
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showDocumentDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(
          'This is a placeholder document representation for EzzTrip\'s $title. In production, this would load real policy content from a CDN or remote database service.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}
