import 'package:http/http.dart' as http;

import '../../models/fair_event.dart';
import '../event_source.dart';

/// Strapi 5 (headless CMS), REST API.
class StrapiEventSource implements EventSource {
  StrapiEventSource(this.client, {required this.baseUrl, this.token = ''});

  final http.Client client;
  final String baseUrl;
  final String token;

  @override
  String get name => 'Strapi';

  @override
  Future<List<FairEvent>> fetchEvents() async {
    final uri = Uri.parse('$baseUrl/api/fair-events').replace(
      queryParameters: {'sort': 'startsAt:asc', 'pagination[pageSize]': '100'},
    );

    final headers = <String, String>{};
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final json =
        await getJson(client, uri, cms: name, headers: headers)
            as Map<String, dynamic>;
    final results = json['data'] as List<dynamic>;

    return results.map((item) {
      final event = item as Map<String, dynamic>;

      return FairEvent(
        id: event['documentId'] as String,
        orgId: event['orgId'] as String,
        title: event['title'] as String,
        startsAt: DateTime.parse(event['startsAt'] as String),
        venue: event['venue'] as String,
        description: event['description'] as String? ?? '',
        cancelled: event['cancelled'] as bool? ?? false,
      );
    }).toList();
  }
}
