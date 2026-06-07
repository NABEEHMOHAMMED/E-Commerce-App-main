import 'package:e_commerce_app_with_provider/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

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
          'My Favorites',
          style: TextStyle(
            color: (Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1A1D2E)),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.neonPink.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: AppTheme.neonPink,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<FavoriteProvider>(
        builder: (ctx, favoriteProvider, _) {
          if (favoriteProvider.favorites.isEmpty) {
            return _buildEmptyFavorites(context);
          }
          return Column(
            children: [
              // ─── Header Stats ──────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.pinkGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${favoriteProvider.favorites.length} items',
                          style: TextStyle(
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white54
                                : const Color(0xFF8E92A6)),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Saved for you',
                          style: TextStyle(
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : const Color(0xFF1A1D2E)),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.neonPink.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Wishlist',
                        style: TextStyle(
                          color: AppTheme.neonPink,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ─── Grid ──────────────────────────────────
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: favoriteProvider.favorites.length,
                  itemBuilder: (ctx, index) {
                    final product = favoriteProvider.favorites[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: ProductCard(product: product),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyFavorites(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              gradient: AppTheme.pinkGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              color:
                  (Theme.of(context).brightness ==
                      Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1A1D2E)),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap the heart icon on any product to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    (Theme.of(context).brightness ==
                        Brightness.dark
                    ? Colors.white54
                    : const Color(0xFF8E92A6)),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
