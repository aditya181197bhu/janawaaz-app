/// A survey being filled in on the phone, before it is submitted.
class SurveyDraft {
  SurveyDraft({required this.wardId}) : startedAt = DateTime.now();

  final int wardId;
  final DateTime startedAt;
  String? respondentName;
  int? respondentAge;
  String respondentGender = 'FEMALE';
  String? occupation;
  String? mobile;
  bool whatsappOptIn = false;
  final Map<int, AnswerDraft> answers = {};
  final List<int> priorities = [];

  Map<String, dynamic> toJson({
    required int volunteerId,
    double? latitude,
    double? longitude,
    double? accuracy,
  }) =>
      {
        'volunteerId': volunteerId,
        'wardId': wardId,
        'respondentName': respondentName,
        'respondentAge': respondentAge,
        'respondentGender': respondentGender,
        'occupation': occupation,
        'mobile': mobile,
        'consentGiven': true,
        'whatsappOptIn': whatsappOptIn,
        'latitude': latitude,
        'longitude': longitude,
        'gpsAccuracyMeters': accuracy,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'answers': answers.entries
            .map((e) => {
                  'questionId': e.key,
                  'rating': e.value.rating,
                  'photoUrl': e.value.photoUrl,
                  'voiceUrl': e.value.voiceUrl,
                })
            .toList(),
        'priorityQuestionIds': priorities,
      };
}

class AnswerDraft {
  AnswerDraft(this.rating);

  String rating; // GREEN, YELLOW, RED or NA
  String? photoUrl;
  String? voiceUrl;
}

class SurveyReceipt {
  SurveyReceipt.fromJson(Map<String, dynamic> j)
      : receiptNo = j['receiptNo'],
        wardId = j['wardId'],
        green = j['green'],
        yellow = j['yellow'],
        red = j['red'],
        notApplicable = j['notApplicable'],
        priorityQuestionIds = (j['priorityQuestionIds'] as List).cast<int>(),
        locationStatus = j['locationStatus'],
        distanceFromWardMeters = j['distanceFromWardMeters'];

  final String receiptNo;
  final int wardId, green, yellow, red, notApplicable;
  final List<int> priorityQuestionIds;
  final String locationStatus;
  final int? distanceFromWardMeters;
}

class SurveySummary {
  SurveySummary.fromJson(Map<String, dynamic> j)
      : receiptNo = j['receiptNo'],
        wardId = j['wardId'],
        respondentName = j['respondentName'],
        green = j['green'],
        yellow = j['yellow'],
        red = j['red'],
        locationStatus = j['locationStatus'],
        submittedAt = DateTime.parse(j['submittedAt']).toLocal();

  final String receiptNo;
  final int wardId;
  final String? respondentName;
  final int green, yellow, red;
  final String locationStatus;
  final DateTime submittedAt;
}
