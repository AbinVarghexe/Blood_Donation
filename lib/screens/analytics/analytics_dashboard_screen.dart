import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/analytics.dart';
import '../../services/analytics_service.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  _AnalyticsDashboardScreenState createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isLoading = true;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedType = 'donation';
  Map<String, dynamic>? _analyticsData;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final data = await _analyticsService.getComprehensiveReport();
      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showDateRangePicker,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analyticsData == null
              ? const Center(child: Text('No data available'))
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTypeSelector(),
                        const SizedBox(height: 24),
                        if (_selectedType == 'donation') ...[
                          _buildDonationStats(),
                          const SizedBox(height: 24),
                          _buildDonationAnalytics(),
                        ] else ...[
                          _buildInventoryAnalytics(),
                        ],
                        const SizedBox(height: 24),
                        _buildEmergencyStats(),
                        const SizedBox(height: 24),
                        _buildUserEngagementStats(),
                        const SizedBox(height: 24),
                        _buildLocationStats(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDonationStats() {
    final stats = _analyticsData!['donationStats'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donation Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Donors',
                  stats['totalDonors'].toString(),
                  Icons.people,
                ),
                _buildStatItem(
                  'Eligible Donors',
                  stats['eligibleDonors'].toString(),
                  Icons.check_circle,
                ),
                _buildStatItem(
                  'Total Donations',
                  stats['totalDonations'].toString(),
                  Icons.favorite,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections:
                      _buildBloodGroupSections(stats['bloodGroupDistribution']),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyStats() {
    final stats = _analyticsData!['emergencyStats'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Request Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Requests',
                  stats['totalRequests'].toString(),
                  Icons.emergency,
                ),
                _buildStatItem(
                  'Fulfilled',
                  stats['fulfilledRequests'].toString(),
                  Icons.check_circle,
                ),
                _buildStatItem(
                  'Urgent',
                  stats['urgentRequests'].toString(),
                  Icons.priority_high,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: stats['totalRequests'].toDouble(),
                  barGroups: _buildStatusBars(stats['statusDistribution']),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserEngagementStats() {
    final stats = _analyticsData!['userEngagementStats'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Engagement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Feedback',
                  stats['totalFeedbacks'].toString(),
                  Icons.feedback,
                ),
                _buildStatItem(
                  'Avg Rating',
                  stats['averageRating'].toStringAsFixed(1),
                  Icons.star,
                ),
                _buildStatItem(
                  'Response Rate',
                  '${(stats['responseRate'] * 100).toStringAsFixed(1)}%',
                  Icons.reply,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStats() {
    final stats = _analyticsData!['locationStats'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Distribution',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              'Donors with Location',
              stats['totalWithLocation'].toString(),
              Icons.location_on,
            ),
            // TODO: Add map visualization
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildBloodGroupSections(
      Map<String, int> distribution) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];

    return distribution.entries.map((entry) {
      final index = distribution.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        color: colors[index % colors.length],
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildStatusBars(Map<String, int> distribution) {
    return distribution.entries.map((entry) {
      return BarChartGroupData(
        x: distribution.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildTypeSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'donation',
          label: Text('Donations'),
          icon: Icon(Icons.bloodtype),
        ),
        ButtonSegment(
          value: 'inventory',
          label: Text('Inventory'),
          icon: Icon(Icons.inventory),
        ),
      ],
      selected: {_selectedType},
      onSelectionChanged: (Set<String> selection) {
        setState(() => _selectedType = selection.first);
      },
    );
  }

  Widget _buildDonationAnalytics() {
    return FutureBuilder<DonationAnalytics>(
      future: _analyticsService.generateDonationAnalytics(
        startDate: _startDate,
        endDate: _endDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final analytics = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(analytics),
            const SizedBox(height: 24),
            _buildBloodGroupChart(analytics),
            const SizedBox(height: 24),
            _buildLocationChart(analytics),
            const SizedBox(height: 24),
            _buildMonthlyTrendChart(analytics),
          ],
        );
      },
    );
  }

  Widget _buildInventoryAnalytics() {
    return FutureBuilder<InventoryAnalytics>(
      future: _analyticsService.generateInventoryAnalytics(
        startDate: _startDate,
        endDate: _endDate,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final analytics = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInventorySummaryCards(analytics),
            const SizedBox(height: 24),
            _buildStockLevelChart(analytics),
            const SizedBox(height: 24),
            _buildCriticalLevelsChart(analytics),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCards(DonationAnalytics analytics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Donations',
          analytics.totalDonations.toString(),
          Icons.bloodtype,
          Colors.red,
        ),
        _buildSummaryCard(
          'Active Donors',
          analytics.activeDonors.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildSummaryCard(
          'New Donors',
          analytics.newDonors.toString(),
          Icons.person_add,
          Colors.green,
        ),
        _buildSummaryCard(
          'Avg. Frequency',
          analytics.averageDonationFrequency.toStringAsFixed(1),
          Icons.timeline,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildInventorySummaryCards(InventoryAnalytics analytics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Hospitals',
          analytics.totalHospitals.toString(),
          Icons.local_hospital,
          Colors.red,
        ),
        _buildSummaryCard(
          'Avg. Stock Level',
          '${(analytics.averageStockLevel * 100).toStringAsFixed(1)}%',
          Icons.inventory,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Critical Levels',
          analytics.criticalLevels.values.reduce((a, b) => a + b).toString(),
          Icons.warning,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Optimal Levels',
          analytics.optimalLevels.values.reduce((a, b) => a + b).toString(),
          Icons.check_circle,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodGroupChart(DonationAnalytics analytics) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donations by Blood Group',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _createBloodGroupSections(analytics),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createBloodGroupSections(
      DonationAnalytics analytics) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return analytics.donationsByBloodGroup.entries.map((entry) {
      final index =
          analytics.donationsByBloodGroup.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key}\n${entry.value}',
        color: colors[index % colors.length],
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLocationChart(DonationAnalytics analytics) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donations by Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: analytics.donationsByLocation.values
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble(),
                  barGroups: _createLocationBarGroups(analytics),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final locations =
                              analytics.donationsByLocation.keys.toList();
                          if (value >= 0 && value < locations.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                locations[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _createLocationBarGroups(
      DonationAnalytics analytics) {
    return List.generate(
      analytics.donationsByLocation.length,
      (index) {
        final location = analytics.donationsByLocation.keys.elementAt(index);
        final value = analytics.donationsByLocation[location]!;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              color: Colors.blue,
              width: 20,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyTrendChart(DonationAnalytics analytics) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Donation Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final months =
                              analytics.donationsByMonth.keys.toList();
                          if (value >= 0 && value < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                months[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _createMonthlySpots(analytics),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _createMonthlySpots(DonationAnalytics analytics) {
    return List.generate(
      analytics.donationsByMonth.length,
      (index) {
        final month = analytics.donationsByMonth.keys.elementAt(index);
        final value = analytics.donationsByMonth[month]!;
        return FlSpot(index.toDouble(), value.toDouble());
      },
    );
  }

  Widget _buildStockLevelChart(InventoryAnalytics analytics) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Stock Levels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: analytics.currentStock.values
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble(),
                  barGroups: _createStockLevelBarGroups(analytics),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final bloodGroups =
                              analytics.currentStock.keys.toList();
                          if (value >= 0 && value < bloodGroups.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                bloodGroups[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _createStockLevelBarGroups(
      InventoryAnalytics analytics) {
    return List.generate(
      analytics.currentStock.length,
      (index) {
        final bloodGroup = analytics.currentStock.keys.elementAt(index);
        final value = analytics.currentStock[bloodGroup]!;
        final criticalLevel = analytics.criticalLevels[bloodGroup]!;
        final optimalLevel = analytics.optimalLevels[bloodGroup]!;

        Color barColor;
        if (value <= criticalLevel) {
          barColor = Colors.red;
        } else if (value >= optimalLevel) {
          barColor = Colors.green;
        } else {
          barColor = Colors.orange;
        }

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              color: barColor,
              width: 20,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCriticalLevelsChart(InventoryAnalytics analytics) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Critical vs Optimal Levels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: analytics.optimalLevels.values
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble(),
                  barGroups: _createCriticalLevelsBarGroups(analytics),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final bloodGroups =
                              analytics.criticalLevels.keys.toList();
                          if (value >= 0 && value < bloodGroups.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                bloodGroups[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _createCriticalLevelsBarGroups(
      InventoryAnalytics analytics) {
    return List.generate(
      analytics.criticalLevels.length,
      (index) {
        final bloodGroup = analytics.criticalLevels.keys.elementAt(index);
        final criticalLevel = analytics.criticalLevels[bloodGroup]!;
        final optimalLevel = analytics.optimalLevels[bloodGroup]!;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: criticalLevel.toDouble(),
              color: Colors.red,
              width: 10,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            BarChartRodData(
              toY: optimalLevel.toDouble(),
              color: Colors.green,
              width: 10,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
}
