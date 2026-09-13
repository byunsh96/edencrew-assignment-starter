import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../domains/favorite_list/controllers/favorite_controller.dart';

//TODO 리뷰 확인

/// 앱 전역 의존성. `main`에서 `MultiProvider`로 감싼다.
///
/// 상태 없는 Repository는 여기 올리지 않는다. `CoreRepository.instance`를
/// 기본값으로 쓰므로 `context` 없이 어디서든 만들 수 있다.
///
/// **여기에는 여러 화면이 공유하는 것만 올린다.** 한 화면에서만 쓰는 컨트롤러는
/// 해당 화면 위젯에 `ChangeNotifierProvider`로 붙여 화면과 함께 소멸시킨다.
///
/// ```dart
/// runApp(
///   MultiProvider(providers: AppProviders.global, child: const App()),
/// );
/// ```
abstract final class AppProviders {
  static List<SingleChildWidget> get global => <SingleChildWidget>[
        // 관심 · 검색 · 상세 세 화면이 같은 인스턴스를 봐야 한다.
        ChangeNotifierProvider<FavoriteController>(
          create: (_) => FavoriteController(),
        ),
      ];
}
