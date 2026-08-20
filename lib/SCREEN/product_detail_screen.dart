import 'package:bloom_app/SCREEN/add_edit_product.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/product_service.dart';
import '../MODELS/product_models.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFav = false;
  final _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    final id = widget.product['id']?.toString();

    if (id == null) {
      return const Scaffold(
        body: Center(child: Text('Produk tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<ProductModel?>(
        stream: _productService.getProductById(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final product = snapshot.data;
          if (product == null) {
            return Center(
              child: Text('Produk sudah tidak tersedia',
                  style: GoogleFonts.dmSans(color: AppColors.textMedium)),
            );
          }

          final data = product.toMap();

          return Column(
            children: [
              //Gambar
              Stack(
                children: [
                  SizedBox(
                    height: 320,
                    width: double.infinity,
                    child: Image.network(
                      data['image'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.accent.withOpacity(0.2),
                        child: const Center(
                          child: Icon(
                            Icons.local_florist_outlined,
                            color: AppColors.accent,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CircleBtn(
                            icon: Icons.arrow_back_ios_new,
                            onTap: () => Navigator.pop(context),
                          ),
                          _CircleBtn(
                            icon: _isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            iconColor:
                                _isFav ? AppColors.accentDark : AppColors.textDark,
                            onTap: () => setState(() => _isFav = !_isFav),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              //Detail
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge kategori
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            data['category'] as String,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Nama produk
                        Text(
                          data['name'] as String,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Brand
                        Text(
                          data['brand'] as String,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Rating bintang
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => Icon(
                                i < (data['rating'] as double).floor()
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: const Color(0xFFFFC107),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${data['rating']}',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              ' / 5.0',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Deskripsi
                        Text(
                          'Deskripsi',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['desc'] as String,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.textMedium,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Harga
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Harga',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                  Text(
                                    data['price'] as String,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.local_florist_rounded,
                                color: AppColors.primary,
                                size: 36,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tombol Edit Produk
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditProductScreen(
                                    product: product,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: Text(
                              'Edit Produk',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tombol Hapus Produk
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmDelete(context, data),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: Text(
                              'Hapus Produk',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error.withOpacity(0.1),
                              foregroundColor: AppColors.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Hapus Produk',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Yakin ingin menghapus "${data['name']}"?',
          style: GoogleFonts.dmSans(color: AppColors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.dmSans(color: AppColors.textMedium),
            ),
          ),
          TextButton(
            onPressed: () async {
              final id = widget.product['id']?.toString();
              if (id != null) {
                await _productService.deleteProduct(id);
              }
              if (!context.mounted) return;
              Navigator.pop(context); 
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Produk berhasil dihapus',
                    style: GoogleFonts.dmSans(),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.dmSans(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _CircleBtn({required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: iconColor ?? AppColors.textDark, size: 18),
      ),
    );
  }
}