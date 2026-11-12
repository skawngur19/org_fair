import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:org_fair/data/cms/contentful_source.dart';

void main() {
  test('builds a delivery request and parses entries', () async {
    late http.Request sent;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(
        jsonEncode({
          'items': [
            {
              'sys': {'id': 'event-1'},
              'fields': {
                'title': 'Hour of Code',
                'orgId': 'csc',
                'startsAt': '2026-11-08T13:00+08:00',
                'venue': 'CICT Lab 2',
              },
            },
          ],
        }),
        200,
      );
    });

    final events = await ContentfulEventSource(
      client,
      spaceId: 'abc123',
      token: 'delivery-token',
    ).fetchEvents();

    expect(sent.method, 'GET');
    expect(sent.url.host, 'cdn.contentful.com');
    expect(sent.url.path, '/spaces/abc123/environments/master/entries');
    expect(sent.url.queryParameters['content_type'], 'fairEvent');
    expect(sent.url.queryParameters['order'], 'fields.startsAt');
    expect(sent.url.queryParameters['limit'], '100');
    expect(sent.headers['Authorization'], 'Bearer delivery-token');
    expect(events, hasLength(1));
    expect(events.single.id, 'event-1');
    expect(events.single.title, 'Hour of Code');
    expect(events.single.startsAt.toUtc(), DateTime.utc(2026, 11, 8, 5));
    expect(events.single.description, '');
    expect(events.single.cancelled, isFalse);
  });
}
