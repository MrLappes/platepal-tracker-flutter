import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  late AnimationController _headerController;
  late AnimationController _contentController;
  late ScrollController _scrollController;

  late Animation<double> _headerOpacity;
  late Animation<Offset> _contentSlide;

  bool _isScrolled = false;

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
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scrollController = ScrollController();

    // Create animations
    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.elasticOut),
    );

    // Add scroll listener
    _scrollController.addListener(_onScroll);

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _contentController.forward();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    if (offset > 10 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (offset <= 10 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleBuyMeCreatine() {
    LinkHandler.openBuyMeCreatine(context);
  }

  void _handleOpenGitHubProfile(String username) {
    LinkHandler.openGitHubProfile(context, username);
  }

  void _handleOpenGitHubRepo() {
    LinkHandler.openGitHubRepo(context, 'MrLappes', 'platepal-tracker');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Animated Header as SliverAppBar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: FadeTransition(
                opacity: _headerOpacity,
                child: Text(
                  localizations?.contributors ?? 'Contributors',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              centerTitle: true,
              background: FadeTransition(
                opacity: _headerOpacity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contributor Count Header
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _headerOpacity,
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFe384c7), // PlatePal color
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${contributors.length} ${contributors.length == 1 ? (localizations?.contributorSingular ?? 'Contributor') : (localizations?.contributorPlural ?? 'Contributors')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: SlideTransition(
              position: _contentSlide,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  children: [
                    // Thank you message
                    FadeTransition(
                      opacity: _headerOpacity,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          localizations?.contributorsThankYou ??
                              'Thanks to everyone who has contributed to making PlatePal Tracker possible!',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Contributors list
                    ...contributors.asMap().entries.map((entry) {
                      final index = entry.key;
                      final contributor = entry.value;
                      return _buildContributorCard(contributor, index);
                    }),

                    const SizedBox(height: 24),

                    // Want to contribute section
                    _buildWantToContributeCard(),

                    const SizedBox(height: 24),

                    // Support development section
                    _buildSupportDevelopmentCard(),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributorCard(Contributor contributor, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top colored strip
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFfba9eb),
                          const Color(0xFFf9c1da),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child:
                                    contributor.avatar != null
                                        ? CachedNetworkImage(
                                          imageUrl: contributor.avatar!,
                                          fit: BoxFit.cover,
                                          errorWidget:
                                              (context, url, error) =>
                                                  const Icon(Icons.person),
                                        )
                                        : const Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Name and role
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contributor.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    contributor.role,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFFe384c7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // GitHub button
                            if (contributor.github != null)
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  onPressed:
                                      () => _handleOpenGitHubProfile(
                                        contributor.github!,
                                      ),
                                  icon: const Icon(Icons.code),
                                  iconSize: 20,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          contributor.description,
                          style: Theme.of(context).textTheme.bodyMedium,
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
    );
  }

  Widget _buildWantToContributeCard() {
    final localizations = AppLocalizations.of(context);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      localizations?.wantToContribute ?? 'Want to Contribute?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations?.openSourceMessage ??
                          'PlatePal Tracker is open source - join us on GitHub!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleOpenGitHubRepo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFe384c7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          localizations?.checkGitHub ??
                              'Check Out Our GitHub Repository',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupportDevelopmentCard() {
    final localizations = AppLocalizations.of(context);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFe384c7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Top colored strip
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFfba9eb),
                          const Color(0xFFf9c1da),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          localizations?.supportDevelopment ??
                              'Support Development',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFe384c7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          localizations?.supportMessage ??
                              'You want to buy me my creatine? Your support is greatly appreciated but not at all mandatory.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _handleBuyMeCreatine,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFe384c7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.local_cafe),
                            label: Text(
                              localizations?.buyMeCreatine ?? 'Buy Me Creatine',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
    );
  }
}
