class Ward {
  Ward.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        localityEn = j['localityEn'],
        localityHi = j['localityHi'],
        centerLat = (j['centerLat'] as num).toDouble(),
        centerLng = (j['centerLng'] as num).toDouble(),
        radiusMeters = j['radiusMeters'],
        targetHouseholds = j['targetHouseholds'];

  final int id;
  final String localityEn;
  final String localityHi;
  final double centerLat;
  final double centerLng;
  final int radiusMeters;
  final int targetHouseholds;

  String locality(bool hindi) => hindi ? localityHi : localityEn;

  String label(bool hindi) => hindi ? 'वार्ड $id · $localityHi' : 'Ward $id · $localityEn';
}

class Question {
  Question.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        part = j['part'],
        _titleEn = j['titleEn'],
        _titleHi = j['titleHi'],
        _shortEn = j['shortEn'],
        _shortHi = j['shortHi'],
        _greenEn = j['greenEn'],
        _greenHi = j['greenHi'],
        _yellowEn = j['yellowEn'],
        _yellowHi = j['yellowHi'],
        _redEn = j['redEn'],
        _redHi = j['redHi'];

  final int id;
  final String part;
  final String _titleEn, _titleHi, _shortEn, _shortHi;
  final String _greenEn, _greenHi, _yellowEn, _yellowHi, _redEn, _redHi;

  String title(bool hi) => hi ? _titleHi : _titleEn;
  String short(bool hi) => hi ? _shortHi : _shortEn;
  String green(bool hi) => hi ? _greenHi : _greenEn;
  String yellow(bool hi) => hi ? _yellowHi : _yellowEn;
  String red(bool hi) => hi ? _redHi : _redEn;
}

class Volunteer {
  Volunteer.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        code = j['code'],
        name = j['name'],
        wardId = j['wardId'],
        surveysToday = j['surveysToday'];

  final int id;
  final String code;
  final String name;
  final int wardId;
  final int surveysToday;
}
