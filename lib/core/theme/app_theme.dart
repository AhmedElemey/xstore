import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.accent,
      onSecondary: AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
    ).copyWith(
      onSurfaceVariant: AppColors.lightTextSecondary,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorder,
      surfaceContainer: AppColors.lightSurfaceVariant,
      surfaceContainerHigh: AppColors.lightSurfaceVariant,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
    );

    return _themeData(
      scheme: scheme,
      backgroundColor: AppColors.lightBackground,
      surfaceVariant: AppColors.lightSurfaceVariant,
      elevatedSurface: AppColors.lightSurface,
      borderColor: AppColors.lightBorder,
      dividerColor: AppColors.lightDivider,
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      textDisabled: AppColors.lightTextDisabled,
      textHint: AppColors.lightTextHint,
      iconPrimary: AppColors.lightIconPrimary,
      iconSecondary: AppColors.lightIconSecondary,
      shadowColor: AppColors.lightShadow,
      cardShadowColor: AppColors.lightCardShadow,
      overlayColor: AppColors.lightOverlay,
      systemUiOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  static ThemeData get dark {
    final scheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: AppColors.darkBackground,
      secondary: AppColors.accentLight,
      onSecondary: AppColors.darkBackground,
      error: AppColors.errorLight,
      onError: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
    ).copyWith(
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorder,
      surfaceContainer: AppColors.darkSurfaceVariant,
      surfaceContainerHigh: AppColors.darkSurfaceElevated,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
    );

    return _themeData(
      scheme: scheme,
      backgroundColor: AppColors.darkBackground,
      surfaceVariant: AppColors.darkSurfaceVariant,
      elevatedSurface: AppColors.darkSurfaceElevated,
      borderColor: AppColors.darkBorder,
      dividerColor: AppColors.darkDivider,
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      textDisabled: AppColors.darkTextDisabled,
      textHint: AppColors.darkTextHint,
      iconPrimary: AppColors.darkIconPrimary,
      iconSecondary: AppColors.darkIconSecondary,
      shadowColor: AppColors.darkShadow,
      cardShadowColor: AppColors.darkCardShadow,
      overlayColor: AppColors.darkOverlay,
      systemUiOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  static ThemeData _themeData({
    required ColorScheme scheme,
    required Color backgroundColor,
    required Color surfaceVariant,
    required Color elevatedSurface,
    required Color borderColor,
    required Color dividerColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color textDisabled,
    required Color textHint,
    required Color iconPrimary,
    required Color iconSecondary,
    required Color shadowColor,
    required Color cardShadowColor,
    required Color overlayColor,
    required SystemUiOverlayStyle systemUiOverlayStyle,
  }) {
    final textTheme = AppTypography.textTheme(scheme).copyWith(
      displayLarge: AppTypography.displayLarge.copyWith(color: textPrimary),
      displayMedium: AppTypography.displayMedium.copyWith(color: textPrimary),
      titleLarge: AppTypography.titleLarge.copyWith(color: textPrimary),
      titleMedium: AppTypography.titleMedium.copyWith(color: textPrimary),
      titleSmall: AppTypography.titleSmall.copyWith(color: textPrimary),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: textPrimary),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: textPrimary),
      bodySmall: AppTypography.bodySmall.copyWith(color: textSecondary),
      labelLarge: AppTypography.labelLarge.copyWith(color: textPrimary),
      labelMedium: AppTypography.labelMedium.copyWith(color: textSecondary),
      labelSmall: AppTypography.labelSmall.copyWith(color: textSecondary),
    );
    final inputTextStyle = textTheme.bodyLarge?.copyWith(color: textPrimary);
    final inputHintStyle = textTheme.bodyMedium?.copyWith(color: textHint);

    final baseInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: backgroundColor,
      shadowColor: shadowColor,
      dividerColor: dividerColor,
      disabledColor: textDisabled,
      hintColor: textHint,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        iconTheme: IconThemeData(color: iconPrimary),
        actionsIconTheme: IconThemeData(color: iconPrimary),
        systemOverlayStyle: systemUiOverlayStyle,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        elevation: 8,
        selectedItemColor: scheme.primary,
        unselectedItemColor: textSecondary,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelSmall?.copyWith(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        hintStyle: inputHintStyle,
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.primary,
        ),
        helperStyle: inputHintStyle,
        prefixStyle: inputTextStyle,
        suffixStyle: inputTextStyle,
        counterStyle: inputHintStyle,
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputContentPaddingH,
          vertical: AppSpacing.inputContentPaddingV,
        ),
        border: baseInputBorder,
        enabledBorder: baseInputBorder,
        focusedBorder: baseInputBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        errorBorder: baseInputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: baseInputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.4),
        ),
        disabledBorder: baseInputBorder.copyWith(
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.6)),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.2),
        selectionHandleColor: scheme.primary,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: inputTextStyle,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceVariant,
          hintStyle: inputHintStyle,
          labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
          floatingLabelStyle: textTheme.bodyMedium?.copyWith(
            color: scheme.primary,
          ),
          helperStyle: inputHintStyle,
          prefixStyle: inputTextStyle,
          suffixStyle: inputTextStyle,
          border: baseInputBorder,
          enabledBorder: baseInputBorder,
          focusedBorder: baseInputBorder.copyWith(
            borderSide: BorderSide(color: scheme.primary, width: 1.4),
          ),
          disabledBorder: baseInputBorder.copyWith(
            borderSide: BorderSide(color: borderColor.withValues(alpha: 0.6)),
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(elevatedSurface),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: cardShadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor.withValues(alpha: 0.5)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        disabledColor: surfaceVariant.withValues(alpha: 0.55),
        selectedColor: scheme.primary.withValues(alpha: 0.12),
        secondarySelectedColor: scheme.primary.withValues(alpha: 0.16),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.chipPaddingH,
          vertical: AppSpacing.chipPaddingV,
        ),
        shape: StadiumBorder(side: BorderSide(color: borderColor)),
        labelStyle: textTheme.labelMedium?.copyWith(color: textPrimary),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.primary,
        ),
        checkmarkColor: scheme.primary,
        iconTheme: IconThemeData(color: iconSecondary, size: 18),
        side: BorderSide(color: borderColor),
      ),
      iconTheme: IconThemeData(color: iconPrimary),
      primaryIconTheme: IconThemeData(color: scheme.primary),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: elevatedSurface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: elevatedSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: elevatedSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleSmall?.copyWith(color: textPrimary),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary.withValues(alpha: 0.45);
          }
          return borderColor.withValues(alpha: 0.7);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: borderColor),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(scheme.onPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: elevatedSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actionTextColor: scheme.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        circularTrackColor: scheme.primary.withValues(alpha: 0.2),
        linearTrackColor: borderColor.withValues(alpha: 0.45),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: borderColor,
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.2),
        valueIndicatorColor: scheme.primary,
        valueIndicatorTextStyle: textTheme.labelSmall?.copyWith(
          color: scheme.onPrimary,
        ),
      ),
      splashColor: scheme.primary.withValues(alpha: 0.1),
      highlightColor: overlayColor.withValues(alpha: 0.1),
      hoverColor: overlayColor.withValues(alpha: 0.08),
      // Ensure editable text is always explicit and readable in every theme.
      primaryTextTheme: textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );
  }

  /// Scales text-adjacent paddings with [TextScaler] so inputs and chips keep
  /// rhythm when OS / accessibility text size changes.
  static ThemeData withScaledTextSpacing(ThemeData theme, TextScaler scaler) {
    final inputPadding = EdgeInsets.symmetric(
      horizontal: scaler.scale(AppSpacing.inputContentPaddingH),
      vertical: scaler.scale(AppSpacing.inputContentPaddingV),
    );
    final chipPadding = EdgeInsets.symmetric(
      horizontal: scaler.scale(AppSpacing.chipPaddingH),
      vertical: scaler.scale(AppSpacing.chipPaddingV),
    );
    final menuInput = theme.dropdownMenuTheme.inputDecorationTheme;
    return theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        contentPadding: inputPadding,
      ),
      chipTheme: theme.chipTheme.copyWith(padding: chipPadding),
      dropdownMenuTheme: theme.dropdownMenuTheme.copyWith(
        inputDecorationTheme: menuInput?.copyWith(
          contentPadding: inputPadding,
        ),
      ),
    );
  }
}
