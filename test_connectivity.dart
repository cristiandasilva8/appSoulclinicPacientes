import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔍 Testando conectividade com o servidor...');
  
  try {
    final client = HttpClient();
    final request = await client.getUrl(
      Uri.parse('http://127.0.0.1:8080/api/portal/dashboard'),
    );
    
    request.headers.set('Authorization', 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwYWNpZW50ZV9pZCI6IjEiLCJjcGYiOiIwNjUuOTcxLjI4OS0wNyIsIm5vbWUiOiJQYWNpZW50ZSB0ZXN0ZSIsImVtYWlsIjoibHVhbmFkdXRyYWRjQGdtYWlsLmNvbSIsInRlbmFudF9pZCI6IjY1IiwiZGF0YWJhc2VfZ3JvdXAiOiJncm91cF9jbGluaWNhX2R1dHJhXzY1IiwiaXNzIjoiU291bENsaW5pYyBBUEkiLCJhdWQiOiJTb3VsQ2xpbmljIFVzZXJzIiwiaWF0IjoxNzYxNzgxNjQ3LCJleHAiOjE3NjE3ODUyNDd9.9IIHTJmK2oMBD4vpJwUQ_iMKc3Uzv885sWfeKXDnf-U');
    request.headers.set('Content-Type', 'application/json');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('✅ Conectividade OK!');
    print('📊 Status: ${response.statusCode}');
    print('📄 Response: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}...');
    
    if (response.statusCode == 200) {
      print('🎉 Servidor está acessível!');
    } else {
      print('❌ Servidor retornou erro: ${response.statusCode}');
    }
    
  } catch (e) {
    print('❌ Erro de conectividade: $e');
    print('💡 Verifique se o servidor está rodando em http://127.0.0.1:8080');
  }
}
