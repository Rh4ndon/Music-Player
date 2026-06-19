import 'package:flutter/material.dart';
import 'package:music_player/core/theme/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SettingsSection(
          title: 'PLAYBACK',
          children: [
            _SettingsTile(
              icon: Icons.equalizer,
              title: 'Equalizer',
              subtitle: 'Adjust audio frequencies',
            ),
            _SettingsTile(
              icon: Icons.volume_up,
              title: 'Volume boost',
              subtitle: 'Increase max volume',
              trailing: Switch(value: false, onChanged: null),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _SettingsSection(
          title: 'DISPLAY',
          children: [
            _SettingsTile(
              icon: Icons.dark_mode,
              title: 'Dark theme',
              subtitle: 'Always use dark mode',
              trailing: Switch(value: true, onChanged: null),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsSection(
          title: 'ABOUT',
          children: [
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'Version',
              subtitle: '1.0.0',
            ),
            _SettingsTile(
              icon: Icons.code,
              title: 'Built with Flutter',
              subtitle: 'Music Player',
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 24),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: trailing,
    );
  }
}
