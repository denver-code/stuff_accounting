class Item {
  final String title;
  final String description;
  final String picture;
  final String upc;
  final String owner;
  final String tag;
  final String id;

  Item({
    required this.title,
    required this.description,
    required this.picture,
    required this.upc,
    required this.owner,
    required this.tag,
    required this.id,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      picture: json['picture'] ?? '',
      upc: json['upc'] ?? '',
      owner: json['owner'] ?? '',
      tag: json['tag'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'picture': picture,
        'upc': upc,
        'owner': owner,
        'tag': tag,
        'id': id,
      };
}
