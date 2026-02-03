import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/link_handler.dart';

class Contributor {
  final String name;
  final String role;
  final String description;
  final String? github;
  final String? avatar;

  const Contributor({
    required this.name,
    required this.role,
    required this.description,
    this.github,
    this.avatar,
  });
}

class ContributorsScreen extends StatefulWidget {
  const ContributorsScreen({super.key});

  @override
  State<ContributorsScreen> createState() => _ContributorsScreenState();
}

class _ContributorsScreenState extends State<ContributorsScreen>
    with TickerProviderStateMixin {
  late AnimationController _contentController;
  late ScrollController _scrollController;
  late Animation<Offset> _contentSlide;

  // List of contributors
  final List<Contributor> contributors = [
    const Contributor(
      name: "MrLappes",
      role: "Creator & Developer",
      description:
          "Created PlatePal Tracker with the vision of making a free, privacy-focused nutrition app for everyone.",
      github: "MrLappes",
      avatar: "https://avatars.githubusercontent.com/u/79363858?v=4",
    ),
    const Contributor(
      name: "Hans Klugsam",
      role: "AI Co-pilot & Resident Hacker",
      description: "Automating the grind and keeping the telemetry crisp. Cyber-minimalism architect.",
      github: "hansklugsam",
      avatar: "https://avatars.githubusercontent.com/u/258904569?v=4",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scrollController = ScrollController();
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));
    _contentController.forward();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildContributorCard(Contributor contributor, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: contributor.avatar != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: CachedNetworkImage(
                            imageUrl: contributor.avatar!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.person, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contributor.name.toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        contributor.role.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (contributor.github != null)
                  IconButton(
                    onPressed: () => LinkHandler.openGitHubProfile(context, contributor.github!),
                    icon: const Icon(Icons.terminal, size: 18),
                    color: colorScheme.primary,
                  ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, thickness: 0.5),
            ),
            Text(
              contributor.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('CONTRIBUTORS //'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SlideTransition(
        position: _contentSlide,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'NETWORK OPERATIVES',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            ...contributors.map((c) => _buildContributorCard(c, context)),
            const SizedBox(height: 32),
            
            // Industrial Style "Join" card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Text(
                    'WANT TO CONTRIBUTE?',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PLATEPAL IS OPEN SOURCE. CHECK THE MAIN REPO ON GITHUB.',
                    style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 0.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => LinkHandler.openGitHubRepo(context, 'MrLappes', 'platepal-tracker-flutter'),
                      child: const Text('SOURCE_CODE'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
