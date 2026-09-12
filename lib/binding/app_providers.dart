import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../core/repository/core_repository.dart';

/// 앱 전역 의존성. `main`에서 `MultiProvider`로 감싼다.
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
        // 모든 Repository가 참조한다. 상태를 갖지 않으므로 Provider로 올린다.
        Provider<CoreRepository>(
          create: (_) => CoreRepository(),
          dispose: (_, CoreRepository repository) => repository.close(),
        ),
      ];
}
