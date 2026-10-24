class TicketTotals {
  TicketTotals.fromJson(Map<String, dynamic> j)
      : total = j['total'],
        reported = j['reported'],
        inProgress = j['inProgress'],
        resolved = j['resolved'];

  final int total;
  final int reported;
  final int inProgress;
  final int resolved;

  int get open => reported + inProgress;

  int get completedPct => total == 0 ? 0 : (resolved * 100 / total).round();
}

class IssueStat {
  IssueStat.fromJson(Map<String, dynamic> j)
      : questionId = j['questionId'],
        _shortEn = j['shortEn'],
        _shortHi = j['shortHi'],
        greenPct = j['greenPct'],
        yellowPct = j['yellowPct'],
        redPct = j['redPct'];

  final int questionId;
  final String _shortEn, _shortHi;
  final int greenPct, yellowPct, redPct;

  String short(bool hi) => hi ? _shortHi : _shortEn;
}

class CategoryCount {
  CategoryCount.fromJson(Map<String, dynamic> j)
      : category = j['category'],
        total = j['total'],
        reported = j['reported'],
        inProgress = j['inProgress'],
        resolved = j['resolved'];

  final String category;
  final int total, reported, inProgress, resolved;

  int get pending => reported + inProgress;
}

class MapPoint {
  MapPoint({required this.lat, required this.lng, required this.status, this.category, this.wardId, this.ticketNo});

  final double lat;
  final double lng;
  final String status;
  final String? category;
  final int? wardId;
  final String? ticketNo;

  factory MapPoint.ticket(Map<String, dynamic> j) => MapPoint(
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        status: j['status'],
        category: j['category'],
        wardId: j['wardId'],
        ticketNo: j['ticketNo'],
      );

  factory MapPoint.survey(Map<String, dynamic> j) => MapPoint(
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        status: j['locationStatus'],
        wardId: j['wardId'],
      );
}

class WardReport {
  WardReport.fromJson(Map<String, dynamic> j)
      : wardId = j['wardId'],
        localityEn = j['localityEn'],
        localityHi = j['localityHi'],
        centerLat = (j['centerLat'] as num).toDouble(),
        centerLng = (j['centerLng'] as num).toDouble(),
        radiusMeters = j['radiusMeters'],
        tickets = TicketTotals.fromJson(j['tickets']),
        byCategory = (j['byCategory'] as List).map((c) => CategoryCount.fromJson(c)).toList(),
        points = (j['points'] as List).map((p) => MapPoint.ticket(p)).toList(),
        householdsSurveyed = j['householdsSurveyed'],
        minHouseholds = j['minHouseholds'],
        enoughSurveyData = j['enoughSurveyData'],
        topProblems = (j['topProblems'] as List).map((p) => IssueStat.fromJson(p)).toList();

  final int wardId;
  final String localityEn, localityHi;
  final double centerLat, centerLng;
  final int radiusMeters;
  final TicketTotals tickets;
  final List<CategoryCount> byCategory;
  final List<MapPoint> points;
  final int householdsSurveyed, minHouseholds;
  final bool enoughSurveyData;
  final List<IssueStat> topProblems;
}

class AdminWardRow {
  AdminWardRow.fromJson(Map<String, dynamic> j)
      : wardId = j['wardId'],
        localityEn = j['localityEn'],
        localityHi = j['localityHi'],
        surveyed = j['surveyed'],
        target = j['target'],
        tickets = TicketTotals.fromJson(j['tickets']),
        volunteers = j['volunteers'],
        flaggedSurveys = j['flaggedSurveys'];

  final int wardId;
  final String localityEn, localityHi;
  final int surveyed, target;
  final TicketTotals tickets;
  final int volunteers, flaggedSurveys;

  String locality(bool hi) => hi ? localityHi : localityEn;
}

class AdminOverview {
  AdminOverview.fromJson(Map<String, dynamic> j)
      : householdsSurveyed = j['householdsSurveyed'],
        targetHouseholds = j['targetHouseholds'],
        volunteers = j['volunteers'],
        surveysToday = j['surveysToday'],
        ticketsToday = j['ticketsToday'],
        tickets = TicketTotals.fromJson(j['tickets']),
        avgResolutionDays = (j['avgResolutionDays'] as num?)?.toDouble(),
        flaggedSurveys = j['flaggedSurveys'],
        topRedIssues = (j['topRedIssues'] as List).map((i) => IssueStat.fromJson(i)).toList(),
        wards = (j['wards'] as List).map((w) => AdminWardRow.fromJson(w)).toList();

  final int householdsSurveyed, targetHouseholds, volunteers, surveysToday, ticketsToday;
  final TicketTotals tickets;
  final double? avgResolutionDays;
  final int flaggedSurveys;
  final List<IssueStat> topRedIssues;
  final List<AdminWardRow> wards;
}

class VolunteerActivity {
  VolunteerActivity.fromJson(Map<String, dynamic> j)
      : code = j['code'],
        name = j['name'],
        surveys = j['surveys'],
        tickets = j['tickets'],
        flaggedSurveys = j['flaggedSurveys'],
        lastActiveAt = j['lastActiveAt'] == null ? null : DateTime.parse(j['lastActiveAt']).toLocal();

  final String code, name;
  final int surveys, tickets, flaggedSurveys;
  final DateTime? lastActiveAt;
}

class HeatmapData {
  HeatmapData.fromJson(Map<String, dynamic> j)
      : columns = (j['columns'] as List).cast<Map<String, dynamic>>(),
        rows = (j['rows'] as List).cast<Map<String, dynamic>>();

  /// [{questionId, shortEn, shortHi}] — one per issue.
  final List<Map<String, dynamic>> columns;

  /// [{wardId, localityEn, localityHi, redPct: [..per issue..]}] — one per ward.
  final List<Map<String, dynamic>> rows;
}

class FlaggedSurvey {
  FlaggedSurvey.fromJson(Map<String, dynamic> j)
      : receiptNo = j['receiptNo'],
        wardId = j['wardId'],
        volunteerCode = j['volunteerCode'],
        volunteerName = j['volunteerName'],
        outsideWard = j['outsideWard'],
        tooFast = j['tooFast'],
        durationSeconds = j['durationSeconds'],
        distanceFromWardMeters = j['distanceFromWardMeters'],
        submittedAt = DateTime.parse(j['submittedAt']).toLocal();

  final String receiptNo;
  final int wardId;
  final String volunteerCode, volunteerName;
  final bool outsideWard, tooFast;
  final int durationSeconds;
  final int? distanceFromWardMeters;
  final DateTime submittedAt;
}

class QualityData {
  QualityData.fromJson(Map<String, dynamic> j)
      : totalSurveys = j['totalSurveys'],
        outsideWard = j['outsideWard'],
        tooFast = j['tooFast'],
        minSecondsPerSurvey = j['minSecondsPerSurvey'],
        flagged = (j['flagged'] as List).map((f) => FlaggedSurvey.fromJson(f)).toList();

  final int totalSurveys, outsideWard, tooFast, minSecondsPerSurvey;
  final List<FlaggedSurvey> flagged;
}

class WardHeat {
  WardHeat.fromJson(Map<String, dynamic> j)
      : wardId = j['wardId'],
        centerLat = (j['centerLat'] as num).toDouble(),
        centerLng = (j['centerLng'] as num).toDouble(),
        radiusMeters = j['radiusMeters'],
        tickets = TicketTotals.fromJson(j['tickets']);

  final int wardId;
  final double centerLat, centerLng;
  final int radiusMeters;
  final TicketTotals tickets;
}

class AdminMapData {
  AdminMapData.fromJson(Map<String, dynamic> j)
      : wards = (j['wards'] as List).map((w) => WardHeat.fromJson(w)).toList(),
        tickets = (j['tickets'] as List).map((t) => MapPoint.ticket(t)).toList(),
        surveys = (j['surveys'] as List).map((s) => MapPoint.survey(s)).toList();

  final List<WardHeat> wards;
  final List<MapPoint> tickets;
  final List<MapPoint> surveys;
}
