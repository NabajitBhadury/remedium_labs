import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loader_provider.dart';
import '../../providers/lab_test_provider.dart';
import '../../theme/app_theme.dart';

import '../../models/disease.dart';
import '../../models/organ.dart';
import '../../models/banner_model.dart';
import '../../services/mock_data_service.dart';
import '../../models/service.dart';
import 'all_diseases_screen.dart';
import 'all_organs_screen.dart';
import 'disease_services_screen.dart';
import 'service_details_screen.dart';

import 'organ_services_screen.dart';
import 'collect_sample_screen.dart';
import 'book_test_screen.dart';
import 'rate_chart_screen.dart';
import 'track_report_screen.dart';
import 'download_report_screen.dart';
import 'report_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MockDataService _dataService = MockDataService();
  List<Organ> _organs = [];
  List<Disease> _diseases = [];
  List<BannerModel> _banners = [];

  int _currentBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoaderProvider>().showLoader();
    });

    final organs = await _dataService.getOrgans(); // Fetch organs
    final diseases = await _dataService.getDiseases();
    final banners = await _dataService.getBanners();

    if (mounted) {
      context.read<LoaderProvider>().hideLoader();
      setState(() {
        _organs = organs;
        _diseases = diseases;
        _banners = banners;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildAppBar(context, auth),
                  const SizedBox(height: 24),
                  if (!auth.isAuthenticated) ...[
                    _buildSearchField(context),
                    const SizedBox(height: 24),
                  ],
                  _buildBanners(context),
                  const SizedBox(height: 32),

                  _buildQuickActions(context),
                  const SizedBox(height: 32),

                  _buildSectionHeader(context, "Specific Test", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllOrgansScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildOrganSelector(context),
                  const SizedBox(height: 32),

                  _buildSectionHeader(context, "Popular Tests", () {
                    // TODO: See all tests
                  }),
                  const SizedBox(height: 16),
                  _buildPopularServicesList(context),
                  const SizedBox(height: 32),

                  _buildSectionHeader(context, "Find by Disease", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllDiseasesScreen(),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildDiseaseSelector(context),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AuthProvider auth) {
    if (auth.isAuthenticated) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                auth.userName?[0].toUpperCase() ?? "U",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search for tests...",
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.tune,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppTheme.textPrimary,
                size: 24,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ).animate().fadeIn().slideX();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryColor, width: 2),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage: null,
                child: const Icon(Icons.person, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Welcome Guest",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.waving_hand,
                      size: 16,
                      color: Colors.amber.shade600,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.locationDot,
                      size: 10,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "New York, USA",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          width: 48,
        ), // Spacer to balance layout or just remove to align right
      ],
    ).animate().fadeIn().slideX();
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search for tests, labs...",
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.tune, size: 20, color: AppTheme.primaryColor),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildBanners(BuildContext context) {
    if (_banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: banner.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: banner.gradientColors.first.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Opacity(
                          opacity: 0.9,
                          child: Image.network(
                            banner.imageUrl,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                FontAwesomeIcons.flask,
                                size: 120,
                                color: Colors.white.withOpacity(0.2),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Limited Time Offer",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            banner.title,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            banner.subtitle,
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: banner.buttonColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              banner.buttonText,
                              style: GoogleFonts.outfit(
                                color: banner.buttonTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? AppTheme.primaryColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                title: "Collect My\nSample",
                icon: Icons.science_outlined,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectSampleScreen())),
                delay: 200,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                title: "Book A\nTest",
                icon: Icons.calendar_month_outlined,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookTestScreen())),
                delay: 300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                title: "Rate\nChart",
                icon: Icons.bar_chart_outlined,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RateChartScreen())),
                delay: 400,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                context,
                title: "Track Your\nReport",
                icon: Icons.location_on_outlined,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackReportScreen())),
                delay: 500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFullWidthAction(
          context,
          title: "Download My Report",
          icon: Icons.download_outlined,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DownloadReportScreen())),
          delay: 600,
        ),
        const SizedBox(height: 12),
        _buildFullWidthAction(
          context,
          title: "My Report History",
          icon: Icons.history_outlined,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportHistoryScreen())),
          delay: 700,
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap, required int delay}) {
    return Container(
      height: 140, // Increased height to prevent overflow
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16), // Adjusted horizontal padding to fit text better
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 28),
                ),
                const Spacer(), // Used a Spacer instead of rigid SizedBox
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2, // Ensure it doesn't wrap more than expected
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1);
  }

  Widget _buildFullWidthAction(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap, required int delay}) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1);
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeMore,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onSeeMore,
          style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
          child: const Text("See All"),
        ),
      ],
    );
  }

  Widget _buildPopularServicesList(BuildContext context) {
    final provider = context.watch<LabTestProvider>();
    if (provider.isLoading && provider.tests.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(),
      ));
    }

    final popularTests = provider.tests.where((t) => t.status.toLowerCase() == 'active').take(5).toList();

    if (popularTests.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: popularTests.length,
      itemBuilder: (context, index) {
        final test = popularTests[index];
        final service = Service(
          id: test.id.toString(),
          name: test.name,
          price: test.mrp,
          durationMinutes: 30, // Default duration
          description: 'Sample Type: ${test.sampleType}',
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailsScreen(service: service),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.science_outlined,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${service.price.toStringAsFixed(0)} • ${service.durationMinutes} mins",
                            style: GoogleFonts.inter(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (service.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              service.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: (50 * index).ms).slideX();
      },
    );
  }

  Widget _buildOrganSelector(BuildContext context) {
    if (_organs.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _organs.length,
        itemBuilder: (context, index) {
          final organ = _organs[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrganServicesScreen(organ: organ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        organ.icon,
                        color: organ.color.withOpacity(0.8),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    organ.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 500.ms).slideX();
  }

  Widget _buildDiseaseSelector(BuildContext context) {
    if (_diseases.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _diseases.length,
        itemBuilder: (context, index) {
          final disease = _diseases[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DiseaseServicesScreen(disease: disease),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(disease.icon, color: disease.color, size: 28),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    disease.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 600.ms).slideX();
  }
}
