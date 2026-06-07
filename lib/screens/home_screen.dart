// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import '../providers/navigation_provider.dart';
import '../localization/app_localizations.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';
import 'all_products_screen.dart';
import 'category_products_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Widget> _screens = const [
    MainHomeScreen(),
    CategoriesScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        final selectedIndex = navProvider.selectedIndex;

        return Scaffold(
          body: _screens[selectedIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: _buildNavItem(
                        context,
                        navProvider,
                        0,
                        Icons.home_filled,
                        Icons.home_outlined,
                        context.tr('home'),
                      ),
                    ),
                    Expanded(
                      child: _buildNavItem(
                        context,
                        navProvider,
                        1,
                        Icons.grid_view_rounded,
                        Icons.grid_view_outlined,
                        context.tr('categories'),
                      ),
                    ),
                    Expanded(
                      child: _buildFavoriteNavItem(context, navProvider),
                    ),
                    Expanded(child: _buildCartNavItem(context, navProvider)),
                    Expanded(
                      child: _buildNavItem(
                        context,
                        navProvider,
                        4,
                        Icons.person_rounded,
                        Icons.person_outline_rounded,
                        context.tr('profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavigationProvider nav,
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label, {
    Widget? badge,
  }) {
    final isSelected = nav.selectedIndex == index;
    return GestureDetector(
      onTap: () => nav.setSelectedIndex(index),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryPurple.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                  child: Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    key: ValueKey(isSelected),
                    color: isSelected
                        ? AppTheme.primaryPurple
                        : AppTheme.navInactive,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.primaryPurple
                        : AppTheme.navInactive,
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null) Positioned(top: 4, right: 8, child: badge),
        ],
      ),
    );
  }

  Widget _buildCartNavItem(BuildContext context, NavigationProvider nav) {
    return _buildNavItem(
      context,
      nav,
      3,
      Icons.shopping_cart_rounded,
      Icons.shopping_cart_outlined,
      context.tr('cart'),
      badge: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          if (cart.itemCount == 0) return SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.neonRed,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
            child: Text(
              '${cart.itemCount}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteNavItem(BuildContext context, NavigationProvider nav) {
    return _buildNavItem(
      context,
      nav,
      2,
      Icons.favorite_rounded,
      Icons.favorite_border_rounded,
      context.tr('favorites'),
      badge: Consumer<FavoriteProvider>(
        builder: (ctx, favs, _) {
          if (favs.favorites.isEmpty) return SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.neonRed,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
            child: Text(
              '${favs.favorites.length}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}

// ─── Main Home Content ────────────────────────────────────────────────────────

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<ProductProvider>(
        builder: (ctx, productProvider, _) {
          final showStatusBanner =
              productProvider.errorMessage != null &&
              productProvider.allProducts.isNotEmpty;

          return RefreshIndicator(
            onRefresh: () => productProvider.fetchProducts(),
            color: AppTheme.primaryPurple,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ─── App Bar ─────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: AppTheme.primaryPurple,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      context.tr('app_title'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    centerTitle: true,
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.heroGradient,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -40,
                            right: -60,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -60,
                            left: -40,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),

                // ─── Status Banner ───────────────────────────────
                if (showStatusBanner)
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentOrange.withValues(alpha: 0.9),
                            AppTheme.neonRed.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentOrange.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              productProvider.isConnected
                                  ? Icons.warning_rounded
                                  : Icons.wifi_off_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              productProvider.errorMessage ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ─── Loading State ───────────────────────────────
                if (productProvider.isLoading &&
                    productProvider.allProducts.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryPurple.withValues(
                                  alpha: 0.2,
                                ),
                                width: 3,
                              ),
                            ),
                            child: const CircularProgressIndicator(
                              color: AppTheme.primaryPurple,
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            context.tr('loading_products'),
                            style: TextStyle(
                              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Color(0xFF8E92A6)),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ─── Empty State ─────────────────────────────────
                if (!productProvider.isLoading &&
                    productProvider.allProducts.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            productProvider.errorMessage ?? context.tr('no_products'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1A1D2E)),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              context.tr('something_went_wrong'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => productProvider.fetchProducts(),
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            label: Text(context.tr('try_again')),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ─── Products Found ──────────────────────────────
                if (productProvider.allProducts.isNotEmpty) ...[
                  // ─── Banner Section ────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppTheme.heroGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr('grand_sale'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    context.tr('sale_desc'),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    height: 32,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        context.tr('shop_now'),
                                        style: const TextStyle(
                                          color: AppTheme.primaryPurple,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                cacheHeight: 240, // Optimize memory usage
                                errorBuilder: (_, _, _) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ─── Flash Deals Header ────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.neonRed.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.local_fire_department_rounded,
                                          color: AppTheme.neonRed,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          context.tr('flash_deals').split(' ')[0],
                                          style: const TextStyle(
                                            color: AppTheme.neonRed,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    context.tr('flash_deals').split(' ').length > 1 ? context.tr('flash_deals').split(' ').sublist(1).join(' ') : '',
                                    style: TextStyle(
                                      color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1A1D2E)),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.tr('exclusive_offers'),
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AllProductsScreen(
                                    title: 'Flash Deals',
                                    products: productProvider.allProducts,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPurple.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                context.tr('see_all'),
                                style: const TextStyle(
                                  color: AppTheme.primaryPurple,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── Flash Deals (Horizontal scroll) ───────────
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 280,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 14, 10, 14),
                        itemCount: productProvider.allProducts.take(6).length,
                        itemBuilder: (ctx, i) {
                          final product = productProvider.allProducts[i];
                          return Padding(
                            padding: EdgeInsets.only(right: i < 5 ? 14 : 10),
                            child: GestureDetector(
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
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ─── Trending Header ───────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.neonYellow.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.trending_up_rounded,
                                          color: AppTheme.neonYellow,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          context.tr('trending'),
                                          style: const TextStyle(
                                            color: AppTheme.neonYellow,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '',
                                    style: TextStyle(
                                      color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1A1D2E)),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.tr('trending_desc'),
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AllProductsScreen(
                                    title: 'Trending',
                                    products: productProvider
                                        .allProducts
                                        .reversed
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentTeal.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                context.tr('see_all'),
                                style: TextStyle(
                                  color: AppTheme.accentTeal,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── Trending (Horizontal scroll) ──────────────
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 280,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 14, 10, 14),
                        itemCount: productProvider.allProducts
                            .skip(6)
                            .take(6)
                            .length,
                        itemBuilder: (ctx, i) {
                          final product = productProvider.allProducts[i + 6];
                          return Padding(
                            padding: EdgeInsets.only(right: i < 5 ? 14 : 10),
                            child: GestureDetector(
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
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ─── Categories Quick Access ────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Categories',
                            style: TextStyle(
                              color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Color(0xFF1A1D2E)),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Consumer<ProductProvider>(
                            builder: (ctx, productProvider, _) {
                              final categories = productProvider.categories;
                              if (categories.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return SizedBox(
                                height: 90,
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categories.length,
                                  itemBuilder: (ctx, i) {
                                    final cat = categories[i];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  CategoryProductsScreen(
                                                    category: cat,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 80,
                                          decoration: BoxDecoration(
                                            gradient: AppTheme.primaryGradient,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.primaryPurple
                                                    .withValues(alpha: 0.2),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).cardColor.withValues(alpha: 0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  _categoryEmoji(cat.id),
                                                  size: 22,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                cat.name,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _categoryEmoji(String categoryId) {
    const map = {
      'electronics': Icons.electrical_services_rounded,
      "men's clothing": Icons.checkroom_rounded,
      "women's clothing": Icons.checkroom_rounded,
      'jewelery': Icons.diamond_rounded,
      'sports': Icons.sports_soccer_rounded,
      'furniture': Icons.chair_rounded,
      'beauty': Icons.spa_rounded,
      'accessories': Icons.watch_rounded,
      'toys': Icons.toys_rounded,
      'books': Icons.auto_stories_rounded,
      'food': Icons.restaurant_rounded,
      'health': Icons.local_hospital_rounded,
      'music': Icons.music_note_rounded,
      'tools': Icons.build_rounded,
      'computers': Icons.computer_rounded,
      'automotive': Icons.directions_car_rounded,
      'home': Icons.house_rounded,
      'industrial': Icons.factory_rounded,
      'others': Icons.category_rounded,
    };
    return map[categoryId] ?? Icons.category_rounded;
  }
}
