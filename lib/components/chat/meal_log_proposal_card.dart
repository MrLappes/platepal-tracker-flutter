import 'package:flutter/material.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';

import '../../models/meal_type.dart';
import '../../services/chat/meal_log_proposal.dart';
import '../../services/health_service.dart';
import '../../services/storage/dish_service.dart';
import '../../utils/number_parsing.dart';
import '../modals/dish_log_modal.dart';
import '../modals/quick_add_modal.dart';

/// Status values stored per proposal in the chat message metadata.
const String mealLogProposalLogged = 'logged';
const String mealLogProposalDismissed = 'dismissed';

/// Confirmation card for a `log_meal` proposal of the chat agent. Nothing is
/// written until the user taps Confirm (or saves the Edit sheet).
class MealLogProposalCard extends StatefulWidget {
  const MealLogProposalCard({
    super.key,
    required this.proposal,
    this.status,
    this.onStatusChanged,
    this.dishService,
  });

  /// The stored proposal JSON; `{'error': ...}` for a rejected tool call.
  final Map<String, dynamic> proposal;
  final String? status;
  final ValueChanged<String>? onStatusChanged;
  final DishService? dishService;

  @override
  State<MealLogProposalCard> createState() => _MealLogProposalCardState();
}

class _MealLogProposalCardState extends State<MealLogProposalCard> {
  late final DishService _dishService = widget.dishService ?? DishService();
  late final MealLogProposalLogger _logger = MealLogProposalLogger(
    dishService: _dishService,
  );
  MealLogProposal? _proposal;
  Future<MealLogPreview>? _preview;
  late String? _status = widget.status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    try {
      final proposal = MealLogProposal.fromJson(widget.proposal);
      _proposal = proposal;
      _preview = _logger.preview(proposal);
    } on MealLogProposalException {
      _proposal = null;
    }
  }

  void _setStatus(String status) {
    setState(() => _status = status);
    widget.onStatusChanged?.call(status);
  }

  Future<void> _confirm() async {
    final proposal = _proposal!;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await _logger.confirm(proposal);
      if (!mounted) return;
      _setStatus(mealLogProposalLogged);
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.componentsModalsDishLogModalDishLoggedSuccessfully,
                ),
              ),
              if (HealthService().isConnected)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.sync, size: 16),
                ),
            ],
          ),
        ),
      );
    } catch (error) {
      debugPrint('Logging a chat proposal failed: ${error.runtimeType}');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.componentsModalsDishLogModalErrorLoggingDish),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit(MealLogPreview preview) async {
    final proposal = _proposal!;
    final dish = preview.dish;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) =>
              dish != null
                  ? DishLogModal(
                    dish: dish,
                    initialLoggedAt: proposal.loggedAt,
                    initialMealType: proposal.mealType,
                    initialServings: proposal.servings,
                    dishService: _dishService,
                  )
                  : QuickAddModal(
                    initialLoggedAt: proposal.loggedAt,
                    initialMealType: proposal.mealType,
                    initialName: proposal.name,
                    initialNutrition: preview.totalNutrition,
                    dishService: _dishService,
                  ),
    );
    if (saved == true && mounted) _setStatus(mealLogProposalLogged);
  }

  String _day(AppLocalizations l10n, DateTime loggedAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(loggedAt.year, loggedAt.month, loggedAt.day);
    if (day == today) return l10n.componentsChatMealLogProposalToday;
    if (day == DateTime(now.year, now.month, now.day - 1)) {
      return l10n.componentsChatMealLogProposalYesterday;
    }
    return l10n.componentsChatMealLogProposalOnDate(
      MaterialLocalizations.of(context).formatMediumDate(loggedAt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final proposal = _proposal;
    final preview = _preview;
    return Container(
      key: const ValueKey('meal-log-proposal'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
      ),
      child:
          proposal == null || preview == null
              ? _message(theme, l10n.componentsChatMealLogProposalInvalid)
              : FutureBuilder<MealLogPreview>(
                future: preview,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _resolved(
                      theme,
                      l10n,
                      _message(
                        theme,
                        l10n.componentsChatMealLogProposalDishMissing,
                      ),
                      canConfirm: false,
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return _resolved(
                    theme,
                    l10n,
                    _summary(theme, l10n, proposal, snapshot.data!),
                    preview: snapshot.data,
                  );
                },
              ),
    );
  }

  Widget _message(ThemeData theme, String text) => Row(
    children: [
      Icon(Icons.info_outline, size: 18, color: theme.colorScheme.error),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
    ],
  );

  Widget _summary(
    ThemeData theme,
    AppLocalizations l10n,
    MealLogProposal proposal,
    MealLogPreview preview,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final mealType = MealType.fromString(
      proposal.mealType,
    ).localizedDisplayName(l10n);
    final day = _day(l10n, proposal.loggedAt);
    final calories = preview.totalNutrition.calories.round().toString();
    final summary =
        proposal.servings == 1
            ? l10n.componentsChatMealLogProposalSummaryOne(
              preview.name,
              mealType,
              day,
              calories,
            )
            : l10n.componentsChatMealLogProposalSummaryOther(
              formatAmount(proposal.servings, locale),
              preview.name,
              mealType,
              day,
              calories,
            );
    final time = TimeOfDay.fromDateTime(proposal.loggedAt).format(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.edit_calendar, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                '${MaterialLocalizations.of(context).formatMediumDate(proposal.loggedAt)}, $time · '
                '${l10n.screensDishCreateProteinAbbreviation} ${formatDecimal(preview.totalNutrition.protein, locale)} g · '
                '${l10n.screensDishCreateCarbsAbbreviation} ${formatDecimal(preview.totalNutrition.carbs, locale)} g · '
                '${l10n.screensDishCreateFatAbbreviation} ${formatDecimal(preview.totalNutrition.fat, locale)} g',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _resolved(
    ThemeData theme,
    AppLocalizations l10n,
    Widget content, {
    MealLogPreview? preview,
    bool canConfirm = true,
  }) {
    final status = _status;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        content,
        const SizedBox(height: 8),
        if (status == mealLogProposalLogged)
          _statusLine(theme, Icons.check_circle, l10n.componentsChatMealLogProposalLogged)
        else if (status == mealLogProposalDismissed)
          _statusLine(theme, Icons.block, l10n.componentsChatMealLogProposalDismissed)
        else
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              TextButton(
                onPressed:
                    _busy ? null : () => _setStatus(mealLogProposalDismissed),
                child: Text(l10n.componentsChatMealLogProposalDismiss),
              ),
              if (canConfirm && preview != null) ...[
                OutlinedButton(
                  onPressed: _busy ? null : () => _edit(preview),
                  child: Text(l10n.componentsChatMealLogProposalEdit),
                ),
                FilledButton(
                  onPressed: _busy ? null : _confirm,
                  child: Text(l10n.componentsChatMealLogProposalConfirm),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _statusLine(ThemeData theme, IconData icon, String text) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
      const SizedBox(width: 4),
      Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}
