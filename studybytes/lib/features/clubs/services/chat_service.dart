import 'dart:async';

class Message {
  final String id;
  final String text;
  final String userId;
  final String userName;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.text,
    required this.userId,
    required this.userName,
    required this.timestamp,
  });
}

class ChatService {
  final Map<String, List<Message>> _clubMessages = {};
  final Map<String, StreamController<List<Message>>> _controllers = {};

  Stream<List<Message>> getMessages(String clubId) {
    _clubMessages.putIfAbsent(clubId, () => []);
    _controllers.putIfAbsent(
        clubId,
        () => StreamController<List<Message>>.broadcast(
              onListen: () {
                _controllers[clubId]?.add(_clubMessages[clubId]!);
              },
            ));
    return _controllers[clubId]!.stream;
  }

  Future<void> sendMessage(String clubId, Message message) async {
    _clubMessages.putIfAbsent(clubId, () => []);
    _clubMessages[clubId]!.add(message);
    _controllers[clubId]?.add(List.from(_clubMessages[clubId]!));
  }

  void loadMockMessages(String clubId) {
    _clubMessages[clubId] = [
      Message(
        id: '1',
        text: '¡Bienvenidos al club! 🎉 ¿Alguna duda sobre el tema de hoy?',
        userId: 'user_001',
        userName: 'Ghosty',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Message(
        id: '2',
        text: '¿Alguien tiene los apuntes de la clase 3? No pude asistir 😅',
        userId: 'user_002',
        userName: 'Usuario Test',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      ),
      Message(
        id: '3',
        text: 'Sí, los subo a la biblioteca en un momento.',
        userId: 'user_001',
        userName: 'Ghosty',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Message(
        id: '4',
        text: '¡Muchas gracias! Eres un crack 🙌',
        userId: 'user_002',
        userName: 'Usuario Test',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ];
    _controllers[clubId]?.add(List.from(_clubMessages[clubId]!));
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
  }
}
