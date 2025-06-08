import 'package:flutter/material.dart';
import '../../models/blood_inventory.dart';
import '../../services/inventory_service.dart';
import '../../services/auth_service.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  _InventoryManagementScreenState createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final InventoryService _inventoryService = InventoryService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddInventoryDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<BloodInventory>>(
        stream: _inventoryService
            .getHospitalInventory(_authService.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final inventory = snapshot.data!;
          if (inventory.isEmpty) {
            return const Center(
              child: Text('No inventory found. Add some blood units.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: inventory.length,
            itemBuilder: (context, index) {
              final item = inventory[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getBloodGroupColor(item.bloodGroup),
                    child: Text(
                      item.bloodGroup,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('${item.bloodGroup} - ${item.units} units'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last updated: ${_formatDate(item.lastUpdated)}'),
                      LinearProgressIndicator(
                        value: item.stockLevelPercentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          item.isCritical ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () =>
                            _showUpdateUnitsDialog(context, item, true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () =>
                            _showUpdateUnitsDialog(context, item, false),
                      ),
                    ],
                  ),
                  onTap: () => _showInventoryDetails(context, item),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getBloodGroupColor(String bloodGroup) {
    switch (bloodGroup) {
      case 'A+':
        return Colors.red;
      case 'A-':
        return Colors.red[300]!;
      case 'B+':
        return Colors.blue;
      case 'B-':
        return Colors.blue[300]!;
      case 'AB+':
        return Colors.purple;
      case 'AB-':
        return Colors.purple[300]!;
      case 'O+':
        return Colors.green;
      case 'O-':
        return Colors.green[300]!;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  Future<void> _showAddInventoryDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String bloodGroup = 'A+';
    int units = 0;
    int criticalLevel = 5;
    int optimalLevel = 20;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Blood Inventory'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: bloodGroup,
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((group) => DropdownMenuItem(
                          value: group,
                          child: Text(group),
                        ))
                    .toList(),
                onChanged: (value) => bloodGroup = value!,
                decoration: const InputDecoration(labelText: 'Blood Group'),
              ),
              TextFormField(
                initialValue: '0',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Units'),
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) => units = int.parse(value),
              ),
              TextFormField(
                initialValue: '5',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Critical Level'),
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) => criticalLevel = int.parse(value),
              ),
              TextFormField(
                initialValue: '20',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Optimal Level'),
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) => optimalLevel = int.parse(value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                setState(() => _isLoading = true);
                try {
                  final inventory = BloodInventory(
                    id: '',
                    hospitalId: _authService.currentUser!.uid,
                    hospitalName: _authService.currentUser!.displayName ??
                        'Unknown Hospital',
                    bloodGroup: bloodGroup,
                    units: units,
                    criticalLevel: criticalLevel,
                    optimalLevel: optimalLevel,
                    lastUpdated: DateTime.now(),
                    lastUpdatedBy: _authService.currentUser!.uid,
                    isActive: true,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await _inventoryService.createInventory(inventory);
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                } finally {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateUnitsDialog(
    BuildContext context,
    BloodInventory inventory,
    bool isAdding,
  ) async {
    final formKey = GlobalKey<FormState>();
    int units = 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAdding ? 'Add Units' : 'Remove Units'),
        content: Form(
          key: formKey,
          child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Units'),
            validator: (value) {
              if (value == null || int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onChanged: (value) => units = int.parse(value),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                setState(() => _isLoading = true);
                try {
                  await _inventoryService.updateUnits(
                    inventory.id,
                    isAdding ? units : -units,
                    _authService.currentUser!.uid,
                  );
                  if (mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                } finally {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: Text(isAdding ? 'Add' : 'Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _showInventoryDetails(
      BuildContext context, BloodInventory inventory) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${inventory.bloodGroup} Inventory Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Units: ${inventory.units}'),
            Text('Critical Level: ${inventory.criticalLevel}'),
            Text('Optimal Level: ${inventory.optimalLevel}'),
            Text('Last Updated: ${_formatDate(inventory.lastUpdated)}'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: inventory.stockLevelPercentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                inventory.isCritical ? Colors.red : Colors.green,
              ),
            ),
            if (inventory.isCritical)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ Critical Level Reached',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
