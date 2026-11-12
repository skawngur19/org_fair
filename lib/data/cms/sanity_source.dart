import 'package:http/http.dart' as http;

import '../../models/fair_event.dart';
import '../event_source.dart';

/// Sanity HTTP Query API source for the fairEvent document type.
class SanityEventSource implements EventSource {
  SanityEventSource(
    this.client, {
    required this.projectId,
    this.dataset = 'production',
    this.token = '',
  });

  final http.Client client;
  final String projectId;
  final String dataset;
  final String token;

  static const query =
      '*[_type == "fairEvent"] | order(startsAt asc) '
      '{_id, title, orgId, startsAt, venue, description, cancelled}';

  @override
  String get name => 'Sanity';

  @override
  Future<List<FairEvent>> fetchEvents() async {
    final uri = Uri.https(
      '$projectId.apicdn.sanity.io',
      '/v2025-02-19/data/query/$dataset',
      {'query': query},
    );
    final headers = <String, String>{};
    if (token.isNotEmpty) {
      headers['Authorization'] = ['Bearer', token].join(' ');
    }

    final json = await getJson(client, uri, cms: name, headers: headers);
    final results = (json as Map<String, dynamic>)['result'] as List<dynamic>;
    return results.map((item) {
      final document = item as Map<String, dynamic>;
      return FairEvent(
        id: document['_id'] as String,
        orgId: document['orgId'] as String,
        title: document['title'] as String,
        startsAt: DateTime.parse(document['startsAt'] as String),
        venue: document['venue'] as String,
        description: document['description'] as String? ?? '',
        cancelled: document['cancelled'] as bool? ?? false,
      );
    }).toList();
  }
}
