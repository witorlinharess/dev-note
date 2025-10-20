import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = _buildElevatedButton();
        break;
      case ButtonType.secondary:
        button = _buildOutlinedButton();
        break;
      case ButtonType.text:
        button = _buildTextButton();
        break;
      case ButtonType.success:
        button = _buildSuccessButton();
        break;
      case ButtonType.error:
        button = _buildErrorButton();
        break;
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildElevatedButton() {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: _buildIcon(),
      label: _buildLabel(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: _buildIcon(),
      label: _buildLabel(),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildTextButton() {
    return TextButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: _buildIcon(),
      label: _buildLabel(),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSuccessButton() {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: _buildIcon(),
      label: _buildLabel(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildErrorButton() {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: _buildIcon(),
      label: _buildLabel(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildIcon() {
    if (isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    if (icon != null) {
      return Icon(icon, size: 18);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLabel() {
    return Text(text);
  }
}

enum ButtonType {
  primary,
  secondary,
  text,
  success,
  error,
}