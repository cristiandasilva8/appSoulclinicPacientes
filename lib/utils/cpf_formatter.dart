import 'package:flutter/services.dart';

class CpfFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove todos os caracteres não numéricos
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Limita a 11 dígitos
    if (newText.length > 11) {
      newText = newText.substring(0, 11);
    }
    
    // Aplica a máscara
    String formattedText = _applyMask(newText);
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
  
  String _applyMask(String text) {
    if (text.isEmpty) return '';
    
    if (text.length <= 3) {
      return text;
    } else if (text.length <= 6) {
      return '${text.substring(0, 3)}.${text.substring(3)}';
    } else if (text.length <= 9) {
      return '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6)}';
    } else {
      return '${text.substring(0, 3)}.${text.substring(3, 6)}.${text.substring(6, 9)}-${text.substring(9)}';
    }
  }
  
  // Remove a máscara do CPF
  static String removeMask(String cpf) {
    return cpf.replaceAll(RegExp(r'[^0-9]'), '');
  }
  
  // Valida se o CPF tem 11 dígitos
  static bool isValidLength(String cpf) {
    return removeMask(cpf).length == 11;
  }
  
  // Valida CPF (algoritmo básico)
  static bool isValid(String cpf) {
    String cleanCpf = removeMask(cpf);
    if (cleanCpf.length != 11) return false;
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cleanCpf)) return false;
    
    // Validação do primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleanCpf[i]) * (10 - i);
    }
    int firstDigit = (sum * 10) % 11;
    if (firstDigit == 10) firstDigit = 0;
    if (int.parse(cleanCpf[9]) != firstDigit) return false;
    
    // Validação do segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cleanCpf[i]) * (11 - i);
    }
    int secondDigit = (sum * 10) % 11;
    if (secondDigit == 10) secondDigit = 0;
    if (int.parse(cleanCpf[10]) != secondDigit) return false;
    
    return true;
  }
}
