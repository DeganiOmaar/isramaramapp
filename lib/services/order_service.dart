import '../models/order_model.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _api = ApiService();

  Future<List<OrderModel>> getMyOrders() async {
    final res = await _api.get('/orders/mes-commandes');
    final list = res['orders'] as List? ?? [];
    return list.map((e) => OrderModel.fromJson(_withId(e))).toList();
  }

  Future<List<OrderModel>> getReceivedOrders() async {
    final res = await _api.get('/orders/commandes-recues');
    final list = res['orders'] as List? ?? [];
    return list.map((e) => OrderModel.fromJson(_withId(e))).toList();
  }

  Future<void> createOrder(List<Map<String, dynamic>> items) async {
    await _api.post('/orders', {'items': items});
  }

  Future<void> acceptOrder(String orderId) async {
    await _api.put('/orders/$orderId/accepter', {});
  }

  Future<void> refuseOrder(String orderId) async {
    await _api.put('/orders/$orderId/refuser', {});
  }

  Map<String, dynamic> _withId(Map<String, dynamic> e) {
    final id = e['_id']?.toString() ?? e['id']?.toString() ?? '';
    return {'id': id, ...e};
  }
}
