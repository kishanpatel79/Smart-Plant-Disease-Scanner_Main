class Disease {
  final String name;
  final String description;
  final String symptoms;
  final String treatment;
  final String prevention;

  Disease({
    required this.name,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      symptoms: json['symptoms'] ?? '',
      treatment: json['treatment'] ?? '',
      prevention: json['prevention'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'symptoms': symptoms,
      'treatment': treatment,
      'prevention': prevention,
    };
  }
}
