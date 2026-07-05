import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String actionType; // 'destination', 'hotel', 'package', 'link'
  final String actionTarget; // target ID or URL

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.actionType,
    required this.actionTarget,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'actionType': actionType,
      'actionTarget': actionTarget,
    };
  }

  factory BannerModel.fromMap(Map<String, dynamic> map, String docId) {
    return BannerModel(
      id: docId,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      actionType: map['actionType'] ?? '',
      actionTarget: map['actionTarget'] ?? '',
    );
  }

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BannerModel.fromMap(data, doc.id);
  }
}
