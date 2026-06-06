import 'package:crid/app/app_state.dart';
import 'package:crid/app/motion.dart';
import 'package:crid/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppDestination {
  const AppDestination({
    required this.path,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final IconData icon;
  final IconData selectedIcon;
}

const appDestinations = [
  AppDestination(
    path: '/timetable',
    icon: Icons.calendar_today_outlined,
    selectedIcon: Icons.calendar_today,
  ),
  AppDestination(
    path: '/plans',
    icon: Icons.view_timeline_outlined,
    selectedIcon: Icons.view_timeline,
  ),
];

const _topBarActionExtent = 48.0;

class AdaptiveShell extends ConsumerStatefulWidget {
  const AdaptiveShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends ConsumerState<AdaptiveShell> {
  var _railCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final location = uri.path;
    final selectedIndex = _selectedIndexForUri(uri);
    final title = _routeTitle(context, uri);
    final isCoreRoute = _isCoreLocation(location);
    final canPopWithSystem = _canPopWithSystem(context, uri);
    final actionVisibility = _ShellActionVisibility.forLocation(location);

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (!context.canPop() &&
            _isCoreLocation(uri.path) &&
            uri.path != '/timetable') {
          context.go('/timetable');
          _requestTimetableAutoScrollAfterNavigation();
          return true;
        }
        return false;
      },
      child: PopScope<Object?>(
        canPop: canPopWithSystem,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          _handleBlockedSystemBack(
            context,
            uri,
            requestTimetableAutoScroll:
                _requestTimetableAutoScrollAfterNavigation,
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 840;
            if (isWide) {
              final railCanExpand = constraints.maxWidth >= 1100;
              final railExtended = railCanExpand && !_railCollapsed;
              return Scaffold(
                body: SafeArea(
                  child: Row(
                    children: [
                      NavigationRail(
                        extended: railExtended,
                        minExtendedWidth: 184,
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (index) {
                          _selectDestination(context, uri, index);
                        },
                        leading: _RailLeading(
                          extended: railExtended,
                          canToggle: railCanExpand,
                          onToggle: railCanExpand
                              ? () {
                                  setState(() {
                                    _railCollapsed = !_railCollapsed;
                                  });
                                }
                              : null,
                        ),
                        destinations: [
                          for (
                            var index = 0;
                            index < appDestinations.length;
                            index++
                          )
                            NavigationRailDestination(
                              icon: Icon(appDestinations[index].icon),
                              selectedIcon: Icon(
                                appDestinations[index].selectedIcon,
                              ),
                              label: Text(_destinationLabel(context, index)),
                            ),
                        ],
                      ),
                      VerticalDivider(
                        width: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ShellHeader(
                              title: title,
                              showBack: !isCoreRoute,
                              currentUri: uri,
                              showWeekLabel: location == '/timetable',
                              showAddCourse: actionVisibility.showAddCourse,
                              showImportExport:
                                  actionVisibility.showImportExport,
                              showSettings: actionVisibility.showSettings,
                            ),
                            Expanded(child: widget.child),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final showDirectTools =
                actionVisibility.showImportExport &&
                constraints.maxWidth >= (location == '/timetable' ? 360 : 320);
            return Scaffold(
              appBar: AppBar(
                leadingWidth: isCoreRoute ? null : _topBarActionExtent,
                titleSpacing: isCoreRoute ? null : 0,
                leading: isCoreRoute
                    ? null
                    : IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).backButtonTooltip,
                        onPressed: () => _returnToSource(context, uri),
                        icon: const BackButtonIcon(),
                      ),
                title: _ShellTitle(
                  title: title,
                  showWeekLabel: location == '/timetable',
                ),
                actions: [
                  _MobileTopBarActions(
                    showAddCourse: actionVisibility.showAddCourse,
                    showImportExport: actionVisibility.showImportExport,
                    showDirectTools: showDirectTools,
                    showSettings: actionVisibility.showSettings,
                  ),
                ],
              ),
              body: widget.child,
              bottomNavigationBar: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  _selectDestination(context, uri, index);
                },
                destinations: [
                  for (var index = 0; index < appDestinations.length; index++)
                    NavigationDestination(
                      icon: Icon(appDestinations[index].icon),
                      selectedIcon: Icon(appDestinations[index].selectedIcon),
                      label: _destinationLabel(context, index),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  int _selectedIndexForUri(Uri uri) {
    final from = uri.queryParameters['from'];
    if (!_isCoreLocation(uri.path) && from != null && from.isNotEmpty) {
      return _selectedIndexForLocation(Uri.tryParse(from)?.path ?? from);
    }
    return _selectedIndexForLocation(uri.path);
  }

  int _selectedIndexForLocation(String location) {
    final index = appDestinations.indexWhere((destination) {
      return location == destination.path ||
          location.startsWith('${destination.path}/');
    });
    return index < 0 ? 0 : index;
  }

  void _selectDestination(BuildContext context, Uri currentUri, int index) {
    final target = appDestinations[index].path;
    if (target == '/timetable') {
      _requestTimetableAutoScrollAfterNavigation();
    }
    if (currentUri.path == target) {
      return;
    }
    if (_isCoreLocation(currentUri.path)) {
      _navigateBetweenCoreDestinations(context, target);
      return;
    }
    if (!_isCoreLocation(currentUri.path) && context.canPop()) {
      final from = currentUri.queryParameters['from'];
      final fromPath = from == null ? null : Uri.tryParse(from)?.path ?? from;
      if (fromPath == target) {
        context.pop();
        return;
      }
    }
    if (target == '/timetable') {
      context.pushReplacement(target);
      return;
    }
    final currentIndex = _selectedIndexForLocation(currentUri.path);
    if (index < currentIndex) {
      context.pushReplacement(target);
      return;
    }
    context.push(target);
  }

  void _requestTimetableAutoScrollAfterNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(timetableAutoScrollRequestProvider.notifier).request();
    });
  }

  void _navigateBetweenCoreDestinations(BuildContext context, String target) {
    if (target == '/timetable') {
      context.go(target);
      return;
    }
    context.go(target);
  }
}

class _ShellActionVisibility {
  const _ShellActionVisibility({
    required this.showAddCourse,
    required this.showImportExport,
    required this.showSettings,
  });

  factory _ShellActionVisibility.forLocation(String location) {
    return _ShellActionVisibility(
      showAddCourse: location != '/plans' && location != '/settings',
      showImportExport: location != '/settings',
      showSettings: location != '/settings',
    );
  }

  final bool showAddCourse;
  final bool showImportExport;
  final bool showSettings;
}

class _RailLeading extends StatelessWidget {
  const _RailLeading({
    required this.extended,
    required this.canToggle,
    required this.onToggle,
  });

  final bool extended;
  final bool canToggle;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(Icons.school, color: colorScheme.onTertiaryContainer),
            ),
          ),
          if (canToggle) ...[
            const SizedBox(height: 12),
            IconButton(
              tooltip: extended
                  ? context.l10n.collapseSidebar
                  : context.l10n.expandSidebar,
              onPressed: onToggle,
              icon: Icon(
                extended
                    ? Icons.keyboard_double_arrow_left
                    : Icons.keyboard_double_arrow_right,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({
    required this.title,
    required this.showBack,
    required this.currentUri,
    required this.showWeekLabel,
    required this.showAddCourse,
    required this.showImportExport,
    required this.showSettings,
  });

  final String title;
  final bool showBack;
  final Uri currentUri;
  final bool showWeekLabel;
  final bool showAddCourse;
  final bool showImportExport;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            if (showBack) ...[
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => _returnToSource(context, currentUri),
                icon: const BackButtonIcon(),
              ),
            ],
            Expanded(
              child: _ShellTitle(
                title: title,
                showWeekLabel: showWeekLabel,
                titleStyle: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            _WideTopBarActions(
              showAddCourse: showAddCourse,
              showImportExport: showImportExport,
              showSettings: showSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _WideTopBarActions extends StatelessWidget {
  const _WideTopBarActions({
    required this.showAddCourse,
    required this.showImportExport,
    required this.showSettings,
  });

  final bool showAddCourse;
  final bool showImportExport;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TopBarOptionalAction(
          visible: showAddCourse,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, _topBarActionExtent),
              ),
              onPressed: () => _openEditor(context),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.addCourse),
            ),
          ),
        ),
        if (showImportExport) ...[
          IconButton(
            tooltip: context.l10n.navImport,
            onPressed: () => _openTool(context, '/import'),
            icon: const Icon(Icons.file_download_outlined),
          ),
          IconButton(
            tooltip: context.l10n.navExport,
            onPressed: () => _openTool(context, '/export'),
            icon: const Icon(Icons.file_upload_outlined),
          ),
        ],
        if (showSettings) const _SettingsIconButton(),
      ],
    );
  }
}

class _MobileTopBarActions extends StatelessWidget {
  const _MobileTopBarActions({
    required this.showAddCourse,
    required this.showImportExport,
    required this.showDirectTools,
    required this.showSettings,
  });

  final bool showAddCourse;
  final bool showImportExport;
  final bool showDirectTools;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TopBarOptionalAction(
          visible: showAddCourse,
          child: SizedBox.square(
            dimension: _topBarActionExtent,
            child: IconButton(
              tooltip: context.l10n.addCourse,
              onPressed: () => _openEditor(context),
              icon: const Icon(Icons.add),
            ),
          ),
        ),
        if (showImportExport && showDirectTools)
          IconButton(
            tooltip: context.l10n.navImport,
            onPressed: () => _openTool(context, '/import'),
            icon: const Icon(Icons.file_download_outlined),
          ),
        if (showImportExport && showDirectTools)
          IconButton(
            tooltip: context.l10n.navExport,
            onPressed: () => _openTool(context, '/export'),
            icon: const Icon(Icons.file_upload_outlined),
          ),
        if (showImportExport && !showDirectTools)
          _ToolMenu(
            items: [
              _ToolMenuItem(
                icon: Icons.file_download_outlined,
                label: context.l10n.navImport,
                onSelected: () => _openTool(context, '/import'),
              ),
              _ToolMenuItem(
                icon: Icons.file_upload_outlined,
                label: context.l10n.navExport,
                onSelected: () => _openTool(context, '/export'),
              ),
            ],
          ),
        if (showSettings) const _SettingsIconButton(),
      ],
    );
  }
}

class _TopBarOptionalAction extends StatelessWidget {
  const _TopBarOptionalAction({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = disableAnimations ? Duration.zero : appMicroMotionDuration;

    return AnimatedSize(
      duration: duration,
      curve: appMicroMotionCurve,
      alignment: Alignment.centerRight,
      child: AnimatedSwitcher(
        duration: duration,
        reverseDuration: duration,
        switchInCurve: appMicroMotionCurve,
        switchOutCurve: appMicroMotionReverseCurve,
        layoutBuilder: _topBarActionLayout,
        transitionBuilder: _topBarActionTransition,
        child: visible
            ? KeyedSubtree(key: const ValueKey('action-on'), child: child)
            : const SizedBox.shrink(key: ValueKey('action-off')),
      ),
    );
  }
}

Widget _topBarActionLayout(
  Widget? currentChild,
  List<Widget> previousChildren,
) {
  return Stack(
    alignment: AlignmentDirectional.centerEnd,
    children: <Widget>[...previousChildren, ?currentChild],
  );
}

Widget _topBarActionTransition(Widget child, Animation<double> animation) {
  final offsetAnimation = animation.drive(
    Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: appMicroMotionCurve)),
  );
  return FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: offsetAnimation,
      child: AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          return ClipRect(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              widthFactor: animation.value,
              child: child,
            ),
          );
        },
      ),
    ),
  );
}

class _SettingsIconButton extends StatelessWidget {
  const _SettingsIconButton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: context.l10n.navSettings,
      onPressed: () => _openSettings(context),
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        hoverColor: colorScheme.secondary.withValues(alpha: 0.10),
        focusColor: colorScheme.secondary.withValues(alpha: 0.12),
        highlightColor: colorScheme.secondary.withValues(alpha: 0.16),
      ),
      icon: const Icon(Icons.settings_outlined),
    );
  }
}

class _ShellTitle extends ConsumerWidget {
  const _ShellTitle({
    required this.title,
    required this.showWeekLabel,
    this.titleStyle,
  });

  final String title;
  final bool showWeekLabel;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = ref.watch(selectedWeekProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: appMicroMotionDuration,
          switchInCurve: appMicroMotionCurve,
          switchOutCurve: appMicroMotionReverseCurve,
          layoutBuilder: _topBarSwitcherLayout,
          transitionBuilder: _topBarTextTransition,
          child: Text(title, key: ValueKey(title), style: titleStyle),
        ),
        AnimatedSize(
          duration: appMicroMotionDuration,
          curve: appMicroMotionCurve,
          alignment: Alignment.topLeft,
          child: showWeekLabel
              ? _AnimatedWeekLabel(
                  week: week,
                  style: Theme.of(context).textTheme.labelSmall,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _AnimatedWeekLabel extends StatelessWidget {
  const _AnimatedWeekLabel({required this.week, required this.style});

  final int week;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: appMicroMotionDuration,
      switchInCurve: appMicroMotionCurve,
      switchOutCurve: appMicroMotionReverseCurve,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        context.l10n.weekNumber(week),
        key: ValueKey(week),
        style: style,
      ),
    );
  }
}

Widget _topBarSwitcherLayout(
  Widget? currentChild,
  List<Widget> previousChildren,
) {
  return Stack(
    alignment: AlignmentDirectional.centerStart,
    children: <Widget>[...previousChildren, ?currentChild],
  );
}

Widget _topBarTextTransition(Widget child, Animation<double> animation) {
  final offsetAnimation = animation.drive(
    Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).chain(CurveTween(curve: appMicroMotionCurve)),
  );
  return FadeTransition(
    opacity: animation,
    child: SlideTransition(position: offsetAnimation, child: child),
  );
}

class _ToolMenu extends StatelessWidget {
  const _ToolMenu({required this.items});

  final List<_ToolMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ToolMenuItem>(
      tooltip: MaterialLocalizations.of(context).showMenuTooltip,
      icon: const Icon(Icons.more_vert),
      iconSize: 24,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      shape: appMenuPanelShape,
      clipBehavior: Clip.antiAlias,
      popUpAnimationStyle: appMenuAnimationStyle,
      onSelected: (item) => item.onSelected(),
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem(
            value: item,
            child: _MenuItem(icon: item.icon, label: item.label),
          ),
      ],
    );
  }
}

class _ToolMenuItem {
  const _ToolMenuItem({
    required this.icon,
    required this.label,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final VoidCallback onSelected;
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(children: [Icon(icon), const SizedBox(width: 12), Text(label)]);
  }
}

String _destinationLabel(BuildContext context, int index) {
  final l10n = context.l10n;
  return switch (index) {
    0 => l10n.navTimetable,
    1 => l10n.navPlans,
    _ => l10n.navSettings,
  };
}

String _routeTitle(BuildContext context, Uri uri) {
  final l10n = context.l10n;
  final location = uri.path;
  if (location == '/plans') {
    return l10n.navPlans;
  }
  if (location.startsWith('/import')) {
    return l10n.navImport;
  }
  if (location == '/editor') {
    return uri.queryParameters['slot'] == null
        ? l10n.newCourse
        : l10n.editCourse;
  }
  if (location == '/export') {
    return l10n.navExport;
  }
  if (location == '/settings') {
    return l10n.navSettings;
  }
  return l10n.navTimetable;
}

bool _isCoreLocation(String location) {
  return appDestinations.any((destination) => location == destination.path);
}

void _openEditor(BuildContext context, {String? slotId}) {
  final queryParameters = <String, String>{
    'from': GoRouterState.of(context).uri.toString(),
  };
  if (slotId != null) {
    queryParameters['slot'] = slotId;
  }
  context.push(
    Uri(path: '/editor', queryParameters: queryParameters).toString(),
  );
}

void _openTool(BuildContext context, String path) {
  if (GoRouterState.of(context).uri.path == path) {
    return;
  }
  context.push(
    Uri(
      path: path,
      queryParameters: {'from': GoRouterState.of(context).uri.toString()},
    ).toString(),
  );
}

void _openSettings(BuildContext context) {
  if (GoRouterState.of(context).uri.path == '/settings') {
    return;
  }
  context.push(
    Uri(
      path: '/settings',
      queryParameters: {'from': GoRouterState.of(context).uri.toString()},
    ).toString(),
  );
}

void _returnToSource(BuildContext context, Uri currentUri) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  final from = currentUri.queryParameters['from'];
  if (from != null && from.isNotEmpty) {
    context.pushReplacement(from);
    return;
  }
  context.pushReplacement(_fallbackPathFor(currentUri.path));
}

bool _canPopWithSystem(BuildContext context, Uri currentUri) {
  if (context.canPop()) {
    return true;
  }
  return currentUri.path == '/timetable';
}

void _handleBlockedSystemBack(
  BuildContext context,
  Uri currentUri, {
  required VoidCallback requestTimetableAutoScroll,
}) {
  if (_isCoreLocation(currentUri.path) && currentUri.path != '/timetable') {
    context.go('/timetable');
    requestTimetableAutoScroll();
    return;
  }
  _returnToSource(context, currentUri);
}

String _fallbackPathFor(String location) {
  return '/timetable';
}
