/// Matches the Laravel/Eventiq envelope: `{ status, message, data }`.
class ApiResponse<T> {
  final bool status;
  final String message;
  final T? data;

  const ApiResponse({this.status = false, this.message = '', this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      status: json['status'] as bool? ?? false,
      message: (json['message'] ?? '').toString(),
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}

/// Matches Laravel's default paginator shape.
class PaginatedResponse<T> {
  final int currentPage;
  final List<T> data;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;

  const PaginatedResponse({
    this.currentPage = 1,
    this.data = const [],
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
    this.nextPageUrl,
  });

  bool get hasMore => nextPageUrl != null && nextPageUrl!.isNotEmpty;

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return PaginatedResponse<T>(
      currentPage: json['current_page'] as int? ?? 1,
      data: (json['data'] as List<dynamic>? ?? const []).map(fromJsonT).toList(),
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      nextPageUrl: json['next_page_url'] as String?,
    );
  }
}
