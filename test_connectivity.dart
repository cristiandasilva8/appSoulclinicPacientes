import 'dart:io';
import 'dart:convert';

/// Script para testar conectividade com o servidor
/// 
/// Uso:
///   dart test_connectivity.dart [token_jwt]
/// 
/// Se o token não for fornecido, a requisição será feita sem autenticação
void main(List<String> args) async {
  print('🔍 Testando conectividade com o servidor...');
  
  // Obter token dos argumentos ou usar vazio
  final token = args.isNotEmpty ? args[0] : null;
  
  if (token == null || token.isEmpty) {
    print('⚠️  Token não fornecido. Usando requisição sem autenticação.');
    print('💡 Uso: dart test_connectivity.dart <seu_token_jwt>');
  }
  
  try {
    final client = HttpClient();
    final request = await client.getUrl(
      Uri.parse('https://production.soulclinic.com.br/api/portal/dashboard'),
    );
    
    // Adicionar token apenas se fornecido
    if (token != null && token.isNotEmpty) {
      request.headers.set('Authorization', 'Bearer $token');
    }
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
    print('💡 Verifique se o servidor está acessível em https://production.soulclinic.com.br');
  }
}
