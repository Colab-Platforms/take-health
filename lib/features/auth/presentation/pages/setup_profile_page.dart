import 'package:classroom_app/features/auth/presentation/widgets/auth_app_bar.dart';
import 'package:flutter/material.dart';

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

  final List<String> _diabeticOptions = [
    'Yes',
    'No',
    'Pre-diabetic',
  ];

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

  void _showDiabeticBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
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
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  ..._diabeticOptions.map((option) {
                    return RadioListTile<String>(
                      title: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      value: option,
                      groupValue: selectedDiabetic,
                      onChanged: (value) {
                        modalSetState(() {
                          selectedDiabetic = value;
                        });

                        // IMPORTANT FIX
                        setState(() {
                          selectedDiabetic = value;
                        });

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
                        side: const BorderSide(
                          color: Color(0xFF0D4D3B),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF0D4D3B),
                          fontSize: 16,
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AuthAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
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
                Expanded(
                  child: _buildDiabeticField(),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _buildDietPreferenceField(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedHeightUnit = value;
                      });
                    },
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
                  child: Text(
                    level,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedActivityLevel = value;
                });
              },
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 2),

        GestureDetector(
          onTap: _showDiabeticBottomSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
                return DropdownMenuItem(
                  value: pref,
                  child: Text(pref),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDietPreference = value;
                });
              },
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
        onPressed: () {},
        child: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.black12,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.black12,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF0D4D3B),
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: Colors.black12,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(12),
    );
  }
}