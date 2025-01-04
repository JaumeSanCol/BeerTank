import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final String broker;
  final int port;
  final String username;
  final String password;
  final List<String> topics;

  late MqttServerClient client;
  final StreamController<Map<String, String>> _messageController = StreamController.broadcast();

  Stream<Map<String, String>> get messageStream => _messageController.stream;

  MqttService({
    required this.broker,
    required this.port,
    required this.username,
    required this.password,
    required this.topics,
  });

  Future<void> initializeMqtt() async {
    client = MqttServerClient(broker, '');
    client.port = port;
    client.logging(on: true);
    client.keepAlivePeriod = 20;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect(username, password);
    } catch (e) {
      print('Error connecting to MQTT broker: $e');
      client.disconnect();
      rethrow;
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Connected to MQTT broker');
      for (var topic in topics) {
        client.subscribe(topic, MqttQos.atLeastOnce);
      }

      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final MqttPublishMessage message = messages[0].payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);

        final parts = payload.split('%');
        if (parts.length == 2) {
          final tankId = parts[0];
          final value = parts[1];
          final topic = messages[0].topic;

          // Add parsed data to the stream
          _messageController.add({
            'tankId': tankId,
            'value': value,
            'topic': topic,
          });
        }
      });
    } else {
      print('Failed to connect: ${client.connectionStatus}');
      client.disconnect();
    }
  }

  void dispose() {
    _messageController.close();
    client.disconnect();
  }
}