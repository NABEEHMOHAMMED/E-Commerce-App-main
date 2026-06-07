import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/favorite_provider.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                    .withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Product Image (Flex 1.2) ─────────────────────
          Expanded(
            flex: 12,
            child: Stack(
              children: [
                Hero(
                  tag: 'product_${product.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      memCacheHeight: 300,
                      placeholder: (context, url) => Container(
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? Color(0xFF1E1E38)
                            : AppTheme.bgLightSurface),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryPurple,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? Color(0xFF1E1E38)
                            : AppTheme.bgLightSurface),
                        child: Icon(
                          Icons.image_not_supported,
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white54
                              : Color(0xFF8E92A6)),
                        ),
                      ),
                    ),
                  ),
                ),
                // Discount badge
                if (product.discountPercentage != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.neonRed, Color(0xFFFF6B6B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-${product.discountPercentage}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<FavoriteProvider>(
                    builder: (ctx, favoriteProvider, _) {
                      final isFav = favoriteProvider.isFavorite(product);
                      return GestureDetector(
                        onTap: () => favoriteProvider.toggleFavorite(product),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).cardColor.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFav ? AppTheme.neonPink : Colors.grey,
                            size: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ─── Product Details (Flex 1) ─────────────────────
          Expanded(
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCategoryLabel(product.categoryId),
                        style: TextStyle(
                          color: _getCategoryColor(product.categoryId),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Color(0xFF1A1D2E)),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.timeLeft != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: AppTheme.accentOrange,
                              size: 9,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              product.timeLeft!,
                              style: const TextStyle(
                                color: AppTheme.accentOrange,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(1)}',
                            style: TextStyle(
                              color:
                                  (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Color(0xFF1A1D2E)),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          if (product.oldPrice != null)
                            Flexible(
                              child: Text(
                                '\$${product.oldPrice!.toStringAsFixed(1)}',
                                style: TextStyle(
                                  color:
                                      (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white54
                                      : Color(0xFF8E92A6)),
                                  fontSize: 9,
                                  decoration: TextDecoration.lineThrough,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: AppTheme.neonYellow,
                                size: 10,
                              ),
                              SizedBox(width: 1),
                              Text(
                                '${product.rating}',
                                style: TextStyle(
                                  color:
                                      (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Color(0xFF1A1D2E)),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String categoryId) {
    const map = {
      'electronics': AppTheme.primaryBlue,
      "men's clothing": AppTheme.accentTeal,
      "women's clothing": AppTheme.neonPink,
      'jewelery': AppTheme.neonYellow,
      'smartphones': Color(0xFF0984E3),
      'watches': Color(0xFFD35400),
      'shoes': Color(0xFFE91E63),
      'furniture': Color(0xFF8E44AD),
      'beauty': Color(0xFFF06292),
      'toys': Color(0xFFFF9F43),
      'gaming': Color.fromARGB(255, 64, 129, 193),
      'accessories': Color(0xFF16A085),
      'sports': Color(0xFF27AE60),
      'groceries': Color(0xFFF39C12),
      'others': Color.fromARGB(255, 104, 88, 229),
    };
    return map[categoryId] ?? AppTheme.primaryPurple;
  }

  String _getCategoryLabel(String categoryId) {
    const map = {
      'electronics': 'Electronics',
      "men's clothing": "Men's Fashion",
      "women's clothing": "Women's Fashion",
      'jewelery': 'Jewelery',
      'smartphones': 'Smartphones',
      'watches': 'Watches',
      'shoes': 'Shoes',
      'furniture': 'Furniture',
      'beauty': 'Beauty',
      'toys': 'Toys',
      'gaming': 'Gaming',
      'accessories': 'Accessories',
      'sports': 'Sports',
      'groceries': 'Groceries',
      'others': 'Others',
    };
    return map[categoryId] ?? categoryId;
  }
}
