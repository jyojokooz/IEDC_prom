import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ideathon_website/event_details_screen.dart';
import 'package:ideathon_website/event_model.dart';
import 'package:ideathon_website/main.dart';

// --- Dummy Event Data ---
final List<Event> dummyEvents = [
  const Event(
    id: 'code_clash_24',
    title: 'CodeClash \'24',
    tagline: 'A 12-hour competitive programming marathon.',
    imageUrl: 'assets/images/event1.jpg',
    description:
        'CodeClash is the ultimate test of problem-solving skills and coding prowess. Participants will face a series of complex algorithmic challenges, racing against the clock to deliver the most efficient and elegant solutions. Open to all students who love to code.',
    date: 'October 26, 2024',
    venue: 'Main Auditorium, RIT',
    rules: [
      'Teams can have 1-3 members.',
      'Only standard library functions are allowed.',
      'Internet access is restricted during the competition.',
      'Solutions will be judged on correctness and efficiency.',
    ],
  ),
  const Event(
    id: 'design_sprint_24',
    title: 'Design Sprint',
    tagline: 'Innovate, prototype, and validate a UI/UX challenge.',
    imageUrl: 'assets/images/event2.jpg',
    description:
        'Join our intensive Design Sprint where teams will tackle a real-world UI/UX problem. From user research to high-fidelity prototyping and user testing, this event covers the entire design lifecycle in just 48 hours. Bring your creativity and collaboration skills!',
    date: 'October 27, 2024',
    venue: 'IEDC Hub, RIT',
    rules: [
      'Teams must consist of 3-4 members.',
      'All design work must be created during the event.',
      'Final submission must include a clickable prototype and a presentation.',
      'Access to design tools like Figma and Adobe XD will be provided.',
    ],
  ),
  const Event(
    id: 'robo_wars_24',
    title: 'RoboWars',
    tagline: 'Build and battle custom robots in a thrilling arena.',
    imageUrl: 'assets/images/event3.jpg',
    description:
        'RoboWars is where engineering meets destruction! Design, build, and arm your custom robot to compete in a head-to-head tournament. Robots will be judged on design, innovation, and combat performance. May the best machine win!',
    date: 'October 28, 2024',
    venue: 'Basketball Court, RIT',
    rules: [
      'Robot weight must not exceed 15kg.',
      'Pneumatic and hydraulic systems are prohibited.',
      'All robots must pass a safety inspection before competing.',
      'A designated pit area will be available for repairs and modifications.',
    ],
  ),
];

// UPDATED: A more robust check for screen size.
bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= 850;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _ideathonFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _teamNameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _eventsKey = GlobalKey();
  final GlobalKey _scheduleKey = GlobalKey();
  final GlobalKey _registrationKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _teamNameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitIdeathonRegistration() async {
    if (_ideathonFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting Ideathon registration...')),
      );
      try {
        await FirebaseFirestore.instance
            .collection('ideathon_registrations')
            .add({
              'name': _nameController.text,
              'email': _emailController.text,
              'phone': _phoneController.text,
              'teamName': _teamNameController.text,
              'timestamp': FieldValue.serverTimestamp(),
            });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful!'),
            backgroundColor: Colors.green,
          ),
        );
        _ideathonFormKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _teamNameController.clear();
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

  void _scrollToSection(GlobalKey key) {
    // NEW: If on mobile, close the drawer first
    if (!isDesktop(context)) {
      Navigator.of(context).pop();
    }
    // Use a small delay to allow the drawer to close before scrolling
    Future.delayed(const Duration(milliseconds: 200), () {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    });
  }

  // NEW: A dedicated builder for the mobile navigation drawer
  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: kBackgroundColor,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: const Color(0xFF1F1A3E).withOpacity(0.8),
            ),
            child: Center(
              child: Image.asset('assets/images/iedc_logo.png', height: 60),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => _scrollToSection(_aboutKey),
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Events'),
            onTap: () => _scrollToSection(_eventsKey),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Schedule'),
            onTap: () => _scrollToSection(_scheduleKey),
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail_outlined),
            title: const Text('Contact'),
            onTap: () => _scrollToSection(_contactKey),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GradientButton(
              text: "Register for Ideathon",
              onPressed: () => _scrollToSection(_registrationKey),
            ),
          ),
        ],
      ),
    );
  }

  // NEW: A dedicated builder for the responsive AppBar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: kBackgroundColor.withOpacity(0.8),
      elevation: 0,
      // On desktop, we don't want the hamburger menu, so the leading icon is null
      automaticallyImplyLeading: !isDesktop(context),
      title: Image.asset('assets/images/iedc_logo.png', height: 40),
      // On mobile, actions are empty. On desktop, they are populated.
      actions: isDesktop(context)
          ? [
              TextButton(
                onPressed: () => _scrollToSection(_aboutKey),
                child: const Text('About'),
              ),
              TextButton(
                onPressed: () => _scrollToSection(_eventsKey),
                child: const Text('Events'),
              ),
              TextButton(
                onPressed: () => _scrollToSection(_scheduleKey),
                child: const Text('Schedule'),
              ),
              TextButton(
                onPressed: () => _scrollToSection(_contactKey),
                child: const Text('Contact'),
              ),
              const SizedBox(width: 20),
              GradientButton(
                text: "Register for Ideathon",
                onPressed: () => _scrollToSection(_registrationKey),
              ),
              const SizedBox(width: 20),
            ]
          : [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // UPDATED: Use the new builder methods
      appBar: _buildAppBar(),
      drawer: isDesktop(context) ? null : _buildMobileDrawer(),
      body: Stack(
        children: [
          Container(color: kBackgroundColor),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF1F1A3E).withOpacity(0.8),
                  kBackgroundColor,
                ],
                center: const Alignment(0, -0.5),
                radius: 1.0,
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -50,
            child: Image.asset('assets/images/abstract_shape1.png', width: 200),
          ),
          Positioned(
            bottom: 200,
            right: -50,
            child: Image.asset('assets/images/abstract_shape2.png', width: 150),
          ),
          Center(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      _buildHeroSection(),
                      const SizedBox(height: 80),
                      _buildAboutSection(),
                      const SizedBox(height: 80),
                      _buildEventsSection(),
                      const SizedBox(height: 80),
                      _buildScheduleSection(),
                      const SizedBox(height: 80),
                      _buildIdeathonRegistrationSection(),
                      const SizedBox(height: 80),
                      _buildContactSection(),
                      const SizedBox(height: 40),
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

  // --- All section-building methods below remain the same ---
  // --- No changes needed for _buildHeroSection, _buildAboutSection, etc. ---

  Widget _buildHeroSection() {
    final heroContent = Column(
      crossAxisAlignment: isDesktop(context)
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        const Text(
          'UNLEASH YOUR IDEAS',
          style: TextStyle(fontSize: 18, color: kSecondaryTextColor),
        ),
        RichText(
          textAlign: isDesktop(context) ? TextAlign.start : TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 60,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            children: [
              TextSpan(text: 'Join The\n'),
              WidgetSpan(child: GradientText('Ideathon')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'A 24-hour marathon of innovation, collaboration, and creation.\nPresented by IEDC RIT as part of PROMINENCE.',
          textAlign: isDesktop(context) ? TextAlign.start : TextAlign.center,
          style: const TextStyle(fontSize: 16, color: kSecondaryTextColor),
        ),
        const SizedBox(height: 30),
        GradientButton(
          text: "Explore Events",
          onPressed: () => _scrollToSection(_eventsKey),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        ),
      ],
    );
    final heroImage = Image.asset('assets/images/vr_person.png');
    final animatedHeroContent = heroContent
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .move(begin: const Offset(0, 20), curve: Curves.easeOut);
    final animatedHeroImage = heroImage
        .animate()
        .fadeIn(duration: 600.ms)
        .move(begin: const Offset(20, 0), curve: Curves.easeOut);
    if (isDesktop(context)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: animatedHeroContent),
            const SizedBox(width: 50),
            Expanded(child: animatedHeroImage),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            animatedHeroImage,
            const SizedBox(height: 40),
            animatedHeroContent,
          ],
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      children: [
        Text(
          subtitle.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFFE842A0),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
          key: _aboutKey,
          children: [
            _buildSectionTitle('What is Prominence?', 'About the Fest'),
            const InfoCard(
              icon: Icons.lightbulb_outline,
              title: 'Innovation Challenge',
              description:
                  'A platform to transform your groundbreaking ideas into tangible solutions. Collaborate with peers and build a business plan to impress our expert judges.',
            ),
            const SizedBox(height: 20),
            const InfoCard(
              icon: Icons.people_outline,
              title: 'Mentorship & Networking',
              description:
                  'Gain invaluable insights from industry experts and mentors. Network with like-minded innovators, entrepreneurs, and potential investors.',
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildEventsSection() {
    return Column(
          key: _eventsKey,
          children: [
            _buildSectionTitle('Explore Our Events', 'Prominence Fest'),
            isDesktop(context)
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: dummyEvents
                        .map(
                          (event) => Expanded(child: EventCard(event: event)),
                        )
                        .toList(),
                  )
                : Column(
                    children: dummyEvents
                        .map(
                          (event) => Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: EventCard(event: event),
                          ),
                        )
                        .toList(),
                  ),
          ],
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildScheduleSection() {
    return Column(
      key: _scheduleKey,
      children: [
        _buildSectionTitle('Main Ideathon Timeline', 'Schedule'),
        _buildTimelineStep(
          '1',
          'Day 1: 09:00 AM',
          'Registration & Welcome Keynote',
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).moveX(begin: -20),
        _buildTimelineStep(
          '2',
          'Day 1: 11:00 AM',
          'Hacking & Brainstorming Begins',
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms).moveX(begin: -20),
        _buildTimelineStep(
          '3',
          'Day 2: 09:00 AM',
          'Final Submissions Due',
        ).animate().fadeIn(delay: 400.ms, duration: 400.ms).moveX(begin: -20),
        _buildTimelineStep(
          '4',
          'Day 2: 10:00 AM',
          'Final Presentations to Judges',
        ).animate().fadeIn(delay: 500.ms, duration: 400.ms).moveX(begin: -20),
        _buildTimelineStep(
          '5',
          'Day 2: 01:00 PM',
          'Winners Announcement & Closing',
        ).animate().fadeIn(delay: 600.ms, duration: 400.ms).moveX(begin: -20),
      ],
    );
  }

  Widget _buildTimelineStep(String step, String time, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: kPrimaryGradient,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kSecondaryTextColor,
                  ),
                ),
                Text(description, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdeathonRegistrationSection() {
    return Column(
          key: _registrationKey,
          children: [
            _buildSectionTitle(
              'Don\'t Miss The Main Event',
              'Register for the Ideathon',
            ),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Form(
                key: _ideathonFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Team Leader Name',
                      ),
                      validator: (v) => (v!.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                      ),
                      validator: (v) => (v!.isEmpty || !v.contains('@'))
                          ? 'Valid email required'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                      ),
                      validator: (v) => (v!.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _teamNameController,
                      decoration: const InputDecoration(labelText: 'Team Name'),
                      validator: (v) => (v!.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 40),
                    GradientButton(
                      text: "Submit Ideathon Registration",
                      onPressed: _submitIdeathonRegistration,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }

  Widget _buildContactSection() {
    return Column(
          key: _contactKey,
          children: [
            _buildSectionTitle('Get In Touch', 'Contact Us'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Expanded(
                  child: InfoCard(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    description: 'iedc@rit.ac.in',
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: InfoCard(
                    icon: Icons.phone_outlined,
                    title: 'Phone',
                    description: '+91 12345 67890',
                  ),
                ),
              ],
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}

class EventCard extends StatefulWidget {
  final Event event;
  const EventCard({super.key, required this.event});
  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(event: widget.event),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFFE842A0).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.asset(
                  widget.event.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.event.tagline,
                      style: const TextStyle(color: kSecondaryTextColor),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          "Learn More",
                          style: TextStyle(
                            color: _isHovered
                                ? const Color(0xFFE842A0)
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedSlide(
                          offset: _isHovered
                              ? Offset.zero
                              : const Offset(-0.5, 0),
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFFE842A0),
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final EdgeInsets padding;
  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: kPrimaryGradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => kPrimaryGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 60),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const InfoCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFE842A0), size: 32),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: kSecondaryTextColor)),
        ],
      ),
    );
  }
}
