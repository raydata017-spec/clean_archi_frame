import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/config/dimensions.dart';
import '../../app/config/localization/generated/translations.g.dart';
import '../../core/utils/extensions/context_extension.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String initialCountryCode;
  final ValueChanged<String>? onCountryCodeChanged;
  final TextInputAction textInputAction;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.initialCountryCode = '+95',
    this.onCountryCodeChanged,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late String _selectedCountryCode;

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = widget.initialCountryCode;
  }

  String _getFlagForCode(String code) {
    switch (code) {
      case '+66':
        return '🇹🇭';
      case '+65':
        return '🇸🇬';
      case '+1':
        return '🇺🇸';
      case '+91':
        return '🇮🇳';
      case '+95':
      default:
        return '🇲🇲';
    }
  }

  void _showCountryPickerBottomSheet() {
    final countries = [
      {'code': '+95', 'name': 'Myanmar', 'flag': '🇲🇲'},
      {'code': '+66', 'name': 'Thailand', 'flag': '🇹🇭'},
      {'code': '+65', 'name': 'Singapore', 'flag': '🇸🇬'},
      {'code': '+1', 'name': 'United States', 'flag': '🇺🇸'},
      {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.borderRadiusMd),
          topRight: Radius.circular(AppSizes.borderRadiusMd),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSizes.paddingMarginSm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMarginMd),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMarginMd),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.auth.phoneNumber,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingMarginSm),
              Divider(color: context.colorScheme.onSurface.withValues(alpha: .1)),
              ...countries.map((country) {
                final isSelected = country['code'] == _selectedCountryCode;
                return ListTile(
                  leading: Text(
                    country['flag']!,
                    style: const TextStyle(fontSize: AppSizes.fontSizeLg),
                  ),
                  title: Text(
                    country['name']!,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: Text(
                    country['code']!,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? context.colorScheme.primary : null,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCountryCode = country['code']!;
                    });
                    if (widget.onCountryCodeChanged != null) {
                      widget.onCountryCodeChanged!(country['code']!);
                    }
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.auth.phoneNumber,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.onSurface.withValues(alpha: .9),
          ),
        ),
        const SizedBox(height: AppSizes.paddingMarginSm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _showCountryPickerBottomSheet,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
              child: Container(
                height: AppSizes.buttonHeightMd + 8.0, // 48
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.cardRadiusMd),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.colorScheme.onSurface.withValues(alpha: .2),
                    width: AppSizes.dividerThickness,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getFlagForCode(_selectedCountryCode),
                      style: const TextStyle(fontSize: AppSizes.fontSizeSm),
                    ),
                    const SizedBox(width: AppSizes.paddingMarginXs),
                    Text(
                      _selectedCountryCode,
                      style: TextStyle(
                        fontSize: AppSizes.fontSizeSm,
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurface.withValues(alpha: .9),
                      ),
                    ),
                    const SizedBox(width: AppSizes.paddingMarginXs),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.colorScheme.onSurface.withValues(alpha: .9),
                      size: AppSizes.iconSm,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSizes.paddingMarginSm),
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: widget.textInputAction,
                style: TextStyle(
                  color: context.colorScheme.onSurface.withValues(alpha: .9),
                  fontSize: AppSizes.fontSizeSm + 1.0,
                ),
                decoration: context.inputDecoration(hintText: '9 1234 5678'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t.auth.phoneRequired;
                  }
                  if (value.trim().length < 8) {
                    return t.auth.phoneInvalid;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
