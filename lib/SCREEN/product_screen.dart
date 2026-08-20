import 'package:bloom_app/MODELS/product_models.dart';
import 'package:bloom_app/SCREEN/add_edit_product.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _searchController = TextEditingController();
  final _productService = ProductService();
  String _searchQuery = '';

  List<ProductModel> _filter(List<ProductModel> products) {
    if (_searchQuery.isEmpty) return products;
    return products
        .where((p) =>
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.brand.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (canPop)
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppColors.inputBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 16),
                          ),
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelola Produk',
                            style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                          Text(
                            'Tambah, edit, atau hapus produk',
                            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMedium),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: 'Cari bunga...',
                      prefixIcon: Icon(Icons.search, color: AppColors.textLight, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: _productService.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Terjadi kesalahan: ${snapshot.error}',
                          style: GoogleFonts.dmSans(color: AppColors.error)),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }

                  final products = _filter(snapshot.data ?? []);

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_florist_outlined, color: AppColors.accent, size: 60),
                          const SizedBox(height: 16),
                          Text('Belum ada produk',
                              style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
                          const SizedBox(height: 8),
                          Text('Tap tombol + untuk menambahkan bunga',
                              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textLight)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, i) {
                      return _FlowerCard(
                        product: products[i],
                        productService: _productService,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Flower Card 

class _FlowerCard extends StatefulWidget {
  final ProductModel product;
  final ProductService productService;

  const _FlowerCard({required this.product, required this.productService});

  @override
  State<_FlowerCard> createState() => _FlowerCardState();
}

class _FlowerCardState extends State<_FlowerCard> {
  bool _isFav = false;

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Produk', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: Text('Yakin ingin menghapus "${widget.product.name}"?', style: GoogleFonts.dmSans(color: AppColors.textMedium)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal', style: GoogleFonts.dmSans(color: AppColors.textMedium))),
          TextButton(
            onPressed: () async {
              await widget.productService.deleteProduct(widget.product.id!);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('Hapus', style: GoogleFonts.dmSans(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: widget.product.toMap())),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                  child: Image.network(
                    widget.product.image,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 110, height: 110, color: AppColors.accent.withOpacity(0.2)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                              child: Text(widget.product.category, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _isFav = !_isFav),
                              child: Icon(_isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: _isFav ? AppColors.accentDark : AppColors.textLight, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(widget.product.name, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(widget.product.brand, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textLight)),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.price,
                          style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AddEditProductScreen(product: widget.product)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit_outlined, color: AppColors.primary, size: 14),
                            const SizedBox(width: 4),
                            Text('Edit', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _confirmDelete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.delete_outline, color: AppColors.error, size: 14),
                            const SizedBox(width: 4),
                            Text('Hapus', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}