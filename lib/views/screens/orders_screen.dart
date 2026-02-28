  import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

const _primary = Color(0xFF1A5F7A);

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<OrderModel> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = Get.find<AuthController>();
      final list = auth.isFournisseur
          ? await OrderService().getReceivedOrders()
          : await OrderService().getMyOrders();
      setState(() {
        _orders = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final title = auth.isFournisseur ? 'Commandes reçues' : 'Mes commandes';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 24.sp),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _primary),
            SizedBox(height: 16.h),
            Text('Chargement...', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: Colors.red.shade400),
              SizedBox(height: 16.h),
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp)),
              SizedBox(height: 16.h),
              FilledButton(
                onPressed: _loadOrders,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              Get.find<AuthController>().isFournisseur ? 'Aucune commande reçue' : 'Aucune commande',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: _orders.length,
        itemBuilder: (_, i) => Get.find<AuthController>().isFournisseur
            ? _SupplierOrderCard(order: _orders[i], onReload: _loadOrders)
            : _ClientOrderCard(order: _orders[i]),
      ),
    );
  }
}

class _ClientOrderCard extends StatelessWidget {
  final OrderModel order;

  const _ClientOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (order.status) {
      case 'nouvelle':
        statusColor = Colors.orange;
        break;
      case 'pending':
        statusColor = Colors.green;
        break;
      case 'refusee':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commande #${order.id.length > 8 ? order.id.substring(order.id.length - 8) : order.id}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  order.statusDisplay,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: statusColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...order.items.map((i) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${i.productNom} × ${i.quantite}',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text('${i.sousTotal.toStringAsFixed(0)} TND', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
                  ],
                ),
              )),
          Divider(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              Text('${order.montantTotalTND.toStringAsFixed(0)} TND', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupplierOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onReload;

  const _SupplierOrderCard({required this.order, required this.onReload});

  @override
  Widget build(BuildContext context) {
    final isNouvelle = order.status == 'nouvelle';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.clientPrenom ?? ''} ${order.clientNom ?? ''}'.trim(),
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isNouvelle
                      ? Colors.orange.withValues(alpha: 0.15)
                      : order.status == 'pending'
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  order.statusDisplay,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...order.items.map((i) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${i.productNom} × ${i.quantite}',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    Text('${i.sousTotal.toStringAsFixed(0)} TND'),
                  ],
                ),
              )),
          Divider(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              Text('${order.montantTotalTND.toStringAsFixed(0)} TND', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primary)),
            ],
          ),
          if (isNouvelle) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _refuse(order.id),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Refuser'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _accept(order.id),
                    style: FilledButton.styleFrom(backgroundColor: _primary),
                    child: const Text('Accepter'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _accept(String orderId) async {
    try {
      await OrderService().acceptOrder(orderId);
      Get.snackbar('Succès', 'Commande acceptée - Le client verra le statut "En cours"', 
      backgroundColor: Colors.green,
      colorText: Colors.black87
      );
      onReload();
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }

  Future<void> _refuse(String orderId) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Refuser la commande'),
        content: const Text('Voulez-vous vraiment refuser cette commande ?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await OrderService().refuseOrder(orderId);
      Get.snackbar('Info', 'Commande refusée',
      backgroundColor: Colors.red, 
      colorText: Colors.white
      );
      onReload();
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }
}
