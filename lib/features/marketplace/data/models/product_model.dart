class Product {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final String category;
  final String categoryAr;
  final String craftsman;
  final String craftsmanAr;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final bool isFavorite;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const Product({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.price,
    this.currency = 'جنيه',
    required this.imageUrls,
    required this.category,
    required this.categoryAr,
    required this.craftsman,
    required this.craftsmanAr,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.isFavorite = false,
    required this.createdAt,
    this.metadata,
  });

  Product copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    double? price,
    String? currency,
    List<String>? imageUrls,
    String? category,
    String? categoryAr,
    String? craftsman,
    String? craftsmanAr,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    bool? isFavorite,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      categoryAr: categoryAr ?? this.categoryAr,
      craftsman: craftsman ?? this.craftsman,
      craftsmanAr: craftsmanAr ?? this.craftsmanAr,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'price': price,
      'currency': currency,
      'imageUrls': imageUrls,
      'category': category,
      'categoryAr': categoryAr,
      'craftsman': craftsman,
      'craftsmanAr': craftsmanAr,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'isFavorite': isFavorite,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameAr: map['nameAr'] ?? '',
      description: map['description'] ?? '',
      descriptionAr: map['descriptionAr'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'جنيه',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      category: map['category'] ?? '',
      categoryAr: map['categoryAr'] ?? '',
      craftsman: map['craftsman'] ?? '',
      craftsmanAr: map['craftsmanAr'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      isFavorite: map['isFavorite'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      metadata: map['metadata'],
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, nameAr: $nameAr, price: $price, category: $categoryAr)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Sample data for demonstration
class ProductSampleData {
  static List<Product> getSampleProducts() {
    return [
      Product(
        id: '1',
        name: 'Handwoven Scarf',
        nameAr: 'ثوب مطرز تراثي',
        description: 'Beautiful traditional Egyptian handwoven scarf',
        descriptionAr: 'وشاح مصري تقليدي منسوج يدوياً',
        price: 850,
        imageUrls: ['https://via.placeholder.com/300x200'],
        category: 'Clothing',
        categoryAr: 'أثاث',
        craftsman: 'Ahmed Hassan',
        craftsmanAr: 'أحمد حسن',
        rating: 4.5,
        reviewCount: 23,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Product(
        id: '2',
        name: 'Wooden Jewelry Box',
        nameAr: 'صندوق مجوهرات خشبي مزخرف',
        description: 'Handcrafted wooden jewelry box with intricate designs',
        descriptionAr: 'ورشة الذهب التراثي',
        price: 250,
        imageUrls: ['https://via.placeholder.com/300x200'],
        category: 'Wooden Items',
        categoryAr: 'خشبيات',
        craftsman: 'Fatima Al-Zahra',
        craftsmanAr: 'فاطمة الزهراء',
        rating: 4.8,
        reviewCount: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Product(
        id: '3',
        name: 'Hand-carved Plate',
        nameAr: 'طبق خزفية منقوشة يدوياً',
        description: 'Beautiful ceramic plate with traditional Egyptian motifs',
        descriptionAr: 'بجارة الأجداد',
        price: 1200,
        imageUrls: ['https://via.placeholder.com/300x200'],
        category: 'Ceramics',
        categoryAr: 'آثاث',
        craftsman: 'Omar Selim',
        craftsmanAr: 'عمر سليم',
        rating: 4.3,
        reviewCount: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Product(
        id: '4',
        name: 'Traditional Jewelry Set',
        nameAr: 'مجموعة إكسسوارات خزفية',
        description: 'Handcrafted ceramic jewelry set',
        descriptionAr: 'حرفة الخزر',
        price: 180,
        imageUrls: ['https://via.placeholder.com/300x200'],
        category: 'Accessories',
        categoryAr: 'إكسسوارات',
        craftsman: 'Mariam Farouk',
        craftsmanAr: 'مريم فاروق',
        rating: 4.7,
        reviewCount: 31,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}
