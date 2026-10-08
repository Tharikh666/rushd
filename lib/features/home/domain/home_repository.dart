import '../../../core/result/app_result.dart';
import 'home_models.dart';

abstract interface class HomeRepository {
  Future<AppResult<HomeSnapshot>> getHomeSnapshot();
}
