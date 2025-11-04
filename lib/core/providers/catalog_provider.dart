import 'package:flutter/foundation.dart';
import '../models/cake.dart';
import '../services/cake_service.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogProvider(this._cakeService);

  final CakeService _cakeService;
  List<Cake> cakes = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchCakes() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      cakes = await _cakeService.listCakes();
    } catch (e) {
      error = 'Failed to load cakes';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}


