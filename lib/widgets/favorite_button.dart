import 'package:flutter/material.dart';
import '../utils/local_storage_service.dart';

class FavoriteButton extends StatefulWidget {
  final String itemId;
  final Function(bool isFavorite)? onFavoriteChanged;

  const FavoriteButton({
    super.key,
    required this.itemId,
    this.onFavoriteChanged,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemId != oldWidget.itemId) {
      _checkIfFavorite();
    }
  }

  Future<void> _checkIfFavorite() async {
    bool favoriteStatus = await _localStorageService.isPhoneFavorite(
      widget.itemId,
    );
    if (mounted) {
      setState(() {
        _isFavorite = favoriteStatus;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    bool newFavoriteStatus;
    if (_isFavorite) {
      await _localStorageService.removeFavoritePhone(widget.itemId);
      newFavoriteStatus = false;
    } else {
      await _localStorageService.addFavoritePhone(widget.itemId);
      newFavoriteStatus = true;
    }
    if (mounted) {
      setState(() {
        _isFavorite = newFavoriteStatus;
      });
      widget.onFavoriteChanged?.call(newFavoriteStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_outlined,
        color: _isFavorite ? Colors.pinkAccent.shade400 : Colors.grey.shade700,
        size: 28,
      ),
      onPressed: _toggleFavorite,
      tooltip: _isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
    );
  }
}
