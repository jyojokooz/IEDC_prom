import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ideathon_website/event_model.dart';
import 'package:ideathon_website/home_screen.dart'; // Re-using GradientButton
import 'package:ideathon_website/main.dart'; // Re-using constants

enum RegistrationType { single, team }

class EventDetailsScreen extends StatefulWidget {
  final Event event;
  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  RegistrationType _selectedType = RegistrationType.single;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _teamNameController = TextEditingController();
  final _member2Controller = TextEditingController();
  final _member3Controller = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _teamNameController.dispose();
    _member2Controller.dispose();
    _member3Controller.dispose();
    super.dispose();
  }

  Future<void> _submitEventRegistration() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting registration...')),
      );
      final Map<String, dynamic> registrationData = {
        'eventId': widget.event.id,
        'eventName': widget.event.title,
        'registrationType': _selectedType.name,
        'leaderName': _nameController.text,
        'leaderEmail': _emailController.text,
        'leaderPhone': _phoneController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };
      if (_selectedType == RegistrationType.team) {
        registrationData.addAll({
          'teamName': _teamNameController.text,
          'member2Email': _member2Controller.text,
          'member3Email': _member3Controller.text,
        });
      }
      try {
        await FirebaseFirestore.instance
            .collection('event_registrations')
            .add(registrationData);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful!'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _teamNameController.clear();
        _member2Controller.clear();
        _member3Controller.clear();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register. Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: kBackgroundColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.event.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(widget.event.imageUrl, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              kBackgroundColor.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventInfo(),
                      const SizedBox(height: 40),
                      _buildSectionTitle("Description"),
                      Text(
                        widget.event.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: kSecondaryTextColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildSectionTitle("Rules & Guidelines"),
                      ...widget.event.rules.map(
                        (rule) => ListTile(
                          leading: const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFFE842A0),
                          ),
                          title: Text(rule),
                        ),
                      ),
                      const SizedBox(height: 60),
                      _buildRegistrationForm(),
                      const SizedBox(height: 60),
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

  Widget _buildEventInfo() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, color: kSecondaryTextColor),
        const SizedBox(width: 8),
        Text(
          widget.event.date,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 24),
        const Icon(Icons.location_on, color: kSecondaryTextColor),
        const SizedBox(width: 8),
        Text(
          widget.event.venue,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE842A0),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Register for this Event"),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Registration Type",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ToggleButtons(
                  isSelected: [
                    _selectedType == RegistrationType.single,
                    _selectedType == RegistrationType.team,
                  ],
                  onPressed: (index) => setState(
                    () => _selectedType = RegistrationType.values[index],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.black,
                  color: Colors.white,
                  fillColor: const Color(0xFFE842A0),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Single"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Team"),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: _selectedType == RegistrationType.single
                        ? "Your Name"
                        : "Team Leader Name",
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: _selectedType == RegistrationType.single
                        ? "Your Email"
                        : "Team Leader Email",
                  ),
                  validator: (v) => (v!.isEmpty || !v.contains('@'))
                      ? 'Valid email required'
                      : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: _selectedType == RegistrationType.single
                        ? "Your Phone"
                        : "Team Leader Phone",
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _selectedType == RegistrationType.team
                      ? Column(
                          key: const ValueKey('team_fields'),
                          children: [
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _teamNameController,
                              decoration: const InputDecoration(
                                labelText: "Team Name",
                              ),
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _member2Controller,
                              decoration: const InputDecoration(
                                labelText: "Team Member 2 Email",
                              ),
                              validator: (v) => (v!.isEmpty || !v.contains('@'))
                                  ? 'Valid email required'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _member3Controller,
                              decoration: const InputDecoration(
                                labelText: "Team Member 3 Email (Optional)",
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(key: ValueKey('empty_space')),
                ),
                const SizedBox(height: 40),
                Center(
                  child: GradientButton(
                    text: "Submit Registration",
                    onPressed: _submitEventRegistration,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }
}
