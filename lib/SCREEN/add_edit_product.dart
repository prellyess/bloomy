import 'dart:io';
import 'package:bloom_app/MODELS/product_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../services/product_service.dart';
import '../widgets/buttons.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();
  final _descController = TextEditingController();
  final _ratingController = TextEditingController();

  final _productService = ProductService();

  String _selectedCategory = 'Mawar';
  XFile? _pickedFile;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameController.text = widget.product!.name;
      _brandController.text = widget.product!.brand;
      _priceController.text = widget.product!.price;
      _imageController.text = widget.product!.image;
      _descController.text = widget.product!.desc;
      _ratingController.text = widget.product!.rating.toString();
      _selectedCategory = widget.product!.category;
    } else {
      _ratingController.text = '4.5';
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
          _imageController.text = pickedFile.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Nama produk wajib diisi!');
      return false;
    }
    if (_priceController.text.trim().isEmpty) {
      _showError('Harga produk wajib diisi!');
      return false;
    }
    final rating = double.tryParse(_ratingController.text);
    if (rating == null || rating < 1.0 || rating > 5.0) {
      _showError('Rating harus antara 1.0 - 5.0!');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.dmSans()),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Future<void> _save() async {
    if (!_validateInputs()) return;

    setState(() => _isSaving = true);

    String imageValue = _imageController.text.trim();
    if (_pickedFile != null) {
      imageValue = _pickedFile!.path;
    }

    final product = ProductModel(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      brand: _brandController.text.trim().isEmpty
          ? 'Bloom Florist'
          : _brandController.text.trim(),
      price: _priceController.text.trim(),
      originalPrice: null,
      category: _selectedCategory,
      image: imageValue.isEmpty
          ? 'https://images.unsplash.com/photo-1559563458-527698bf5295?w=400'
          : imageValue,
      desc: _descController.text.trim(),
      rating: double.parse(_ratingController.text),
    );

    try {
      if (_isEdit) {
        await _productService.updateProduct(product);
      } else {
        await _productService.addProduct(product);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          _isEdit ? 'Produk berhasil diupdate!' : 'Produk berhasil ditambahkan!',
          style: GoogleFonts.dmSans(),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError('Gagal menyimpan produk: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Produk' : 'Tambah Produk',
          style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: _buildImagePreview(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text('Pilih Gambar dari Galeri',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 24),

            _label('Nama Bunga *'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'cth: Mawar Merah Premium',
                prefixIcon: Icon(Icons.local_florist_outlined,
                    color: AppColors.textLight),
              ),
            ),
            const SizedBox(height: 16),

            _label('Brand / Toko'),
            const SizedBox(height: 8),
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(
                hintText: 'cth: Bloom Florist',
                prefixIcon:
                    Icon(Icons.storefront_outlined, color: AppColors.textLight),
              ),
            ),
            const SizedBox(height: 16),

            _label('Harga *'),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'cth: Rp 45.000',
                prefixIcon:
                    Icon(Icons.payments_outlined, color: AppColors.textLight),
              ),
            ),
            const SizedBox(height: 16),

            _label('Rating (1.0 - 5.0) *'),
            const SizedBox(height: 8),
            TextField(
              controller: _ratingController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'cth: 4.5',
                prefixIcon: Icon(Icons.star_outline_rounded,
                    color: AppColors.textLight),
              ),
            ),
            const SizedBox(height: 8),

            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _ratingController,
              builder: (_, value, __) {
                final rating = double.tryParse(value.text) ?? 0.0;
                return Row(
                  children: List.generate(5, (index) {
                    if (rating >= 5.0) {
                      return const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC107), size: 20);
                    }
                    if (index < rating.floor()) {
                      return const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC107), size: 20);
                    } else if (index < rating) {
                      return const Icon(Icons.star_half_rounded,
                          color: Color(0xFFFFC107), size: 20);
                    } else {
                      return const Icon(Icons.star_outline_rounded,
                          color: Color(0xFFFFC107), size: 20);
                    }
                  }),
                );
              },
            ),
            const SizedBox(height: 16),

            _label('Deskripsi'),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Deskripsi bunga...',
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              label: _isSaving
                  ? 'Menyimpan...'
                  : (_isEdit ? 'Simpan Perubahan' : 'Tambah Produk'),
              onPressed: _isSaving ? null : _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_pickedFile != null) {
      if (kIsWeb) {
        return Image.network(_pickedFile!.path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder());
      } else {
        return Image.file(File(_pickedFile!.path), fit: BoxFit.cover);
      }
    }

    if (_imageController.text.isNotEmpty) {
      return Image.network(_imageController.text,
          fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder());
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_florist_outlined,
                color: AppColors.accent, size: 48),
            SizedBox(height: 8),
            Text('Ketuk untuk memilih gambar',
                style: TextStyle(color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textMedium),
      );
}