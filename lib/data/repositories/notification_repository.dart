import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../models/api_response.dart';
import '../../models/app_notification.dart';
import '../mock/mock_data.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> fetchNotifications();
}

class MockNotificationRepository implements NotificationRepository {
  @override
  Future<List<AppNotification>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.notifications;
  }
}

class ApiNotificationRepository implements NotificationRepository {
  final ApiClient _client = ApiClient.instance;

  @override
  Future<List<AppNotification>> fetchNotifications() {
    return _client.request(
      (dio) => dio.get(ApiEndpoints.notifications),
      parse: (data) {
        final response = ApiResponse<List<dynamic>>.fromJson(
          data as Map<String, dynamic>,
          (p0) => p0 as List<dynamic>,
        );
        return (response.data ?? const [])
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}

NotificationRepository createNotificationRepository() =>
    Env.useMockData ? MockNotificationRepository() : ApiNotificationRepository();
