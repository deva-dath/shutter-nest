import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shutter_nest/core/utils/adaptive_glass.dart';

/// Theme-aligned app bar for ShutterNest. Uses brand green, gradient, or optional glass.
class ShutterAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShutterAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.leadingIcon = Icons.arrow_back_ios_new_rounded,
    this.onLeadingTap,
    this.actions,
    this.useGlass = false,
    this.gradient = defaultGradient,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
  });

  /// Short title text (ignored if [titleWidget] is set).
  final String? title;

  /// Custom title widget. Overrides [title] when set.
  final Widget? titleWidget;

  /// Custom leading widget. If null and [onLeadingTap] is set, uses [leadingIcon].
  final Widget? leading;
  final IconData leadingIcon;
  final VoidCallback? onLeadingTap;
  final List<Widget>? actions;

  /// When false (default), uses solid brand green or [gradient]. White content when not glass.
  final bool useGlass;
  /// When set, app bar background uses this gradient (ignores solid color). Use [defaultGradient] for theme gradient.
  final Gradient? gradient;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  static const double _toolbarHeight = 56;

  /// Brand green for app bar background.
  static const Color _brandGreen = Color(0xFF1E7F3E);
  static const Color _brandGreenLight = Color(0xFF6DBE45);
  static const Color _onGreen = Colors.white;

  /// Default gradient: lighter green to darker green (top to bottom). Matches splash style.
  static const LinearGradient defaultGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_brandGreenLight, _brandGreen],
  );

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isColoredBar = !useGlass;
    final contentColor = isColoredBar ? _onGreen : theme.colorScheme.onSurface;
    final iconColor = isColoredBar ? _onGreen : (isDark ? _brandGreenLight : _brandGreen);

    Widget? leadingWidget = leading;
    if (leadingWidget == null &&
        (onLeadingTap != null ||
            (automaticallyImplyLeading &&
                ModalRoute.of(context)?.canPop == true))) {
      leadingWidget = IconButton(
        icon: Icon(leadingIcon, size: 22, color: iconColor),
        onPressed: onLeadingTap ?? () => Navigator.of(context).maybePop(),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      );
    }

    final Widget titleContent =
        titleWidget ??
        (title != null
            ? Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: contentColor,
                ),
              )
            : const SizedBox.shrink());

    final Widget barContent = SafeArea(
      bottom: false,
      child: SizedBox(
        height: _toolbarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              if (leadingWidget != null) leadingWidget,
              Expanded(
                child: centerTitle
                    ? Center(child: titleContent)
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: titleContent,
                      ),
              ),
              if (actions != null && actions!.isNotEmpty) ...actions!,
            ],
          ),
        ),
      ),
    );

    if (useGlass) {
      return AdaptiveGlass.navBar(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        child: barContent,
      );
    }

    final Widget barBackground = gradient != null
        ? Container(
            decoration: BoxDecoration(gradient: gradient),
            child: barContent,
          )
        : Material(
            color: isDark ? _brandGreenLight : _brandGreen,
            elevation: 0,
            child: barContent,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: barBackground,
    );
  }
}
