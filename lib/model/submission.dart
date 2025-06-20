class Submission {
  final String id;
  final String title;
  final String submissionText;
  final String submissionDate;

  Submission({
    required this.id,
    required this.title,
    required this.submissionText,
    required this.submissionDate,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'].toString(),
      title: json['title'],
      submissionText: json['submission_text'],
      submissionDate: json['submission_date'],
    );
  }
}