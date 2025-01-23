class Contact {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String category;
  final String imageUrl;
  final bool isFavorite;
  final bool isBlacklisted;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.category,
    required this.imageUrl,
    this.isFavorite = false,
    this.isBlacklisted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'category': category,
      'imageUrl': imageUrl,
      'isFavorite': isFavorite,
      'isBlacklisted': isBlacklisted,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map, String documentId) {
    return Contact(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
      isBlacklisted: map['isBlacklisted'] ?? false,
    );
  }

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? category,
    String? imageUrl,
    bool? isFavorite,
    bool? isBlacklisted,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
    );
  }
}
