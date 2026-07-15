import 'package:crid/app/adaptive_shell.dart';
import 'package:crid/app/launch_activation.dart';
import 'package:crid/app/motion.dart';
import 'package:crid/features/editor/presentation/course_editor_page.dart';
import 'package:crid/features/import/presentation/conflict_diff_page.dart';
import 'package:crid/features/import/presentation/import_center_page.dart';
import 'package:crid/features/settings/presentation/export_page.dart';
import 'package:crid/features/settings/presentation/settings_page.dart';
import 'package:crid/features/settings/presentation/third_party_licenses_page.dart';
import 'package:crid/features/timetable/presentation/plan_management_page.dart';
import 'package:crid/features/timetable/presentation/timetable_home_page.dart';
import 'package:crid/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final importFilePath = launchImportFilePath(
    ref.watch(launchArgumentsProvider),
  );
  return GoRouter(
    initialLocation: importFilePath == null ? '/timetable' : '/import',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AdaptiveShell(child: child),
        routes: [
          GoRoute(
            path: '/timetable',
            pageBuilder: (context, state) =>
                _coreDestinationPage(state, const TimetableHomePage()),
          ),
          GoRoute(
            path: '/plans',
            pageBuilder: (context, state) =>
                _coreDestinationPage(state, const PlanManagementPage()),
          ),
        ],
      ),
      GoRoute(
        path: '/import',
        pageBuilder: (context, state) => _overlayPage(
          state,
          title: context.l10n.navImport,
          child: const ImportCenterPage(),
        ),
        routes: [
          GoRoute(
            path: 'conflicts',
            pageBuilder: (context, state) => _overlayPage(
              state,
              title: context.l10n.conflictHandling,
              child: const ConflictDiffPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/editor',
        pageBuilder: (context, state) => _overlayPage(
          state,
          title: state.uri.queryParameters['slot'] == null
              ? context.l10n.newCourse
              : context.l10n.editCourse,
          child: CourseEditorPage(
            slotId: state.uri.queryParameters['slot'],
            returnPath: state.uri.queryParameters['from'],
          ),
        ),
      ),
      GoRoute(
        path: '/export',
        pageBuilder: (context, state) => _overlayPage(
          state,
          title: context.l10n.navExport,
          child: const ExportPage(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _overlayPage(
          state,
          title: context.l10n.navSettings,
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: '/licenses',
        pageBuilder: (context, state) => _overlayPage(
          state,
          title: context.l10n.thirdPartyLicenses,
          child: const OpenSourceLicensesPage(),
        ),
        routes: [
          GoRoute(
            path: ':packageName',
            pageBuilder: (context, state) {
              final packageName = state.pathParameters['packageName'] ?? '';
              return _overlayPage(
                state,
                title: packageName == 'Crid'
                    ? context.l10n.appLicenseDisplayName
                    : packageName,
                child: OpenSourceLicenseDetailsPage(packageName: packageName),
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const _RouteNotFoundPage(),
  );
});

Page<void> _coreDestinationPage(GoRouterState state, Widget child) {
  final direction = _coreDestinationDirection(state.uri.path);
  return CustomTransitionPage<void>(
    key: state.pageKey,
    restorationId: state.pageKey.value,
    transitionDuration: appCoreDestinationMotionDuration,
    reverseTransitionDuration: appCoreDestinationMotionDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final disableAnimations =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (disableAnimations) {
        return child;
      }

      final incomingPosition = animation.drive(
        Tween<Offset>(
          begin: Offset(direction * 0.14, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: appCoreDestinationMotionCurve)),
      );
      final outgoingPosition = secondaryAnimation.drive(
        Tween<Offset>(
          begin: Offset.zero,
          end: Offset(direction * 0.14, 0),
        ).chain(CurveTween(curve: appCoreDestinationMotionCurve)),
      );

      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ClipRect(
          child: SlideTransition(
            position: outgoingPosition,
            child: SlideTransition(position: incomingPosition, child: child),
          ),
        ),
      );
    },
    child: child,
  );
}

double _coreDestinationDirection(String location) {
  return location == '/timetable' ? -1 : 1;
}

Page<void> _overlayPage(
  GoRouterState state, {
  required String title,
  required Widget child,
}) {
  return MaterialPage<void>(
    key: state.pageKey,
    restorationId: state.pageKey.value,
    child: _OverlayPage(title: title, uri: state.uri, child: child),
  );
}

class _OverlayPage extends StatelessWidget {
  const _OverlayPage({
    required this.title,
    required this.uri,
    required this.child,
  });

  final String title;
  final Uri uri;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 48,
        titleSpacing: 0,
        leading: BackButton(onPressed: () => _returnFromOverlay(context, uri)),
        title: Text(title),
      ),
      body: SafeArea(
        top: false,
        child: _DesktopOverlayFrame(uri: uri, child: child),
      ),
    );
  }
}

class _DesktopOverlayFrame extends StatelessWidget {
  const _DesktopOverlayFrame({required this.uri, required this.child});

  final Uri uri;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 840) {
          return child;
        }
        final maxWidth = _desktopOverlayMaxWidth(uri.path);
        final contentWidth = constraints.maxWidth > maxWidth
            ? maxWidth
            : constraints.maxWidth;
        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              height: constraints.maxHeight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

double _desktopOverlayMaxWidth(String location) {
  if (location == '/export') {
    return 1120;
  }
  if (location.startsWith('/licenses')) {
    return 980;
  }
  if (location.startsWith('/import')) {
    return 1080;
  }
  return 1120;
}

void _returnFromOverlay(BuildContext context, Uri uri) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  final from = uri.queryParameters['from'];
  if (from != null && from.isNotEmpty) {
    context.pushReplacement(from);
    return;
  }
  context.pushReplacement('/timetable');
}

class _RouteNotFoundPage extends StatelessWidget {
  const _RouteNotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton.icon(
          onPressed: () => context.go('/timetable'),
          icon: const Icon(Icons.calendar_today),
          label: Text(context.l10n.backToTimetable),
        ),
      ),
    );
  }
}
