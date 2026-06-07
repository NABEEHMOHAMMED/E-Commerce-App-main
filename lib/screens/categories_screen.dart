import 'package:e_commerce_app_with_provider/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import 'category_products_screen.dart';
import '../localization/app_localizations.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Provider.of<NavigationProvider>(context, listen: false).goHome();
            }
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E1E38) : AppTheme.bgLightSurface),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
              size: 18,
            ),
          ),
        ),
        title: Text(
          context.tr('categories'),
          style: TextStyle(
            color: (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Color(0xFF1A1D2E)),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ─── Search Bar ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 52,
              decoration: BoxDecoration(
                color: (Theme.of(context).brightness == Brightness.dark ? Color(0xFF1E1E38) : AppTheme.bgLightSurface),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      255,
                      254,
                      254,
                      254,
                    ).withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppTheme.primaryPurple,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: context.tr('search_categories'),
                        hintStyle: TextStyle(
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white54
                                      : const Color(0xFF8E92A6))
                                  .withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Color(0xFF1A1D2E)),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.tune_rounded,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // ─── All Categories Header ───────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('all_categories'),
                  style: TextStyle(
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Color(0xFF1A1D2E)),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Consumer<ProductProvider>(
                    builder: (_, provider, _) {
                      return Text(
                        '${provider.categories.length} ${context.tr('items')}',
                        style: const TextStyle(
                          color: AppTheme.primaryPurple,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ─── Category Grid ───────────────────────────────
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (ctx, productProvider, _) {
                final categories = productProvider.categories;
                if (categories.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryPurple,
                    ),
                  );
                }
                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (ctx, index) {
                    return _CategoryCard(category: categories[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  static const Map<String, IconData> _icons = {
    'electronics': Icons.electrical_services_rounded,
    "men's clothing": Icons.checkroom_rounded,
    "women's clothing": Icons.checkroom_rounded,
    'jewelery': Icons.diamond_rounded,
    'smartphones': Icons.smartphone_rounded,
    'watches': Icons.watch_rounded,
    'shoes': Icons.directions_walk_rounded,
    'furniture': Icons.chair_rounded,
    'beauty': Icons.face_retouching_natural_rounded,
    'toys': Icons.toys_rounded,
    'sports': Icons.sports_basketball_rounded,
    'groceries': Icons.shopping_basket_rounded,
    'accessories': Icons.watch_rounded,
    'gaming': Icons.sports_esports_rounded,
  };

  static const Map<String, Color> _colors = {
    'electronics': Color(0xFF00BFA6),
    "men's clothing": Color(0xFF6C5CE7),
    "women's clothing": Color(0xFFFF4B8D),
    'jewelery': Color(0xFFFFC547),
    'smartphones': Color(0xFF4A90E2),
    'watches': Color(0xFFFF6B35),
    'shoes': Color(0xFFE91E8C),
    'furniture': Color(0xFF7B2FBE),
    'beauty': Color(0xFFFF5252),
    'toys': Color(0xFF00BCD4),
    'sports': Color(0xFF00E676),
    'groceries': Color(0xFFFF9F43),
    'accessories': Color(0xFF00CEC9),
    'gaming': Color(0xFF8C52FF), // Changed from dark 0xFF2C3E50 to bright purple
  };

  @override
  Widget build(BuildContext context) {
    final icon = _icons[category.id] ?? Icons.category_rounded;
    final color = _colors[category.id] ?? Colors.purple;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsScreen(category: category),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              context.tr(category.id),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1A1D2E)),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${category.productCount} ${context.tr('products')}',
                style: TextStyle(
                  color: (Theme.of(context).brightness == Brightness.dark ? color : color.withValues(alpha: 0.8)),
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
