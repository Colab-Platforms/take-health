import 'package:classroom_app/features/auth/presentation/widgets/auth_app_bar.dart';
import 'package:classroom_app/core/routes/app_routes.dart';
import 'package:classroom_app/core/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SetupProfilePage extends StatefulWidget {
  const SetupProfilePage({super.key});

  @override
  State<SetupProfilePage> createState() => _SetupProfilePageState();
}

class _SetupProfilePageState extends State<SetupProfilePage> {
  String? selectedGender;
  String? selectedHeightUnit = 'CM';
  String? selectedActivityLevel;
  String? selectedDiabetic;
  String? selectedDietPreference;
  bool _isLoading = false;

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _heightUnits = ['CM', 'FT'];
  final List<String> _activityLevels = [
    'Sedentary (Little/no exercise)',
    'Lightly Active (1-3 days/week)',
    'Moderately Active (3-5 days/week)',
    'Very Active (6-7 days/week)',
    'Extremely Active (Athlete)',
  ];
  final List<String> _diabeticOptions = ['Yes', 'No', 'Pre-diabetic'];
  final List<String> _dietPreferences = [
    'Non-Vegetarian',
    'Vegetarian',
    'Vegan',
    'Keto',
    'Pescatarian',
  ];

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // ─── Value Mappers ────────────────────────────────────────────────────────

  String _mapActivityLevel(String level) {
    if (level.startsWith('Sedentary')) return 'sedentary';
    if (level.startsWith('Lightly')) return 'lightly_active';
    if (level.startsWith('Moderately')) return 'moderately_active';
    if (level.startsWith('Very')) return 'very_active';
    if (level.startsWith('Extremely')) return 'extremely_active';
    return 'sedentary';
  }

  String _mapDietPreference(String pref) {
    switch (pref) {
      case 'Non-Vegetarian': return 'non-vegetarian';  // Try with hyphen
      case 'Vegetarian':     return 'vegetarian';       // Full word
      case 'Vegan':          return 'vegan';
      case 'Keto':           return 'keto';
      case 'Pescatarian':    return 'pescatarian';
      default:               return 'vegetarian';
    }
  }

  String _mapDiabetic(String val) {
    switch (val) {
      case 'Yes':          return 'yes';
      case 'No':           return 'no';
      case 'Pre-diabetic': return 'pre_diabetic';
      default:             return 'no';
    }
  }

  String _mapGender(String gender) => gender.toLowerCase();

  double _getHeightInCm() {
    final raw = double.tryParse(_heightController.text) ?? 0;
    return selectedHeightUnit == 'FT' ? raw * 30.48 : raw;
  }

  // ─── Submit via ApiService ────────────────────────────────────────────────

  Future<void> _submitProfile() async {
    if (_ageController.text.isEmpty ||
        selectedGender == null ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        selectedActivityLevel == null ||
        selectedDiabetic == null ||
        selectedDietPreference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.updateProfile({
        "name": "",
        "phone": "",
        "profile": {
          "age": int.tryParse(_ageController.text) ?? 0,
          "gender": _mapGender(selectedGender!),
          "dietaryPreference": _mapDietPreference(selectedDietPreference!),
          "height": _getHeightInCm(),
          "weight": double.tryParse(_weightController.text) ?? 0,
          "bloodGroup": "",
          "allergies": [],
          "chronicConditions": [],
          "isDiabetic": _mapDiabetic(selectedDiabetic!),
          "avatar": "",
          "activityLevel": _mapActivityLevel(selectedActivityLevel!),
          "medicalHistory": {
            "conditions": [],
            "surgeries": [],
            "familyHistory": [],
            "currentMedications": [],
          },
          "lifestyle": {
            "smoker": false,
            "smokingFrequency": "",
            "alcohol": false,
            "alcoholFrequency": "",
            "sleepHours": 0,
            "stressLevel": "low",
            "waterIntake": 0,
          },
          "diabetesProfile": {
            "type": "Type 1",
            "diagnosisYear": 0,
            "status": "Controlled",
            "hba1c": 0,
            "glucoseMonitoring": "",
            "fastingGlucose": "",
            "postMealGlucose": "",
            "testingFrequency": "",
            "onMedication": false,
            "medicationType": [],
            "insulinTiming": "",
            "recentDosageChange": false,
          },
          "dietPreferences": {
            "cuisinePreference": "",
            "mealsPerDay": "",
            "restrictions": [],
          },
          "fitnessProfile": {
            "exercisePreference": [],
            "primaryGoal": "",
            "timeframe": "",
            "biggestChallenge": "",
          },
          "hasSeenMobileTour": false,
        },
        "nutritionGoal": {
          "goal": "weight_loss",
          "targetWeight": 0,
          "weeklyGoal": 0,
          "calorieGoal": 0,
          "proteinGoal": 0,
          "carbsGoal": 0,
          "fatGoal": 0,
          "autoCalculated": true,
          "lastUpdated": DateTime.now().toUtc().toIso8601String(),
        },
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile set up successfully!'),
          backgroundColor: Color(0xFF0D4D3B),
        ),
      );

      context.go(AppRoutes.homePage);

    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('HttpException: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );

      if (message.contains('Session expired')) {
        context.go(AppRoutes.login);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Bottom Sheet ─────────────────────────────────────────────────────────

  void _showDiabeticBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Are you diabetic?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0D4D3B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This helps us customize your health plan',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ..._diabeticOptions.map((option) {
                    return RadioListTile<String>(
                      title: Text(option, style: const TextStyle(fontSize: 16)),
                      value: option,
                      groupValue: selectedDiabetic,
                      onChanged: (value) {
                        modalSetState(() => selectedDiabetic = value);
                        setState(() => selectedDiabetic = value);
                        Navigator.pop(context);
                      },
                      activeColor: const Color(0xFF0D4D3B),
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0D4D3B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF0D4D3B), fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AuthAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildAgeField(),
            const SizedBox(height: 15),
            _buildGenderField(),
            const SizedBox(height: 15),
            _buildHeightField(),
            const SizedBox(height: 15),
            _buildWeightField(),
            const SizedBox(height: 15),
            _buildActivityLevelField(),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildDiabeticField()),
                const SizedBox(width: 16),
                Expanded(child: _buildDietPreferenceField()),
              ],
            ),
            const SizedBox(height: 32),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  // ─── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Setup Profile',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0D4D3B),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Health Identity',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildAgeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Age *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('Enter your age'),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: _boxDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedGender,
              hint: const Text('Select'),
              isExpanded: true,
              items: _genders.map((gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (value) => setState(() => selectedGender = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Height *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Enter height'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: _boxDecoration(),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedHeightUnit,
                    isExpanded: true,
                    items: _heightUnits.map((unit) {
                      return DropdownMenuItem(value: unit, child: Text(unit));
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedHeightUnit = value),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weight (Kg) *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        TextField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration('Enter weight'),
        ),
      ],
    );
  }

  Widget _buildActivityLevelField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Level *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: _boxDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedActivityLevel,
              hint: const Text('Select activity'),
              isExpanded: true,
              items: _activityLevels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => selectedActivityLevel = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiabeticField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Are You Diabetic? *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: _showDiabeticBottomSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: _boxDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDiabetic ?? 'Select',
                  style: TextStyle(
                    color: selectedDiabetic != null
                        ? Colors.black
                        : Colors.black26,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDietPreferenceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Diet Preference *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: _boxDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedDietPreference,
              hint: const Text('Select'),
              isExpanded: true,
              items: _dietPreferences.map((pref) {
                return DropdownMenuItem(value: pref, child: Text(pref));
              }).toList(),
              onChanged: (value) =>
                  setState(() => selectedDietPreference = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D4D3B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isLoading ? null : _submitProfile,
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : const Text(
          'Sign Up',
          style: TextStyle(fontSize: 16, letterSpacing: 1.5),
        ),
      ),
    );
  }

  // ─── Decoration Helpers ───────────────────────────────────────────────────

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D4D3B), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.black12, width: 1.5),
      borderRadius: BorderRadius.circular(12),
    );
  }
}