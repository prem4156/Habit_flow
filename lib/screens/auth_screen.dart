import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/system_state.dart';
import '../theme/system_theme.dart';

class AuthScreen extends StatefulWidget {
  final SystemState state;

  const AuthScreen({super.key, required this.state});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In Controllers
  final _signInEmailCtrl = TextEditingController();
  final _signInPassCtrl = TextEditingController();
  bool _obscureSignInPass = true;

  // Sign Up Controllers
  final _signUpNameCtrl = TextEditingController();
  final _signUpEmailCtrl = TextEditingController();
  final _signUpPassCtrl = TextEditingController();
  bool _obscureSignUpPass = true;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailCtrl.dispose();
    _signInPassCtrl.dispose();
    _signUpNameCtrl.dispose();
    _signUpEmailCtrl.dispose();
    _signUpPassCtrl.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    final email = _signInEmailCtrl.text.trim();
    final pass = _signInPassCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _errorMessage = 'Please enter both Email and Passcode.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    final success = await widget.state.signInWithEmail(email, pass);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (!success) {
        _errorMessage = 'Authentication failed. Check credentials.';
      }
    });
  }

  void _handleSignUp() async {
    final name = _signUpNameCtrl.text.trim();
    final email = _signUpEmailCtrl.text.trim();
    final pass = _signUpPassCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _errorMessage = 'Please provide an Email and Passcode.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    final success = await widget.state.signUpWithEmail(email, pass, name);
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (!success) {
        _errorMessage = 'Failed to register Hunter Protocol.';
      }
    });
  }

  void _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    try {
      // 1. Attempt native device Google account sign-in
      final success = await widget.state.signInWithGoogle(tryDeviceAuth: true);
      if (!mounted) return;

      setState(() => _isLoading = false);

      // If user cancelled native dialog or device auth is not supported, open the picker modal
      if (!success && !widget.state.isAuthenticated) {
        _showGoogleAccountPicker();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showGoogleAccountPicker();
    }
  }

  void _showGoogleAccountPicker() {

    showModalBottomSheet(
      context: context,
      backgroundColor: SystemColors.panelBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: SystemColors.cyanGlow, width: 1.2),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('G', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose a Google Account',
                        style: GoogleFonts.orbitron(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'to continue to Monarch Protocol',
                        style: GoogleFonts.rajdhani(color: SystemColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),

              // Quick Google Profile 1
              _buildGoogleAccountOption(
                name: 'Sung Jin-Woo',
                email: 'jinwoo.shadowmonarch@gmail.com',
                avatarChar: 'S',
                color: Colors.deepPurple,
                onTap: () {
                  Navigator.pop(ctx);
                  widget.state.signInWithGoogle(
                    email: 'jinwoo.shadowmonarch@gmail.com',
                    displayName: 'Sung Jin-Woo',
                  );
                },
              ),

              // Quick Google Profile 2
              _buildGoogleAccountOption(
                name: 'Hunter Candidate',
                email: 'hunter.solo@gmail.com',
                avatarChar: 'H',
                color: Colors.teal,
                onTap: () {
                  Navigator.pop(ctx);
                  widget.state.signInWithGoogle(
                    email: 'hunter.solo@gmail.com',
                    displayName: 'Hunter Candidate',
                  );
                },
              ),

              // Custom Gmail Input
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person_add_alt_1, color: SystemColors.cyanGlow, size: 20),
                ),
                title: Text(
                  'Use another Gmail account',
                  style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Text(
                  'Enter your own Gmail address',
                  style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCustomGoogleInputDialog();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showCustomGoogleInputDialog() {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SystemColors.panelBg,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: SystemColors.cyanGlow, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        title: Text(
          'GOOGLE ACCOUNT LOGIN',
          style: GoogleFonts.orbitron(color: SystemColors.cyanGlow, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: GoogleFonts.rajdhani(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Google Display Name', hintText: 'e.g. Jin-Woo'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.rajdhani(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Gmail Address', hintText: 'e.g. hunter@gmail.com'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.orbitron(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SystemColors.cyanGlow, foregroundColor: Colors.black),
            onPressed: () {
              final em = emailCtrl.text.trim();
              final nm = nameCtrl.text.trim();
              if (em.isNotEmpty) {
                Navigator.pop(ctx);
                widget.state.signInWithGoogle(
                  email: em,
                  displayName: nm.isEmpty ? 'Google Hunter' : nm,
                );
              }
            },
            child: Text('VERIFY & LOGIN', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleAccountOption({
    required String name,
    required String email,
    required String avatarChar,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(avatarChar, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      title: Text(
        name,
        style: GoogleFonts.orbitron(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        email,
        style: GoogleFonts.rajdhani(color: SystemColors.textSecondary, fontSize: 12),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final registeredAccounts = state.accounts;

    return Scaffold(
      backgroundColor: SystemColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // System Seal & Logo Header
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SystemColors.cyanGlow.withValues(alpha: 0.12),
                        border: Border.all(color: SystemColors.cyanGlow, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: SystemColors.cyanGlow.withValues(alpha: 0.4),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.shield_outlined, color: SystemColors.cyanGlow, size: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // System Title
                  Center(
                    child: Text(
                      'THE SYSTEM',
                      style: GoogleFonts.orbitron(
                        color: SystemColors.cyanGlow,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'HUNTER IDENTIFICATION',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Synchronize protocol progress across Google, Gmail, or Guest mode.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                        color: SystemColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error Banner
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: SystemColors.crimsonGlow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: SystemColors.crimsonGlow, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: SystemColors.crimsonGlow, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.rajdhani(color: SystemColors.crimsonGlow, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Main Card Container with Holographic Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: SystemColors.panelBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: SystemColors.cyanGlow.withValues(alpha: 0.4), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: SystemColors.cyanGlow.withValues(alpha: 0.1),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Tab Selector (Sign In vs Register)
                        TabBar(
                          controller: _tabController,
                          indicatorColor: SystemColors.cyanGlow,
                          indicatorWeight: 3,
                          labelColor: SystemColors.cyanGlow,
                          unselectedLabelColor: Colors.white54,
                          labelStyle: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          tabs: const [
                            Tab(text: 'SIGN IN'),
                            Tab(text: 'REGISTER PROTOCOL'),
                          ],
                        ),

                        // Form Body
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: SizedBox(
                            height: 235,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // Tab 1: Sign In
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextField(
                                      controller: _signInEmailCtrl,
                                      style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 15),
                                      decoration: InputDecoration(
                                        labelText: 'Gmail / Email Address',
                                        hintText: 'e.g. yourname@gmail.com',
                                        prefixIcon: const Icon(Icons.email_outlined, color: SystemColors.cyanGlow, size: 18),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _signInPassCtrl,
                                      obscureText: _obscureSignInPass,
                                      style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 15),
                                      decoration: InputDecoration(
                                        labelText: 'Hunter Passcode',
                                        prefixIcon: const Icon(Icons.lock_outline, color: SystemColors.cyanGlow, size: 18),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscureSignInPass ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 18),
                                          onPressed: () => setState(() => _obscureSignInPass = !_obscureSignInPass),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _signInEmailCtrl.text = 'monarch@hunter.system';
                                          _signInPassCtrl.text = 'shadow123';
                                        });
                                      },
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                                          child: Text(
                                            '⚡ Fill Demo (monarch@hunter.system)',
                                            style: GoogleFonts.rajdhani(color: SystemColors.cyanGlow, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: SystemColors.cyanGlow,
                                          foregroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        onPressed: _isLoading ? null : _handleSignIn,
                                        child: _isLoading
                                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                                            : Text('AUTHENTICATE & ENTER', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),

                                // Tab 2: Register Protocol
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextField(
                                      controller: _signUpNameCtrl,
                                      style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 15),
                                      decoration: InputDecoration(
                                        labelText: 'Hunter Codename (e.g. Sung Jin-Woo)',
                                        prefixIcon: const Icon(Icons.badge_outlined, color: SystemColors.cyanGlow, size: 18),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _signUpEmailCtrl,
                                      style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 15),
                                      decoration: InputDecoration(
                                        labelText: 'Gmail / Email Address',
                                        hintText: 'e.g. yourname@gmail.com',
                                        prefixIcon: const Icon(Icons.email_outlined, color: SystemColors.cyanGlow, size: 18),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _signUpPassCtrl,
                                      obscureText: _obscureSignUpPass,
                                      style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 15),
                                      decoration: InputDecoration(
                                        labelText: 'Security Passcode (min 4 chars)',
                                        prefixIcon: const Icon(Icons.lock_outline, color: SystemColors.cyanGlow, size: 18),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscureSignUpPass ? Icons.visibility_off : Icons.visibility, color: Colors.white38, size: 18),
                                          onPressed: () => setState(() => _obscureSignUpPass = !_obscureSignUpPass),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: SystemColors.monarchViolet,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        onPressed: _isLoading ? null : _handleSignUp,
                                        child: _isLoading
                                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                            : Text('REGISTER NEW HUNTER', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 16),

                  // Divider OR
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR CONNECT VIA', style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Google Sign In Button
                  InkWell(
                    onTap: _isLoading ? null : _handleGoogleSignIn,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white30, width: 1.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Text('G', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'CONTINUE WITH GOOGLE',
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Guest Awakening Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: SystemColors.hpGreen.withValues(alpha: 0.6), width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => widget.state.signInAsGuest(),
                    icon: const Icon(Icons.person_outline, color: SystemColors.hpGreen, size: 18),
                    label: Text(
                      'ENTER AS GUEST HUNTER',
                      style: GoogleFonts.orbitron(
                        color: SystemColors.hpGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  // Quick Switch to Existing Stored Accounts
                  if (registeredAccounts.length > 1) ...[
                    const SizedBox(height: 20),
                    Text(
                      'SAVED HUNTER IDENTITIES ON THIS DEVICE:',
                      style: GoogleFonts.orbitron(color: SystemColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: registeredAccounts.map((acc) {
                        return InkWell(
                          onTap: () => widget.state.switchAccount(acc.id),
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: SystemColors.cyanGlow.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(acc.provider.icon, style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 6),
                                Text(
                                  acc.displayName,
                                  style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
