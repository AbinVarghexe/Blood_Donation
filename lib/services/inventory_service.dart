import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blood_inventory.dart';
import '../services/notification_service.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final String _collection = 'blood_inventory';

  // Create a new blood inventory entry
  Future<BloodInventory> createInventory(BloodInventory inventory) async {
    final docRef =
        await _firestore.collection(_collection).add(inventory.toFirestore());
    final doc = await docRef.get();
    return BloodInventory.fromFirestore(doc);
  }

  // Get inventory by ID
  Future<BloodInventory?> getInventory(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return BloodInventory.fromFirestore(doc);
  }

  // Update inventory
  Future<void> updateInventory(String id, Map<String, dynamic> data) async {
    await _firestore.collection(_collection).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete inventory
  Future<void> deleteInventory(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // Get all inventory for a hospital
  Stream<List<BloodInventory>> getHospitalInventory(String hospitalId) {
    return _firestore
        .collection(_collection)
        .where('hospitalId', isEqualTo: hospitalId)
        .where('isActive', isEqualTo: true)
        .orderBy('bloodGroup')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BloodInventory.fromFirestore(doc))
            .toList());
  }

  // Get inventory by blood group
  Stream<List<BloodInventory>> getInventoryByBloodGroup(String bloodGroup) {
    return _firestore
        .collection(_collection)
        .where('bloodGroup', isEqualTo: bloodGroup)
        .where('isActive', isEqualTo: true)
        .orderBy('units', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BloodInventory.fromFirestore(doc))
            .toList());
  }

  // Update blood units
  Future<void> updateUnits(String id, int units, String updatedBy) async {
    final inventory = await getInventory(id);
    if (inventory == null) return;

    final newUnits = inventory.units + units;
    if (newUnits < 0) throw Exception('Cannot have negative units');

    await updateInventory(id, {
      'units': newUnits,
      'lastUpdated': FieldValue.serverTimestamp(),
      'lastUpdatedBy': updatedBy,
    }); // Check if stock is critical and notify if necessary
    if (newUnits <= inventory.criticalLevel) {
      await _notificationService.createInventoryAlert(
        userId: inventory.hospitalId,
        bloodType: inventory.bloodGroup,
        title: 'Critical Blood Inventory Alert',
        message:
            'Blood inventory for ${inventory.bloodGroup} at ${inventory.hospitalName} is critically low ($newUnits units remaining)',
        data: {
          'hospitalId': inventory.hospitalId,
          'hospitalName': inventory.hospitalName,
          'bloodGroup': inventory.bloodGroup,
          'currentUnits': newUnits,
          'criticalLevel': inventory.criticalLevel,
        },
      );
    }
  }

  // Get critical inventory
  Stream<List<BloodInventory>> getCriticalInventory() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BloodInventory.fromFirestore(doc))
            .where((inventory) => inventory.isCritical)
            .toList());
  }

  // Get inventory needing restock
  Stream<List<BloodInventory>> getInventoryNeedingRestock() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BloodInventory.fromFirestore(doc))
            .where((inventory) => inventory.needsRestock)
            .toList());
  }

  // Get total available units by blood group
  Future<Map<String, int>> getTotalAvailableUnits() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .get();

    final Map<String, int> totals = {};
    for (var doc in snapshot.docs) {
      final inventory = BloodInventory.fromFirestore(doc);
      totals[inventory.bloodGroup] =
          (totals[inventory.bloodGroup] ?? 0) + inventory.units;
    }
    return totals;
  }

  // Get inventory history
  Stream<List<BloodInventory>> getInventoryHistory(String hospitalId) {
    return _firestore
        .collection(_collection)
        .where('hospitalId', isEqualTo: hospitalId)
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BloodInventory.fromFirestore(doc))
            .toList());
  }
}
