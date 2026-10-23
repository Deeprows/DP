import 'dart:convert';

import 'package:http/http.dart' as http;

import 'prediction_service.dart';

class LiveFixture {
  const LiveFixture({
    required this.id,
    required this.home,
    required this.away,
    required this.competition,
    required this.kickoff,
    required this.status,
    this.statusLong = '',
    this.elapsed,
    this.homeScore,
    this.awayScore,
    this.homeLogo = '',
    this.awayLogo = '',
    this.leagueLogo = '',
    this.country = '',
    this.round = '',
    this.venue = '',
    this.leagueId,
    this.homeId,
    this.awayId,
  });

  final int id;
  final String home, away, competition, status;
  final DateTime kickoff;
  final String statusLong, homeLogo, awayLogo, leagueLogo, country, round, venue;
  final int? elapsed, homeScore, awayScore, leagueId, homeId, awayId;

  bool get isLive => const {
        '1H', 'HT', '2H', 'ET', 'BT', 'P', 'INT', 'LIVE',
      }.contains(status.toUpperCase());

  bool get isFinished => const {
        'FT', 'AET', 'PEN', 'AWD', 'WO',
      }.contains(status.toUpperCase());

  bool get isUpcoming => const {
        'NS', 'TBD', 'TIMED', 'SCHEDULED',
      }.contains(status.toUpperCase());

  factory LiveFixture.fromJson(Map<String, dynamic> json) {
    int? optionalInt(Object? value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    return LiveFixture(
      id: optionalInt(json['id']) ?? 0,
      home: (json['home'] ?? '').toString(),
      away: (json['away'] ?? '').toString(),
      competition: (json['competition'] ?? '').toString(),
      kickoff: DateTime.parse(json['kickoff'].toString()).toLocal(),
      status: (json['status'] ?? '').toString(),
      statusLong: (json['statusLong'] ?? '').toString(),
      elapsed: optionalInt(json['elapsed']),
      homeScore: optionalInt(json['homeScore']),
      awayScore: optionalInt(json['awayScore']),
      homeLogo: (json['homeLogo'] ?? '').toString(),
      awayLogo: (json['awayLogo'] ?? '').toString(),
      leagueLogo: (json['leagueLogo'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      round: (json['round'] ?? '').toString(),
      venue: (json['venue'] ?? '').toString(),
      leagueId: optionalInt(json['leagueId']),
      homeId: optionalInt(json['homeId']),
      awayId: optionalInt(json['awayId']),
    );
  }
}

class FixturesService {
  static String get _baseUrl {
    final endpoint = PredictionService.endpoint.trim();
    if (endpoint.isEmpty) {
      throw StateError('Football API URL is not configured.');
    }
    return endpoint.replaceFirst(RegExp(r'/+$'), '');
  }

  static Future<Map<String, dynamic>> _getJson(String path,
      [Map<String, String>? parameters]) async {
    final uri = Uri.parse('$_baseUrl$path')
        .replace(queryParameters: parameters);
    final response = await http.get(uri).timeout(const Duration(seconds: 35));
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const FormatException('Football server returned invalid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid football server response.');
    }
    if (response.statusCode != 200 || decoded['status'] == 'error') {
      final message = decoded['message'] ?? decoded['error'];
      throw StateError(message?.toString() ??
          'Football service error (${response.statusCode}).');
    }
    return decoded;
  }

  static List<LiveFixture> _parseFixtures(
      Map<String, dynamic> body, String field) {
    final items = body[field];
    if (items is! List) {
      throw FormatException('Missing $field in football response.');
    }
    final fixtures = items.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid match in football response.');
      }
      return LiveFixture.fromJson(item);
    }).toList();
    fixtures.sort((a, b) => a.kickoff.compareTo(b.kickoff));
    return fixtures;
  }

  /// All fixtures and results for a calendar date (YYYY-MM-DD).
  static Future<List<LiveFixture>> forDate(DateTime date) async {
    final day = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final body = await _getJson('/matches', {'date': day});
    return _parseFixtures(body, 'matches');
  }

  /// All matches currently reported as live by API-Football.
  static Future<List<LiveFixture>> live() async {
    final body = await _getJson('/matches/live');
    return _parseFixtures(body, 'matches');
  }

  /// A single match, including its current score and match status.
  static Future<LiveFixture> byId(int id) async {
    if (id <= 0) throw ArgumentError.value(id, 'id', 'Invalid fixture ID');
    final body = await _getJson('/matches/$id');
    final match = body['match'] ?? body['fixture'];
    if (match is Map<String, dynamic>) {
      return LiveFixture.fromJson(match);
    }
    final matches = body['matches'];
    if (matches is List && matches.isNotEmpty &&
        matches.first is Map<String, dynamic>) {
      return LiveFixture.fromJson(matches.first as Map<String, dynamic>);
    }
    throw const FormatException('Match details were not found in the response.');
  }

  /// Backward-compatible method for the existing Fixtures screen.
  static Future<List<LiveFixture>> upcoming({int days = 7}) async {
    final safeDays = days.clamp(1, 21);
    final body = await _getJson('/fixtures', {'days': '$safeDays'});
    return _parseFixtures(body, 'fixtures');
  }
}
