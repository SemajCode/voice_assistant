import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:voice_assistant/secrets.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiAPIKey'
        },
        body: jsonEncode(
          {
            'model': 'gpt-3.5-turbo',
            'messages': [
              {
                'role': 'user',
                'content':
                    'Does this message wants to generate an AI image, art, picture or anything similar? $prompt . Simply answer with a yes or no.',
              }
            ]
          },
        ),
      );
      print(res.body);
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['messages']['content'];
        content = content.trim();
        switch (content) {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
    } catch (e) {
      return e.toString();
    }

    return 'An internal error occured';
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiAPIKey'
        },
        body: jsonEncode(
          {
            'model': 'gpt-3.5-turbo',
            'messages': messages,
          },
        ),
      );
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['messages']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
    } catch (e) {
      return e.toString();
    }
    return 'CHAPGPT';
  }

  Future<String> dallEAPI(String prompt) async {
    return 'DALL-E';
  }
}
