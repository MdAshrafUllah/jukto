// ignore_for_file: public_member_api_docs, sort_constructors_first

class Cgpa {
  Cgpa({required this.subjectName, required this.credit, required this.point});

  final String subjectName;
  final double credit;
  final double point;

  factory Cgpa.fromJson(Map<String, dynamic> json) => Cgpa(
      subjectName: json['subjectName'],
      credit: json['credit'],
      point: json['point']);

  Map<String, dynamic> toJson(Cgpa cgpa) {
    return {
      'subjectName': cgpa.subjectName,
      'credit': cgpa.credit,
      'point': cgpa.point,
    };
  }

  @override
  bool operator ==(covariant Cgpa other) {
    if (identical(this, other)) return true;

    return other.subjectName == subjectName &&
        other.credit == credit &&
        other.point == point;
  }

  @override
  int get hashCode => subjectName.hashCode ^ credit.hashCode ^ point.hashCode;
}
