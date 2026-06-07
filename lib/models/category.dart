class Category {
  final String id;
  final String name;
  final String icon;
  final String imageUrl;
  final int productCount;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.imageUrl,
    this.productCount = 0,
  });
}
