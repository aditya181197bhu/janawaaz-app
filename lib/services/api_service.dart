import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import '../models/meta.dart';
import '../models/stats.dart';
import '../models/survey.dart';
import '../models/ticket.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Thin HTTP client for the Jan Awaaz backend. Same pattern as the Stavya app.
class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  static const _timeout = Duration(seconds: 20);
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  // ---------- Meta ----------

  Future<List<Ward>> wards() async =>
      (await _get('/wards') as List).map((w) => Ward.fromJson(w)).toList();

  Future<List<Question>> questions() async =>
      (await _get('/questions') as List).map((q) => Question.fromJson(q)).toList();

  Future<Volunteer> volunteer(int id) async => Volunteer.fromJson(await _get('/volunteers/$id'));

  /// Uploads a photo or voice note and returns its server path.
  Future<String> upload(File file, {required String kind}) async {
    final request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/files'))
      ..fields['kind'] = kind
      // The http package no longer infers the MIME type from the extension, and the
      // backend rejects application/octet-stream, so set it explicitly.
      ..files.add(await http.MultipartFile.fromPath('file', file.path, contentType: _mediaTypeFor(file.path)));
    final response = await http.Response.fromStream(await request.send().timeout(const Duration(seconds: 60)));
    return (_decode(response) as Map<String, dynamic>)['url'];
  }

  // ---------- Ward view (Janta and volunteer) ----------

  Future<WardReport> wardReport(int wardId) async => WardReport.fromJson(await _get('/public/wards/$wardId'));

  // ---------- Surveys ----------

  Future<SurveyReceipt> submitSurvey(Map<String, dynamic> body) async =>
      SurveyReceipt.fromJson(await _send('POST', '/surveys', body));

  Future<List<SurveySummary>> mySurveys(int volunteerId, {int limit = 5}) async =>
      (await _get('/surveys', {'volunteerId': '$volunteerId', 'limit': '$limit'}) as List)
          .map((s) => SurveySummary.fromJson(s))
          .toList();

  // ---------- Complaints ----------

  Future<List<Ticket>> createTickets(Map<String, dynamic> body) async =>
      (await _send('POST', '/complaints', body) as List).map((t) => Ticket.fromJson(t)).toList();

  Future<List<Ticket>> tickets({int? wardId, String? status}) async =>
      (await _get('/complaints', {'wardId': wardId?.toString(), 'status': status}) as List)
          .map((t) => Ticket.fromJson(t))
          .toList();

  Future<Ticket> ticket(String ticketNo) async =>
      Ticket.fromJson(await _get('/complaints/${Uri.encodeComponent(ticketNo.trim())}'));

  Future<Ticket> editTicket(String ticketNo, {String? category, String? description, String? landmark}) async =>
      Ticket.fromJson(await _send('PUT', '/complaints/$ticketNo',
          {'category': category, 'description': description, 'landmark': landmark}));

  Future<Ticket> updateTicketStatus(String ticketNo, String status, {String? note}) async =>
      Ticket.fromJson(await _send('PATCH', '/complaints/$ticketNo/status', {'status': status, 'note': note}));

  // ---------- Admin ----------

  Future<AdminOverview> adminOverview() async => AdminOverview.fromJson(await _get('/admin/overview'));

  Future<Map<String, dynamic>> adminWard(int wardId) async => await _get('/admin/wards/$wardId');

  Future<HeatmapData> heatmap() async => HeatmapData.fromJson(await _get('/admin/heatmap'));

  Future<QualityData> quality() async => QualityData.fromJson(await _get('/admin/quality'));

  Future<AdminMapData> adminMap() async => AdminMapData.fromJson(await _get('/admin/map'));

  // ---------- plumbing ----------

  Future<dynamic> _get(String path, [Map<String, String?>? query]) async {
    final params = {...?query}..removeWhere((_, v) => v == null);
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: params.isEmpty ? null : params);
    return _decode(await _guard(() => http.get(uri)));
  }

  Future<dynamic> _send(String method, String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final encoded = jsonEncode(body);
    final response = await _guard(() => switch (method) {
          'POST' => http.post(uri, headers: _jsonHeaders, body: encoded),
          'PUT' => http.put(uri, headers: _jsonHeaders, body: encoded),
          _ => http.patch(uri, headers: _jsonHeaders, body: encoded),
        });
    return _decode(response);
  }

  Future<http.Response> _guard(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(_timeout);
    } on SocketException {
      throw ApiException('Cannot reach the server. Check the internet connection.');
    } on HttpException {
      throw ApiException('Cannot reach the server. Check the internet connection.');
    }
  }

  dynamic _decode(http.Response response) {
    // Decode bytes as UTF-8 explicitly: the backend sends no charset, and the
    // http package would otherwise fall back to Latin-1 and garble Hindi.
    final text = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return text.isEmpty ? null : jsonDecode(text);
    }
    String message = 'Request failed (${response.statusCode})';
    try {
      message = (jsonDecode(text) as Map<String, dynamic>)['error'] ?? message;
    } catch (_) {}
    throw ApiException(message, statusCode: response.statusCode);
  }

  static MediaType _mediaTypeFor(String path) {
    final ext = path.toLowerCase().split('.').last;
    return switch (ext) {
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      'heic' => MediaType('image', 'heic'),
      'm4a' || 'mp4' => MediaType('audio', 'mp4'),
      'aac' => MediaType('audio', 'aac'),
      'wav' => MediaType('audio', 'wav'),
      _ => MediaType('image', 'jpeg'),
    };
  }
}
