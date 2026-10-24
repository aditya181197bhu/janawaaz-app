class TicketUpdate {
  TicketUpdate.fromJson(Map<String, dynamic> j)
      : status = j['status'],
        note = j['note'],
        createdAt = DateTime.parse(j['createdAt']).toLocal();

  final String status;
  final String? note;
  final DateTime createdAt;
}

class Ticket {
  Ticket.fromJson(Map<String, dynamic> j)
      : ticketNo = j['ticketNo'],
        wardId = j['wardId'],
        category = j['category'],
        description = j['description'],
        landmark = j['landmark'],
        residentName = j['residentName'],
        residentMobileMasked = j['residentMobileMasked'],
        photoUrl = j['photoUrl'],
        latitude = (j['latitude'] as num?)?.toDouble(),
        longitude = (j['longitude'] as num?)?.toDouble(),
        locationStatus = j['locationStatus'],
        status = j['status'],
        createdAt = DateTime.parse(j['createdAt']).toLocal(),
        updates = (j['updates'] as List? ?? []).map((u) => TicketUpdate.fromJson(u)).toList();

  final String ticketNo;
  final int wardId;
  final String category;
  final String? description;
  final String? landmark;
  final String? residentName;
  final String? residentMobileMasked;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final String locationStatus;
  final String status;
  final DateTime createdAt;
  final List<TicketUpdate> updates;

  /// The next status a volunteer or admin can move this ticket to, or null if completed.
  String? get nextStatus => switch (status) {
        'REPORTED' => 'IN_PROGRESS',
        'IN_PROGRESS' => 'RESOLVED',
        _ => null,
      };
}
