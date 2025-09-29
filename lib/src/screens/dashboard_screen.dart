import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:harvestor/theme/app_colors.dart';
import 'package:harvestor/theme/app_text_styles.dart';
import 'package:harvestor/theme/app_theme.dart';
import '../../widgets/metric_card_enhanced.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_indicator.dart';
import '../../providers/dashboard_provider.dart';
import '../state/app_state.dart';
import 'package:harvestor/utils/constants.dart' hide AppColors;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadInitialData();
    _initializeProvider();
  }

  void _initializeProvider() {
    // Get device ID from app state and set it in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      context.read<DashboardProvider>().setDeviceId(appState.harvesterId);
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _loadInitialData() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          // Data will be loaded by provider
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DashboardProvider(),
      child: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildEnhancedAppBar(provider),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildOneTeamOneMissionBanner(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildActionButtonsSection(),
                            const SizedBox(height: 20),
                            _buildMetricsSection(),
                            const SizedBox(height: 20),
                            _buildAlertsSection(),
                            const SizedBox(height: 32), // Extra bottom padding for FAB
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: _buildNotificationFab(),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  Widget _buildOneTeamOneMissionBanner() {
    return GestureDetector(
      onTap: () => _showTeamDetails(),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1976D2), // Blue
              Color(0xFF42A5F5), // Light blue
              Color(0xFF64B5F6), // Lighter blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Animated pulse indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.7),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(
                    0.4 + 0.6 * (0.5 + 0.5 * _getPulseValue()),
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ONE TEAM ONE MISSION',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All systems operational • Ready for harvest',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getPulseValue() {
    return (DateTime.now().millisecondsSinceEpoch % 3000) / 3000.0;
  }

  void _showTeamDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Team Status Details',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatusItem('System Status', 'All systems operational', Icons.check_circle, Colors.blue),
            _buildStatusItem('Network', 'Connected ', Icons.wifi, Colors.blue),
            _buildStatusItem('Sensors', 'All sensors active', Icons.sensors, Colors.blue),
            _buildStatusItem('Last Sync', '2 minutes ago', Icons.sync, Colors.orange),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(DashboardProvider provider) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 4,
      shadowColor: AppColors.primary.withOpacity(0.3),
      title: Row(
        children: [
          AnimatedStatusIndicator(
            isOnline: provider.systemStatus['firebase'] ?? false,
            size: 12,
          ),
        ],
      ),
      actions: [],
    );
  }

  Widget _buildActionButtonsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border.withOpacity(0.3), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.02),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.settings,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Control Panel',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildEnhancedControlButton(
                  label: 'Pause Alerts',
                  icon: Icons.notifications_paused,
                  color: AppColors.warning,
                  description: 'Temporarily pause all alerts',
                  onPressed: () => _showActionDialog('Pause Alerts',
                      'This will temporarily pause all alerts. Continue?'),
                ),
                _buildEnhancedControlButton(
                  label: '3D Visualizer',
                  icon: Icons.view_in_ar,
                  color: AppColors.info,
                  description: 'Open 3D harvester model',
                  onPressed: () => _showActionDialog(
                      '3D Visualizer', 'Open 3D harvester visualization'),
                ),
                _buildEnhancedControlButton(
                  label: 'System Reset',
                  icon: Icons.restart_alt,
                  color: AppColors.success,
                  description: 'Reset all systems',
                  onPressed: () => _showActionDialog('System Reset',
                      'This will reset all harvester systems. Continue?'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedControlButton({
    required String label,
    required IconData icon,
    required Color color,
    required String description,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 2,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.05),
                  color.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Metrics',
          style: AppTextStyles.cardTitle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                _buildGrainTankCard(provider),
                _buildPtoRpmCard(provider),
                _buildTemperatureCard(provider),
                _buildFuelLevelCard(provider),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGrainTankCard(DashboardProvider provider) {
    return MetricCardEnhanced(
      title: 'Grain Tank',
      value: provider.getMetricValue('grainTank'),
      unit: provider.getMetricUnit('grainTank'),
      icon: Icons.grain,
      progressValue: provider.getMetricProgress('grainTank') * 100,
      maxValue: 100,
      color: provider.getMetricColor('grainTank'),
      isGood: true,
      lastUpdated: provider.getLastUpdated(),
    );
  }

  Widget _buildPtoRpmCard(DashboardProvider provider) {
    return MetricCardEnhanced(
      title: 'PTO RPM',
      value: provider.getMetricValue('ptoRpm'),
      unit: provider.getMetricUnit('ptoRpm'),
      icon: Icons.speed,
      progressValue: provider.getMetricProgress('ptoRpm') * 1000,
      maxValue: 1000,
      color: provider.getMetricColor('ptoRpm'),
      isGood: true,
      showGauge: true,
      lastUpdated: provider.getLastUpdated(),
    );
  }

  Widget _buildTemperatureCard(DashboardProvider provider) {
    return MetricCardEnhanced(
      title: 'Engine Temp',
      value: provider.getMetricValue('engineTemp'),
      unit: provider.getMetricUnit('engineTemp'),
      icon: Icons.thermostat,
      progressValue: provider.getMetricProgress('engineTemp') * 120,
      maxValue: 120,
      color: provider.getMetricColor('engineTemp'),
      isGood: true,
      lastUpdated: provider.getLastUpdated(),
    );
  }

  Widget _buildFuelLevelCard(DashboardProvider provider) {
    return MetricCardEnhanced(
      title: 'Fuel Level',
      value: provider.getMetricValue('fuelLevel'),
      unit: provider.getMetricUnit('fuelLevel'),
      icon: Icons.local_gas_station,
      progressValue: provider.getMetricProgress('fuelLevel') * 100,
      maxValue: 100,
      color: provider.getMetricColor('fuelLevel'),
      isGood: true,
      lastUpdated: provider.getLastUpdated(),
    );
  }

  Widget _buildAlertsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.border.withOpacity(0.3), width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppColors.background.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        color: AppColors.warning,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Alerts & Notifications',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildAlertsFilterButton(),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showAlertsModal(),
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: const Text('View All'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAlertsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsFilterButton() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // Handle filter selection
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Filter: $value'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'all',
          child: Text('All Alerts'),
        ),
        const PopupMenuItem(
          value: 'critical',
          child: Row(
            children: [
              Icon(Icons.error, color: AppColors.error, size: 16),
              SizedBox(width: 8),
              Text('Critical'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'warning',
          child: Row(
            children: [
              Icon(Icons.warning, color: AppColors.warning, size: 16),
              SizedBox(width: 8),
              Text('Warnings'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'info',
          child: Row(
            children: [
              Icon(Icons.info, color: AppColors.info, size: 16),
              SizedBox(width: 8),
              Text('Info'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.filter_list,
              color: AppColors.primary,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Filter',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsList() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.alerts.isEmpty) {
          return _buildNoAlertsView();
        }
        return Column(
          children: provider.alerts
              .map<Widget>(
                  (alert) => ExpandableAlertCard(alert: alert as AlertItem))
              .toList(),
        );
      },
    );
  }

  Widget _buildNoAlertsView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 56,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No recent alerts',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Everything is running smoothly',
            style: AppTextStyles.bodyMedium.withColor(AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationFab() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final unreadCount = provider.unreadAlertsCount;
        return FloatingActionButton(
          onPressed: () {
            provider.markAllAlertsAsRead();
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          hoverElevation: 8,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications, size: 28),
              if (unreadCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAlertsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Alerts',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            _buildSoundToggle(),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAlertsModalFilters(),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildAlertsModalList(),
                    const SizedBox(height: 20),
                    _buildAlertsSummary(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.volume_up,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Sound On',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsModalFilters() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', true),
                  _buildFilterChip('Critical', false),
                  _buildFilterChip('Warning', false),
                  _buildFilterChip('Info', false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {},
        backgroundColor: Colors.white.withOpacity(0.2),
        selectedColor: Colors.white,
        checkmarkColor: AppColors.primary,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: isSelected ? AppColors.primary : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAlertsModalList() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.alerts.isEmpty) {
          return _buildNoAlertsView();
        }

        return Column(
          children: provider.alerts.map<Widget>((alert) {
            final alertItem = alert as AlertItem;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _getAlertBackgroundColor(alertItem.severity),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getAlertBorderColor(alertItem.severity),
                  width: 1,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getAlertIconBackgroundColor(alertItem.severity),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getAlertIcon(alertItem.severity),
                    color: _getAlertIconColor(alertItem.severity),
                    size: 20,
                  ),
                ),
                title: Text(
                  alertItem.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alertItem.message,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(alertItem.timestamp),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => _acknowledgeAlert(alertItem),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('ACK'),
                    ),
                    TextButton(
                      onPressed: () => _dismissAlert(alertItem),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('DISMISS'),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAlertsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryStat('Total Alerts', '12', Icons.notifications),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildSummaryStat('Active', '3', Icons.warning, color: AppColors.warning),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildSummaryStat('Acknowledged', '9', Icons.check_circle, color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? AppColors.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.primary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getAlertBackgroundColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.error.withOpacity(0.1);
      case AlertSeverity.warning:
        return AppColors.warning.withOpacity(0.1);
      case AlertSeverity.error:
        return AppColors.error.withOpacity(0.1);
      case AlertSeverity.info:
        return AppColors.info.withOpacity(0.1);
    }
  }

  Color _getAlertBorderColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.error.withOpacity(0.3);
      case AlertSeverity.warning:
        return AppColors.warning.withOpacity(0.3);
      case AlertSeverity.error:
        return AppColors.error.withOpacity(0.3);
      case AlertSeverity.info:
        return AppColors.info.withOpacity(0.3);
    }
  }

  Color _getAlertIconBackgroundColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.error.withOpacity(0.2);
      case AlertSeverity.warning:
        return AppColors.warning.withOpacity(0.2);
      case AlertSeverity.error:
        return AppColors.error.withOpacity(0.2);
      case AlertSeverity.info:
        return AppColors.info.withOpacity(0.2);
    }
  }

  Color _getAlertIconColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.error;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.error:
        return AppColors.error;
      case AlertSeverity.info:
        return AppColors.info;
    }
  }

  IconData _getAlertIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return Icons.error;
      case AlertSeverity.warning:
        return Icons.warning;
      case AlertSeverity.error:
        return Icons.error;
      case AlertSeverity.info:
        return Icons.info;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _acknowledgeAlert(AlertItem alert) {
    // Handle alert acknowledgment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alert acknowledged: ${alert.title}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _dismissAlert(AlertItem alert) {
    // Handle alert dismissal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alert dismissed: ${alert.title}'),
        backgroundColor: AppColors.textSecondary,
      ),
    );
  }

  void _showActionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTextStyles.heading4),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
