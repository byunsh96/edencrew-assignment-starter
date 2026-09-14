import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../constants/app_text_styles.dart';
import '../theme/theme.dart';
import 'app_svg_icon.dart';

/// 화면 하단에 잠깐 떴다 사라지는 알림.
///
/// Figma에는 떠 있는 모습만 있다. 노출 시간과 사라지는 방식은 직접 정했다.
/// - 2초 뒤 자동으로 사라진다. 문구가 짧아 읽기에 충분하고, 연속으로 토글할 때
///   화면을 오래 가리지 않는다.
/// - 이미 떠 있는 토스트가 있으면 교체한다. 빠르게 여러 번 누를 때 쌓이면
///   마지막 동작의 결과를 알 수 없다.
abstract final class AppToast {
  static const Duration _visibleDuration = Duration(seconds: 2);
  static const Duration _fadeDuration = Duration(milliseconds: 200);

  static OverlayEntry? _current;

  /// 관심 등록 · 해제 토스트.
  static void favorite(BuildContext context, {required bool added}) {
    final AppColors colors = context.colors;

    show(
      context,
      icon: added ? AppIcons.starFill : AppIcons.star,
      iconColor: added ? colors.favoriteActive : colors.textSecondary,
      message: added ? '관심이 등록되었습니다' : '관심이 해제되었습니다',
    );
  }

  static void show(
    BuildContext context, {
    required String icon,
    required Color iconColor,
    required String message,
  }) {
    final OverlayState overlay = Overlay.of(context);
    _dismiss();

    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext context) => _ToastCard(
        icon: icon,
        iconColor: iconColor,
        message: message,
        visibleDuration: _visibleDuration,
        fadeDuration: _fadeDuration,
        onFinished: _dismiss,
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }

  static void _dismiss() {
    _current?.remove();
    _current = null;
  }
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.visibleDuration,
    required this.fadeDuration,
    required this.onFinished,
  });

  final String icon;
  final Color iconColor;
  final String message;
  final Duration visibleDuration;
  final Duration fadeDuration;
  final VoidCallback onFinished;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.fadeDuration,
  );

  @override
  void initState() {
    super.initState();
    _play();
  }

  Future<void> _play() async {
    await _controller.forward();
    await Future<void>.delayed(widget.visibleDuration);
    if (!mounted) return;

    await _controller.reverse();
    if (!mounted) return;
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    final AppDimens dimens = context.dimens;

    return Positioned(
      left: dimens.space4,
      right: dimens.space4,
      bottom: dimens.space3,
      child: FadeTransition(
        opacity: _controller,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: dimens.space4,
              vertical: dimens.space3Mid, // Figma 토스트 세로 여백
            ),
            decoration: BoxDecoration(
              color: colors.surfaceOverlay,
              borderRadius: BorderRadius.circular(dimens.radiusLg),
              boxShadow: <BoxShadow>[
                BoxShadow(color: colors.dropShadow, blurRadius: 24, offset: Offset(0, 8)),
              ],
            ),
            child: Row(
              spacing: dimens.space2,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSvgIcon(widget.icon, size: dimens.iconSmMd, color: widget.iconColor),
                Flexible(
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.left,
                    style: AppTextStyles.label.copyWith(color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
