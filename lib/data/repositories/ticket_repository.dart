import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../models/api_response.dart';
import '../../models/my_ticket.dart';
import '../mock/mock_data.dart';

abstract class TicketRepository {
  Future<List<MyTicket>> fetchMyTickets();
}

class MockTicketRepository implements TicketRepository {
  @override
  Future<List<MyTicket>> fetchMyTickets() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockData.myTickets;
  }
}

/// Talks to the existing Laravel/Eventiq REST API (`GET /my-tickets`).
class ApiTicketRepository implements TicketRepository {
  final ApiClient _client = ApiClient.instance;

  @override
  Future<List<MyTicket>> fetchMyTickets() {
    return _client.request(
      (dio) => dio.get(ApiEndpoints.myTickets),
      parse: (data) {
        final response = ApiResponse<List<dynamic>>.fromJson(
          data as Map<String, dynamic>,
          (p0) => p0 as List<dynamic>,
        );
        return (response.data ?? const [])
            .map((e) => MyTicket.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}

TicketRepository createTicketRepository() => Env.useMockData ? MockTicketRepository() : ApiTicketRepository();
