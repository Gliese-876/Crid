import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/l10n.dart';

class OpenSourceLicensesPage extends StatelessWidget {
  const OpenSourceLicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_LicenseCatalog>(
      future: _licenseCatalog(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(snapshot.error.toString()),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final catalog = snapshot.data!;
        final packageLicenses = catalog.licenses
            .where((license) => license.packageName != _appLicensePackageName)
            .toList(growable: false);
        return CustomScrollView(
          key: const PageStorageKey<String>('open-source-licenses'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    title: Text(context.l10n.appLicenseDisplayName),
                    subtitle: Text(context.l10n.appLicenseSummary),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push(
                        '/licenses/${Uri.encodeComponent(_appLicensePackageName)}',
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final license = packageLicenses[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == packageLicenses.length - 1 ? 0 : 8,
                    ),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        title: Text(_licenseDisplayName(context, license)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push(
                            '/licenses/${Uri.encodeComponent(license.packageName)}',
                          );
                        },
                      ),
                    ),
                  );
                }, childCount: packageLicenses.length),
              ),
            ),
          ],
        );
      },
    );
  }
}

class OpenSourceLicenseDetailsPage extends StatelessWidget {
  const OpenSourceLicenseDetailsPage({super.key, required this.packageName});

  final String packageName;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_LicenseCatalog>(
      future: _licenseCatalog(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(snapshot.error.toString()),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final license = snapshot.data!.byPackage[packageName];
        if (license == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(packageName),
            ),
          );
        }

        return SelectionArea(
          child: ListView.builder(
            key: PageStorageKey<String>(
              'open-source-license-detail-$packageName',
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: license.paragraphs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
                child: Text(
                  license.paragraphs[index],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

String _licenseDisplayName(BuildContext context, _PackageLicense license) {
  return license.packageName == _appLicensePackageName
      ? context.l10n.appLicenseDisplayName
      : license.packageName;
}

void preloadOpenSourceLicenses() {
  if (!debugOpenSourceLicensePreloadEnabled) {
    return;
  }
  unawaited(_licenseCatalog().then<void>((_) {}, onError: (_) {}));
}

@visibleForTesting
var debugOpenSourceLicensePreloadEnabled = true;

@visibleForTesting
void debugResetOpenSourceLicenseCache() {
  _cachedLicenses = null;
}

Future<_LicenseCatalog>? _cachedLicenses;

Future<_LicenseCatalog> _licenseCatalog() {
  return _cachedLicenses ??= _loadLicenses();
}

Future<_LicenseCatalog> _loadLicenses() async {
  final grouped = <String, LinkedHashSet<String>>{};
  grouped[_appLicensePackageName] = LinkedHashSet<String>.of(
    _splitLicenseText(await rootBundle.loadString('LICENSE')),
  );
  var loadedEntries = 0;
  await for (final entry in LicenseRegistry.licenses) {
    final paragraphs = entry.paragraphs
        .map((paragraph) => paragraph.text.trim())
        .where((text) => text.isNotEmpty)
        .toList(growable: false);
    if (paragraphs.isEmpty) {
      continue;
    }
    for (final package in entry.packages) {
      grouped
          .putIfAbsent(package, LinkedHashSet<String>.new)
          .addAll(paragraphs);
    }
    loadedEntries += 1;
    if (loadedEntries % 12 == 0) {
      await Future<void>.delayed(Duration.zero);
    }
  }
  final licenses = [
    for (final entry in grouped.entries)
      _PackageLicense(
        packageName: entry.key,
        paragraphs: List.unmodifiable(entry.value),
      ),
  ]..sort((a, b) => a.packageName.compareTo(b.packageName));
  return _LicenseCatalog(List.unmodifiable(licenses));
}

List<String> _splitLicenseText(String text) {
  return text
      .split(RegExp(r'\n\s*\n'))
      .map((paragraph) => paragraph.trim())
      .where((paragraph) => paragraph.isNotEmpty)
      .toList(growable: false);
}

const _appLicensePackageName = 'Crid';

class _LicenseCatalog {
  _LicenseCatalog(this.licenses)
    : byPackage = Map.unmodifiable({
        for (final license in licenses) license.packageName: license,
      });

  final List<_PackageLicense> licenses;
  final Map<String, _PackageLicense> byPackage;
}

class _PackageLicense {
  const _PackageLicense({required this.packageName, required this.paragraphs});

  final String packageName;
  final List<String> paragraphs;
}
