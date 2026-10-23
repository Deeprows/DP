import 'dart:convert';
import 'package:http/http.dart' as http;
import 'prediction_service.dart';

class LiveFixture {
  const LiveFixture({required this.id, required this.home, required this.away,
    required this.competition, required this.kickoff, required this.status});
  final int id;
  final String home, away, competition, status;
  final DateTime kickoff;

  factory LiveFixture.fromJson(Map<String, dynamic> json) => LiveFixture(
    id: (json['id'] as num).toInt(),
    home: json['home'] as String,
    away: json['away'] as String,
    competition: json['competition'] as String,
    kickoff: DateTime.parse(json['kickoff'] as String).toLocal(),
    status: json['status'] as String,
  );
}

class FixturesService {
  static Future<List<LiveFixture>> upcoming() async {
    final endpoint = PredictionService.endpoint.trim();
    if (endpoint.isEmpty) throw StateError('Prediction API URL is not configured.');
    final uri = Uri.parse('${endpoint.replaceAll(RegExp(r"/+$"), "")}/fixtures?days=7');
    final response = await http.get(uri).timeout(const Duration(seconds: 35));
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) throw const FormatException('Invalid fixtures response');
    if (response.statusCode != 200) throw StateError(body['error']?.toString() ?? 'Unable to load fixtures');
    final items = body['fixtures'];
    if (items is! List) throw const FormatException('Missing fixtures');
    return items.map((e) => LiveFixture.fromJson(e as Map<String, dynamic>)).toList();
  }
}
