class MusicTrack {
  final String id;
  final String title;
  final String filePath;
  final String description;
  final Duration? estimatedDuration;

  const MusicTrack({
    required this.id,
    required this.title,
    required this.filePath,
    required this.description,
    this.estimatedDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'description': description,
      'estimatedDuration': estimatedDuration?.inMilliseconds,
    };
  }

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      id: json['id'],
      title: json['title'],
      filePath: json['filePath'],
      description: json['description'],
      estimatedDuration: json['estimatedDuration'] != null 
          ? Duration(milliseconds: json['estimatedDuration'])
          : null,
    );
  }
} 