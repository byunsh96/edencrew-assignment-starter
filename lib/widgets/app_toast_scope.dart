import 'package:flutter/material.dart';

/// 토스트가 뜰 수 있는 영역을 만든다.
///
/// `AppToast`는 `Overlay.of(context)`로 **가장 가까운 상위 `Overlay`** 를 찾고,
/// 토스트는 그 `Overlay`의 박스 안에 배치된다.
/// 그래서 이 위젯으로 감싼 범위가 곧 토스트의 아래쪽 경계가 된다.
///
/// 하단 탭 바 위에 띄우고 싶으면 탭 바를 제외한 영역만 감싸면 된다.
/// 토스트가 탭 바 높이나 safe area를 직접 계산할 필요가 없어진다.
///
/// ```dart
/// Column(
///   children: <Widget>[
///     Expanded(child: AppToastScope(child: body)),
///     AppTabBar(...),
///   ],
/// )
/// ```
class AppToastScope extends StatefulWidget {
  const AppToastScope({required this.child, super.key});

  final Widget child;

  @override
  State<AppToastScope> createState() => _AppToastScopeState();
}

class _AppToastScopeState extends State<AppToastScope> {
  /// build가 다시 돌 때마다 새 항목이 만들어지지 않도록 한 번만 생성한다.
  late final OverlayEntry _entry = OverlayEntry(builder: (_) => widget.child);

  @override
  void didUpdateWidget(AppToastScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child != oldWidget.child) _entry.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(initialEntries: <OverlayEntry>[_entry]);
  }
}
