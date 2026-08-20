import 'package:bloom_app/MODELS/product_models.dart';
import 'package:bloom_app/SCREEN/add_edit_diskon_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';

class DiskonScreen extends StatefulWidget {
  const DiskonScreen({super.key});

  @override
  State<DiskonScreen> createState() => _DiskonScreenState();
}

class _DiskonScreenState extends State<DiskonScreen> {
  final _productService = ProductService();

  List<ProductModel> _filterDiskon(List<ProductModel> products) {
    return products
        .where((p) => p.originalPrice != null && p.originalPrice!.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditDiskonScreen(isDiscountMode: true),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ProductModel>>(
          stream: _productService.getProducts(),
          builder: (context, snapshot) {
            final diskonProducts = _filterDiskon(snapshot.data ?? []);
            final isLoading = snapshot.connectionState == ConnectionState.waiting;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_offer_rounded, color: Colors.redAccent, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'Produk Diskon',
                                style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${diskonProducts.length} produk sedang diskon',
                        style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMedium),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                      : diskonProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.local_offer_outlined, color: AppColors.accent, size: 70),
                                  const SizedBox(height: 16),
                                  Text('Belum ada produk diskon', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Text('Tekan tombol + untuk menambahkan', style: GoogleFonts.dmSans(color: AppColors.textLight)),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              itemCount: diskonProducts.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 14),
                              itemBuilder: (ctx, i) {
                                return _DiskonCard(product: diskonProducts[i]);
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Card Diskon
class _DiskonCard extends StatelessWidget {
  final ProductModel product;

  const _DiskonCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product.toMap())),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                  child: Image.network(
                    product.image,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 110, height: 110, color: AppColors.accent.withOpacity(0.15)),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                    child: const Text('DISKON', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                      child: Text(product.category, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 6),
                    Text(product.name, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(product.brand, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textLight)),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          product.price,
                          style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        if (product.originalPrice != null && product.originalPrice!.isNotEmpty)
                          Text(
                            product.originalPrice!,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textLight,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}