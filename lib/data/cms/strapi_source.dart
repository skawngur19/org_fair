import 'package:http/http.dart' as http;

import '../../models/fair_event.dart';
import '../event_source.dart';

/// Strapi 5 REST API source for the fair-event collection type.
class StrapiEventSource implements EventSource {
  StrapiEventSource(this.client, {required this.baseUrl, this.token = ''});

  final http.Client client;

  /// The server URL without a trailing slash.
  final String baseUrl;
  final String token;

  @override
  String get name => 'Strapi';

  @override
  Future<List<FairEvent>> fetchEvents() async {
    final uri = Uri.parse(baseUrl)
        .resolve('/api/fair-events')
        .replace(
          queryParameters: {
            'sort': 'startsAt:asc',
            'pagination[pageSize]': '100',
          },
        );
    final headers = <String, String>{};
    if (token.isNotEmpty) {
      headers['Authorization'] = ['Bearer', token].join(' ');
    }

    final json = await getJson(client, uri, cms: name, headers: headers);
    final records = (json as Map<String, dynamic>)['data'] as List<dynamic>;
    return records.map((item) {
      final record = item as Map<String, dynamic>;
      return FairEvent(
        id: record['documentId'] as String,
        orgId: record['orgId'] as String,
        title: record['title'] as String,
        startsAt: DateTime.parse(record['startsAt'] as String),
        venue: record['venue'] as String,
        description: record['description'] as String? ?? '',
        cancelled: record['cancelled'] as bool? ?? false,
      );
    }).toList();
  }
}
