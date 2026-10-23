import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/fixtures_service.dart';
import '../theme.dart';

class FixturesScreen extends StatefulWidget {
  const FixturesScreen({super.key});

  @override
  State<FixturesScreen> createState() => _FixturesScreenState();
}

class _FixturesScreenState extends State<FixturesScreen> {
  late Future<List<LiveFixture>> request;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    request = FixturesService.upcoming();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(refresh);

        try {
          await request;
        } catch (_) {
          // Errors are displayed by FutureBuilder.
        }
      },
      child: FutureBuilder<List<LiveFixture>>(
        future: request,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 100),
                const Icon(
                  Icons.wifi_off_outlined,
                  size: 48,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Unable to load real fixtures',
                    style: AppText.heading,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: AppText.muted,
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => setState(refresh),
                    child: const Text('Try again'),
                  ),
                ),
              ],
            );
          }

          final fixtures = snapshot.data ?? [];

          if (fixtures.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 100),
                Icon(
                  Icons.event_busy_outlined,
                  size: 48,
                  color: AppColors.textMuted,
                ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    'No upcoming fixtures available',
                    style: AppText.heading,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'The provider has no fixtures in the supported '
                    'competitions over the next 7 days. '
                    'Pull down to refresh.',
                    textAlign: TextAlign.center,
                    style: AppText.muted,
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fixtures.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upcoming fixtures',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Verified schedule • Times shown in your local timezone',
                        style: AppText.muted,
                      ),
                    ],
                  ),
                );
              }

              final match = fixtures[index - 1];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.competition.toUpperCase(),
                          style: AppText.label,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${match.home}  vs  ${match.away}',
                          style: AppText.heading,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${DateFormat('EEE, d MMM • HH:mm').format(match.kickoff)}'
                          '  ·  ${match.status.replaceAll('_', ' ')}',
                          style: AppText.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
