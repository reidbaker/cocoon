// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:cocoon_server/logging.dart';
import 'package:googleapis/pubsub/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';

import '../foundation/providers.dart';
import '../foundation/typedefs.dart';

/// Service class for interacting with PubSub.
class PubSub {
  const PubSub({this.httpClientProvider = Providers.freshHttpClient});

  final HttpClientProvider httpClientProvider;

  Future<List<String>> publish(String topic, dynamic json) async {
    final Client httpClient = await clientViaApplicationDefaultCredentials(
      scopes: <String>[PubsubApi.pubsubScope],
    );
    final pubsubApi = PubsubApi(httpClient);
    final messageData = jsonEncode(json);
    final List<int> messageBytes = utf8.encode(messageData);
    final messageBase64 = base64Encode(messageBytes);
    final request = PublishRequest(
      messages: <PubsubMessage>[PubsubMessage(data: messageBase64)],
    );
    final fullTopicName = 'projects/flutter-dashboard/topics/$topic';
    final response = await pubsubApi.projects.topics.publish(
      request,
      fullTopicName,
    );
    log.info('pubsub response messageId=${response.messageIds}');
    return response.messageIds!;
  }
}
