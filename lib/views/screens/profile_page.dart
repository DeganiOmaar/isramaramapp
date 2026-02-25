import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.user;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final roleLabel = user.role == 'client' ? 'Client' : user.role == 'fournisseur' ? 'Fournisseur' : 'Non défini';
    final roleColor = user.role == 'client' ? const Color(0xFF57C5B6) : user.role == 'fournisseur' ? const Color(0xFF1A5F7A) : Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            SizedBox(height: 24.h),
            CircleAvatar(
              radius: 48.r,
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              child: Text(
                (user.prenom?.substring(0, 1).toUpperCase() ?? user.email.substring(0, 1).toUpperCase()),
                style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
            ),
            SizedBox(height: 16.h),
            Text(user.displayName, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text(user.email, style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.badge_outlined, color: roleColor, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(roleLabel, style: TextStyle(fontWeight: FontWeight.w600, color: roleColor, fontSize: 14.sp)),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            _InfoTile(icon: Icons.person_outline, label: 'Nom', value: user.nom ?? '-'),
            _InfoTile(icon: Icons.person_outline, label: 'Prénom', value: user.prenom ?? '-'),
            if (user.role == 'fournisseur') ...[
              if (user.societeNom != null) _InfoTile(icon: Icons.business, label: 'Société', value: user.societeNom!),
              if (user.produitAVendre != null) _InfoTile(icon: Icons.inventory_2, label: 'Produit principal', value: user.produitAVendre!),
              if (user.descriptionActivite != null) _InfoTile(icon: Icons.description, label: 'Activité', value: user.descriptionActivite!),
            ],
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('Se déconnecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('Déconnexion')),
        ],
      ),
    );
    if (confirm == true) {
      await Get.find<AuthController>().logout();
    }
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 22.sp, color: Colors.grey.shade600),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
