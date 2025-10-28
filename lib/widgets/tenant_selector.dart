import 'package:flutter/material.dart';
import '../config/app_config.dart';

class TenantSelector extends StatelessWidget {
  final String selectedTenant;
  final Function(String) onTenantChanged;

  const TenantSelector({
    super.key,
    required this.selectedTenant,
    required this.onTenantChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecione sua clínica:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedTenant,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: AppConfig.tenants.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Color(entry.value.primaryColor),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(entry.value.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onTenantChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}
