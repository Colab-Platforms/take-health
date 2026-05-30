import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ClinicalPage extends StatelessWidget {
  const ClinicalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFE6EBE0),
      ),
      home: const ClinicalSynthesisScreen(),
    );
  }
}

// ─────────────────── COLOR TOKENS ───────────────────
const kBg         = Color(0xFFE6EBE0);
const kCard       = Color(0xFFFFFFFF);
const kInk        = Color(0xFF10241C);
const kInkSoft    = Color(0xFF3B5046);
const kMuted      = Color(0xFF7C8F84);
const kGreen      = Color(0xFF1F9D63);
const kGreenDeep  = Color(0xFF147A4B);
const kGreenTint  = Color(0xFFD9EAD9);
const kNavy       = Color(0xFF0F2030);
const kShadow     = Color(0x28143C28);
const kRed        = Color(0xFFD32F2F);
const kRedTint    = Color(0xFFFFEBEE);
const kOrange     = Color(0xFFF57C00);
const kOrangeTint = Color(0xFFFFF3E0);
const kPurple     = Color(0xFF5C6BC0);
const kPurpleTint = Color(0xFFEDE7F6);
const kRecsGreen  = Color(0xFF5E8A72);
const kRecsItem   = Color(0xFF3D6050);

// ═══════════════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════════════
class Biomarker {
  final String name;
  final String status; // 'NORMAL', 'BORDERLINE', 'HIGH', 'CRITICAL'
  final String value;
  final String target;
  final String unit;
  final String? prescription;
  final String? dose;

  Biomarker({
    required this.name,
    required this.status,
    required this.value,
    required this.target,
    required this.unit,
    this.prescription,
    this.dose,
  });
}

// Sample data
final List<Biomarker> allBiomarkers = [
  Biomarker(
    name: 'BODY TEMPERATURE\n(FEVER/PYREXIA)',
    status: 'HIGH',
    value: '101.2',
    target: '97°F – 99°F (36.1°C – 37.2°C)',
    unit: '°F',
  ),
  Biomarker(
    name: 'PARACETAMOL\n(PRESCRIBED...)',
    status: 'NORMAL',
    value: '500',
    target: 'Prescribed therapeutic dose',
    unit: 'MG',
    prescription: '1 TAB TDS X 5 DAYS',
    dose: '500',
  ),
  Biomarker(
    name: 'SINAREST SYRUP\n(PRESCRIBED...)',
    status: 'NORMAL',
    value: '10',
    target: 'Prescribed therapeutic dose',
    unit: 'ML',
    prescription: 'BD X 5 DAYS',
    dose: '10',
  ),
  Biomarker(
    name: 'ASCORBIC ACID /\nVITAMIN C (...)',
    status: 'CRITICAL',
    value: 'Not measured',
    target: 'Therapeutic supplementation dose\n(65–90mg/day;\ntherapeutic to\n1000mg/day)',
    unit: '',
    prescription: 'OD X 7 DAYS',
    dose: '500',
  ),
];

// ═══════════════════════════════════════════════════
//  ROOT SCREEN (WITH SCROLL TO TOP FUNCTIONALITY)
// ═══════════════════════════════════════════════════
class ClinicalSynthesisScreen extends StatefulWidget {
  const ClinicalSynthesisScreen({super.key});

  @override
  State<ClinicalSynthesisScreen> createState() => _ClinicalSynthesisScreenState();
}

class _ClinicalSynthesisScreenState extends State<ClinicalSynthesisScreen> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Up arrow button with scroll to top functionality
          _FabButton(
            color: const Color(0xFF243C33),
            icon: Icons.keyboard_arrow_up_rounded,
            size: 45,
            onPressed: _scrollToTop,
          ),
          const SizedBox(height: 12),
          _FabButton(
            color: kGreen,
            icon: Icons.chat_bubble_rounded,
            size: 52,
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF2F5EB), Color(0xFFE0E6D8)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(height: 16),
                      _TopBar(),
                      SizedBox(height: 20),
                      _DiagnosticCard(),
                      SizedBox(height: 16),
                      _DoctorsAnalysisCard(),
                      SizedBox(height: 16),
                      _UpgradeCard(),
                      SizedBox(height: 16),
                      _KeyFindingsCard(),
                      SizedBox(height: 28),
                      _BioMarkerSection(),
                      SizedBox(height: 16),
                      _CriticalDeficienciesCard(),
                      SizedBox(height: 16),
                      _NutritionalProtocolCard(),
                      SizedBox(height: 16),
                      _DoctorsRecommendationsCard(),
                      SizedBox(height: 24),
                      _DisclaimerText(),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  TOP BAR
// ═══════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CircleBtn(
          size: 36,
          onTap: () => Navigator.maybePop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: kInk),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('CLINICAL\nSYNTHESIS',
                  style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900,
                    color: kInk, height: 1.05, letterSpacing: -.5,
                  )),
              SizedBox(height: 4),
              Text('AI-POWERED INSIGHTS',
                  style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w800,
                    color: kGreenDeep, letterSpacing: 1.5,
                  )),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CircleBtn(size: 36, child: const Icon(Icons.refresh_rounded, size: 16, color: kGreenDeep)),
            const SizedBox(width: 4),
            _CircleBtn(size: 36, child: const Icon(Icons.translate_rounded, size: 16, color: kGreenDeep)),
            const SizedBox(width: 4),
            _CircleBtn(size: 36, child: const Icon(Icons.share_rounded, size: 16, color: kGreenDeep)),
            const SizedBox(width: 4),
            _CircleBtn(size: 36, child: const Icon(Icons.download_rounded, size: 16, color: kGreenDeep)),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
//  DIAGNOSTIC PROFILE CARD
// ═══════════════════════════════════════════════════
class _DiagnosticCard extends StatelessWidget {
  const _DiagnosticCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFFDFF0DF), Color(0xFFCFE6D2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.description_outlined, color: kGreenDeep, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('DIAGNOSTIC\nPROFILE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                            color: kMuted, letterSpacing: 1.2, height: 1.4)),
                    SizedBox(height: 4),
                    Text('Blood Test',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                            color: kInk, letterSpacing: -.4)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: kGreenTint, borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: kGreen)),
                    const SizedBox(width: 5),
                    const Text('COMPLETE',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                            color: kGreenDeep, letterSpacing: .6)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('SUBJECT',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                            color: kMuted, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Row(children: const [
                      Icon(Icons.person_outline_rounded, size: 16, color: kGreenDeep),
                      SizedBox(width: 6),
                      Text('MAYURA',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kInk)),
                    ]),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('TIMELINE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                            color: kMuted, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Icon(Icons.calendar_today_rounded, size: 14, color: kGreenDeep),
                        SizedBox(width: 6),
                        Text('26/05/2026',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kInk)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  DOCTOR'S ANALYSIS CARD
// ═══════════════════════════════════════════════════
class _DoctorsAnalysisCard extends StatelessWidget {
  const _DoctorsAnalysisCard();

  static const _findings = [
    ['Fever (Pyrexia)', 'Diagnosed with {0} as of 26 May 2026.'],
    ['Paracetamol 500mg', 'Prescribed {0} for fever and pain relief (3 times daily for 5 days).'],
    ['Sinarest Syrup', '{0} prescribed to manage associated cold/congestion symptoms (twice daily for 5 days).'],
    ['Ascorbic Acid (Vitamin C) 500mg', '{0} prescribed to support immune recovery (once daily for 7 days).'],
    ['Complete bed rest', '{0} advised with follow-up in 5\u20137 days or sooner if symptoms worsen.'],
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: kCard,
                  boxShadow: [BoxShadow(color: kShadow, blurRadius: 14, offset: Offset(0, 6))],
                ),
                child: const Icon(Icons.monitor_heart_outlined, color: kGreenDeep, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Doctor's Analysis",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                            color: kInk, letterSpacing: -.5)),
                    SizedBox(height: 4),
                    Text('AI-POWERED CLINICAL ASSESSMENT',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                            color: kGreenDeep, letterSpacing: 1.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFFF3F7EF), Color(0xFFEEF4EA)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE6EFE2)),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [Color(0xFFE0F0E1), Color(0xFFD2E8D6)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.medical_services_outlined, color: kGreenDeep, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("DOCTOR'S\nSYNTHESIS",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                                  color: kGreenDeep, letterSpacing: -.2, height: 1.1)),
                          SizedBox(height: 4),
                          Text('AI CLINICAL PROFILE',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                  color: kMuted, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._findings.map((f) => _FindingRow(bold: f[0], text: f[1])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FindingRow extends StatelessWidget {
  const _FindingRow({required this.bold, required this.text});
  final String bold;
  final String text;

  @override
  Widget build(BuildContext context) {
    final parts = text.split('{0}');
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: kGreen),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                    color: kInkSoft, height: 1.5),
                children: [
                  if (parts[0].isNotEmpty) TextSpan(text: parts[0]),
                  TextSpan(text: bold,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: kInk)),
                  if (parts.length > 1 && parts[1].isNotEmpty) TextSpan(text: parts[1]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  UPGRADE DARK CARD
// ═══════════════════════════════════════════════════
class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [kNavy, Color(0xFF0C1A28)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x99081410), blurRadius: 30, offset: Offset(0, 14))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08), shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Color(0xFF3FE08A), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('NEW AI UPGRADE',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                            color: Color(0xFF43E08C), letterSpacing: .3)),
                    SizedBox(height: 2),
                    Text('EXPERT CLINICAL RECALIBRATION',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                            color: Color(0xFF9FB6AC), letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Get a more professional, empathetic, and doctor\u2013like clinical synthesis of your report.',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: Color(0xFFF1F6F1), height: 1.5),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF22C172), Color(0xFF1F9D63)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(
                  color: Color(0xCC22C172), blurRadius: 20, offset: Offset(0, 10))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('UPGRADE TO EXPERT NOTE',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900,
                              color: Color(0xFF06241A), letterSpacing: .5)),
                      SizedBox(width: 8),
                      Text('\u2728', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  KEY FINDINGS CARD
// ═══════════════════════════════════════════════════
class _KeyFindingsCard extends StatelessWidget {
  const _KeyFindingsCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('KEY FINDINGS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                  color: kMuted, letterSpacing: 1.5)),
          SizedBox(height: 14),
          _FindingChip(label: 'Active diagnosis \u2014 Fever (Pyrexia)'),
          SizedBox(height: 10),
          _FindingChip(label: 'Prescribed medication \u2014 Paracetamol, Sinarest'),
          SizedBox(height: 10),
          _FindingChip(label: 'Vitamin C supplementation for immunity'),
          SizedBox(height: 10),
          _FindingChip(label: 'Bed rest advised for recovery'),
        ],
      ),
    );
  }
}

class _FindingChip extends StatelessWidget {
  const _FindingChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
              shape: BoxShape.circle, border: Border.all(color: kGreen, width: 1.5)),
          child: const Icon(Icons.check_rounded, size: 13, color: kGreen),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kInk)),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════
//  BIO-MARKER METRICS SECTION (WITH TAB FILTERING)
// ═══════════════════════════════════════════════════
class _BioMarkerSection extends StatefulWidget {
  const _BioMarkerSection();

  @override
  State<_BioMarkerSection> createState() => _BioMarkerSectionState();
}

class _BioMarkerSectionState extends State<_BioMarkerSection> {
  int _selectedTab = 0;
  final _tabs = ['ALL', 'NORMAL', 'BORDERLINE', 'HIGH'];

  List<Biomarker> get _filteredBiomarkers {
    if (_selectedTab == 0) return allBiomarkers;
    final status = _tabs[_selectedTab];
    return allBiomarkers.where((b) => b.status == status).toList();
  }

  int get _optimalCount => allBiomarkers.where((b) => b.status == 'NORMAL').length;
  int get _cautionCount => allBiomarkers.where((b) => b.status == 'BORDERLINE').length;
  int get _criticalCount => allBiomarkers.where((b) => b.status == 'CRITICAL' || b.status == 'HIGH').length;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBiomarkers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row
        Row(
          children: [
            const Text('BIO-MARKER METRICS',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                    color: kInk, letterSpacing: -.4)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: kCard, borderRadius: BorderRadius.circular(999),
                boxShadow: const [BoxShadow(color: kShadow, blurRadius: 12, offset: Offset(0, 4))],
              ),
              child: Text('${allBiomarkers.length} TOTAL',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                      color: kInkSoft, letterSpacing: .5)),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Filter tabs
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: kCard, borderRadius: BorderRadius.circular(999),
            boxShadow: const [BoxShadow(color: kShadow, blurRadius: 12, offset: Offset(0, 4))],
          ),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final selected = i == _selectedTab;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? kGreenDeep : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(_tabs[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .5,
                        color: selected ? Colors.white : kMuted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 18),

        // Stat tiles (always show totals)
        Row(
          children: [
            Expanded(child: _StatTile(count: '$_optimalCount', label: 'OPTIMAL',
                color: kGreen, bgColor: const Color(0xFFE8F5EE), icon: Icons.check_circle_outline_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _StatTile(count: '$_cautionCount', label: 'CAUTION',
                color: kOrange, bgColor: kOrangeTint, icon: Icons.error_outline_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _StatTile(count: '$_criticalCount', label: 'CRITICAL',
                color: kPurple, bgColor: kPurpleTint, icon: Icons.warning_amber_rounded)),
          ],
        ),
        const SizedBox(height: 16),

        // Filtered biomarker grid
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [BoxShadow(color: kShadow, blurRadius: 16, offset: Offset(0, 8))],
            ),
            child: const Center(
              child: Text('No biomarkers found in this category',
                  style: TextStyle(fontSize: 14, color: kMuted, fontWeight: FontWeight.w500)),
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < filtered.length; i += 2)
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _BiomarkerCard(biomarker: filtered[i])),
                        if (i + 1 < filtered.length) ...[
                          const SizedBox(width: 10),
                          Expanded(child: _BiomarkerCard(biomarker: filtered[i + 1])),
                        ],
                      ],
                    ),
                    if (i + 2 < filtered.length) const SizedBox(height: 10),
                  ],
                ),
            ],
          ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.count, required this.label,
    required this.color, required this.bgColor, required this.icon,
  });
  final String count, label;
  final Color color, bgColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: kShadow, blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(count,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kInk)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: kMuted, letterSpacing: .8)),
        ],
      ),
    );
  }
}

class _BiomarkerCard extends StatelessWidget {
  const _BiomarkerCard({required this.biomarker});
  final Biomarker biomarker;

  Color get _statusColor {
    switch (biomarker.status) {
      case 'HIGH': return kPurple;
      case 'CRITICAL': return kRed;
      case 'BORDERLINE': return kOrange;
      default: return kGreen;
    }
  }

  Color get _statusBgColor {
    switch (biomarker.status) {
      case 'HIGH': return kPurpleTint;
      case 'CRITICAL': return kRedTint;
      case 'BORDERLINE': return kOrangeTint;
      default: return const Color(0xFFE8F5EE);
    }
  }

  IconData get _statusIcon {
    switch (biomarker.status) {
      case 'HIGH': return Icons.warning_amber_rounded;
      case 'CRITICAL': return Icons.warning_amber_rounded;
      case 'BORDERLINE': return Icons.error_outline_rounded;
      default: return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: kShadow, blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _statusBgColor),
                child: Icon(_statusIcon, color: _statusColor, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: biomarker.status == 'HIGH' || biomarker.status == 'CRITICAL'
                      ? kInk
                      : Colors.transparent,
                  border: biomarker.status == 'HIGH' || biomarker.status == 'CRITICAL'
                      ? null
                      : Border.all(color: kGreen, width: 1.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(biomarker.status,
                    style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .5,
                      color: biomarker.status == 'HIGH' || biomarker.status == 'CRITICAL'
                          ? Colors.white
                          : kGreen,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(biomarker.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                  color: kInk, height: 1.3)),
          const SizedBox(height: 8),
          Text(biomarker.target,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                  color: kMuted, height: 1.4)),
          if (biomarker.value != 'Not measured') ...[
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(children: [
                TextSpan(text: biomarker.value,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                        color: kGreen)),
                if (biomarker.unit.isNotEmpty)
                  TextSpan(text: '  ${biomarker.unit}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                          color: kMuted)),
                if (biomarker.prescription != null)
                  TextSpan(text: '\n${biomarker.prescription}',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                          color: kMuted, height: 1.4)),
              ]),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Text(biomarker.value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                    color: kRed, height: 1.4)),
            if (biomarker.prescription != null)
              Text(biomarker.prescription!,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                      color: kMuted, height: 1.4)),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  CRITICAL DEFICIENCIES CARD
// ═══════════════════════════════════════════════════
class _CriticalDeficienciesCard extends StatelessWidget {
  const _CriticalDeficienciesCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: kRedTint),
                child: const Icon(Icons.warning_amber_rounded, color: kRed, size: 24),
              ),
              const SizedBox(width: 14),
              const Text('CRITICAL DEFICIENCIES',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                      color: kInk, letterSpacing: -.3)),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: kCard, borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: const [BoxShadow(color: kShadow, blurRadius: 12, offset: Offset(0, 6))],
            ),
            clipBehavior: Clip.hardEdge,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(width: 5, color: kRed),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: const Text('VITAMIN C\n(RELATIVE/FUNCTIONAL)',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                                        color: kInk, height: 1.3)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD6D6),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text('MILD',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                                        color: Color(0xFFB71C1C), letterSpacing: .5)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('CURRENT',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                            color: kMuted, letterSpacing: 1)),
                                    SizedBox(height: 6),
                                    Text('Not measured\n\u2014 supplementation\nprescribed\ntherapeutically',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                            color: kInk, height: 1.4)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('RANGE',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                                            color: kMuted, letterSpacing: 1)),
                                    SizedBox(height: 6),
                                    Text('Serum\nVitamin C:\n0.6\u20132.0\nmg/dL',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                                            color: kMuted, height: 1.4)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  NUTRITIONAL PROTOCOL CARD
// ═══════════════════════════════════════════════════
class _NutritionalProtocolCard extends StatelessWidget {
  const _NutritionalProtocolCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFE6D4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.restaurant_menu_rounded, color: kGreenDeep, size: 28),
              ),
              const SizedBox(width: 14),
              const Text('NUTRITIONAL\nPROTOCOL',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                      color: kInk, letterSpacing: -.4, height: 1.1)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Based on your clinical synthesis, we've prepared an optimized nutritional strategy to address your bio-marker needs.",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                color: kInkSoft, height: 1.6),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: kGreenDeep,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.auto_awesome_outlined, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text('GENERATE PERSONALIZED DIET PLAN',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                              color: Colors.white, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  DOCTOR'S RECOMMENDATIONS CARD
// ═══════════════════════════════════════════════════
class _DoctorsRecommendationsCard extends StatelessWidget {
  const _DoctorsRecommendationsCard();

  static const _recs = [
    'Eat light, easily digestible, warm meals such as khichdi, dal soup, and vegetable broth \u2014 avoid heavy, oily, or spicy foods that stress the digestive system during illness',
    'Include natural Vitamin C-rich foods (amla, guava, oranges) in your diet daily to complement your Ascorbic Acid supplement and boost immune recovery',
    'Avoid cold beverages, ice cream, and exposure to cold air/AC drafts which can worsen congestion and cold symptoms',
    'Get 8\u201310 hours of sleep per night \u2014 sleep is when your immune system does its most powerful repair and recovery work',
    'Follow up with your doctor in 5\u20137 days as advised, and keep a note of any new symptoms (rash, difficulty breathing, severe headache) to report immediately',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kRecsGreen,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 12))],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Doctor's\nRecommendations",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                            color: Colors.white, height: 1.1, letterSpacing: -.3)),
                    SizedBox(height: 6),
                    Text('BASED ON YOUR REPORT FINDINGS',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                            color: Color(0xCCFFFFFF), letterSpacing: 1.2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...List.generate(_recs.length,
                  (i) => _RecommendationItem(number: i + 1, text: _recs[i])),
        ],
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  const _RecommendationItem({required this.number, required this.text});
  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kRecsItem,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('$number',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: Colors.white, height: 1.55)),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  DISCLAIMER
// ═══════════════════════════════════════════════════
class _DisclaimerText extends StatelessWidget {
  const _DisclaimerText();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'DISCLAIMER: THIS AI ANALYSIS IS FOR INFORMATIONAL WELLNESS SUPPORT ONLY AND SHOULD NOT REPLACE PROFESSIONAL MEDICAL ADVICE. ALWAYS CONSULT WITH A HEALTHCARE PROVIDER.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600,
            color: kMuted, letterSpacing: .4, height: 1.7),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ═══════════════════════════════════════════════════
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kCard, borderRadius: BorderRadius.circular(26),
        boxShadow: const [BoxShadow(color: kShadow, blurRadius: 30, offset: Offset(0, 14))],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({this.child, this.onTap, this.size = 44});
  final Widget? child;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap ?? () {
          // Default: go back to previous screen
          Navigator.pop(context);
        },
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  const _FabButton({
    required this.color,
    required this.icon,
    this.size = 56,
    this.onPressed,
  });
  final Color color;
  final IconData icon;
  final double size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        heroTag: icon.toString(),
        backgroundColor: color,
        onPressed: onPressed ?? () {},
        elevation: 8,
        child: Icon(icon, color: Colors.white, size: size * .4),
      ),
    );
  }
}