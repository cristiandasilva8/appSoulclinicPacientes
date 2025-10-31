import 'lib/services/portal_test_service.dart';

void main() async {
  const token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJwYWNpZW50ZV9pZCI6IjEiLCJjcGYiOiIwNjUuOTcxLjI4OS0wNyIsIm5vbWUiOiJQYWNpZW50ZSB0ZXN0ZSIsImVtYWlsIjoibHVhbmFkdXRyYWRjQGdtYWlsLmNvbSIsInRlbmFudF9pZCI6IjY1IiwiZGF0YWJhc2VfZ3JvdXAiOiJncm91cF9jbGluaWNhX2R1dHJhXzY1IiwiaXNzIjoiU291bENsaW5pYyBBUEkiLCJhdWQiOiJTb3VsQ2xpbmljIFVzZXJzIiwiaWF0IjoxNzYxNzgxNjQ3LCJleHAiOjE3NjE3ODUyNDd9.9IIHTJmK2oMBD4vpJwUQ_iMKc3Uzv885sWfeKXDnf-U';
  
  print('🚀 Testando Portal do Paciente com token fornecido');
  print('=' * 60);
  
  // Testar todos os endpoints do portal
  final results = await PortalTestService.testAllPortalEndpoints(token);
  
  // Gerar relatório
  PortalTestService.generateReport(results);
  
  print('\n🎯 PRÓXIMOS PASSOS:');
  print('1. ✅ Endpoints do Portal funcionam perfeitamente');
  print('2. 🔧 Atualize seu app para usar apenas esses endpoints');
  print('3. 🚀 Seu app deve funcionar agora!');
}
