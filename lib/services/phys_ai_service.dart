import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class PhysAiTurn {
  const PhysAiTurn({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, String> toJson() => {'role': role, 'content': content};
}

class PhysAiException implements Exception {
  const PhysAiException(this.message);
  final String message;
}

abstract interface class PhysAiResponder {
  Future<String> reply(List<PhysAiTurn> conversation);
}

/// For a private prototype only. A bundled key can be extracted from an APK.
class GroqPhysAiResponder implements PhysAiResponder {
  const GroqPhysAiResponder();

  static const _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const _localKeyAsset = 'assets/config/physai.local.json';
  static final _endpoint = Uri.parse(
    'https://api.groq.com/openai/v1/chat/completions',
  );

  @override
  Future<String> reply(List<PhysAiTurn> conversation) async {
    final apiKey = await _resolveApiKey();
    if (apiKey.isEmpty || apiKey == 'ӨЗ_GROQ_API_КІЛТІҢІЗ') {
      throw const PhysAiException(
        'Groq кілті қосылмаған. assets/config/physai.local.json файлына кілтті енгізіп, қолданбаны қайта іске қосыңыз.',
      );
    }
    if (conversation.isEmpty || conversation.last.role != 'user') {
      throw const PhysAiException('Алдымен физика сұрағын жазыңыз.');
    }

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client
          .postUrl(_endpoint)
          .timeout(const Duration(seconds: 15));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      request.write(
        jsonEncode({
          'model': 'openai/gpt-oss-120b',
          'reasoning_effort': 'low',
          'max_completion_tokens': 1200,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Сен PhysAI — мектеп оқушыларына арналған физика көмекшісісің. '
                  'Физика сұрақтарына қазақ тілінде түсінікті, дәл жауап бер. '
                  'Есепті берілгені, формуласы, орнына қоюы және жауабы бойынша '
                  'қадамдап түсіндір. Формулаларды қарапайым мәтінмен жаз, '
                  'LaTeX қолданба. Дерек жетпесе ойдан шығарма. '
                  'Физикаға қатысы жоқ сұрақта физика тақырыбына бағытта.',
            },
            ...conversation.take(12).map((turn) => turn.toJson()),
          ],
        }),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      final body = await utf8.decoder
          .bind(response)
          .join()
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const PhysAiException(
          'Groq кілті жарамсыз немесе модельге рұқсат жоқ.',
        );
      }
      if (response.statusCode == 429) {
        throw const PhysAiException(
          'Groq тегін сұрау шегі толды. Кейінірек қайталаңыз.',
        );
      }
      if (response.statusCode != 200) {
        throw const PhysAiException(
          'Groq қазір жауап бере алмады. Кейінірек қайталаңыз.',
        );
      }
      final data = jsonDecode(body) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      final first = choices?.firstOrNull as Map<String, dynamic>?;
      final message = first?['message'] as Map<String, dynamic>?;
      final answer = message?['content'];
      if (answer is! String || answer.trim().isEmpty) {
        throw const PhysAiException(
          'PhysAI бос жауап берді. Қайталап көріңіз.',
        );
      }
      return answer.trim();
    } on PhysAiException {
      rethrow;
    } on TimeoutException {
      throw const PhysAiException('Жауап тым ұзақ күттірді. Қайталап көріңіз.');
    } on SocketException {
      throw const PhysAiException('Интернет қосылымын тексеріңіз.');
    } on FormatException {
      throw const PhysAiException('Groq жауабын оқу мүмкін болмады.');
    } catch (_) {
      throw const PhysAiException('PhysAI-ға қосылу мүмкін болмады.');
    } finally {
      client.close(force: true);
    }
  }

  Future<String> _resolveApiKey() async {
    if (_apiKey.isNotEmpty) return _apiKey.trim();
    try {
      final content = await rootBundle.loadString(_localKeyAsset);
      final data = jsonDecode(content) as Map<String, dynamic>;
      return (data['GROQ_API_KEY'] as String? ?? '').trim();
    } catch (_) {
      return '';
    }
  }
}
