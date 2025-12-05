import 'package:http/http.dart' as http;
import 'dart:io';

void main() async {
  final url = Uri.parse('https://api.judgerules.it/api/events?limit=20&skip=0&list=1');
  
  print('Testing connection to $url');

  // Test 1: Default Dart User-Agent
  try {
    print('\n--- Test 1: Default Headers ---');
    final response = await http.get(url);
    print('Status: ${response.statusCode}');
    print('Body length: ${response.body.length}');
    if (response.statusCode == 200) {
      print('Preview: ${response.body.substring(0, 100)}');
    }
  } catch (e) {
    print('Error: $e');
  }

  // Test 2: Curl User-Agent
  try {
    print('\n--- Test 2: Curl Headers ---');
    final response = await http.get(url, headers: {
      'User-Agent': 'curl/7.88.1',
      'Accept': '*/*',
    });
    print('Status: ${response.statusCode}');
    print('Body length: ${response.body.length}');
    if (response.statusCode == 200) {
      print('Preview: ${response.body.substring(0, 100)}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

