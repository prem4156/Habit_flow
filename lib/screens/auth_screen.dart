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
      final success = await widget.state.signInWithGoogle(tryDeviceAuth: true);
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (!success && !widget.state.isAuthenticated) {
        _promptGmailConnectDialog();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _promptGmailConnectDialog();
    }
  }

  void _promptGmailConnectDialog() {
    final TextEditingController gmailCtrl = TextEditingController(
      text: _signInEmailCtrl.text.isNotEmpty ? _signInEmailCtrl.text : '',
    );
    final TextEditingController nameCtrl = TextEditingController(
      text: _signUpNameCtrl.text.isNotEmpty ? _signUpNameCtrl.text : '',
    );
    String? dialogError;

    final accent = SystemTheme.getPrimaryAccent(context);
    final textPrimary = SystemTheme.getTextPrimary(context);
    final textSecondary = SystemTheme.getTextSecondary(context);

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: SystemTheme.getPanelBg(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: accent, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'G',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'CONNECT GMAIL ACCOUNT',
                  style: GoogleFonts.orbitron(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your Google / Gmail account to synchronize directly with the System:',
                  style: GoogleFonts.rajdhani(
                    color: textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: gmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Gmail Address',
                    hintText: 'hunter@gmail.com',
                    prefixIcon: Icon(Icons.email_outlined, color: accent, size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Hunter Name (Optional)',
                    hintText: 'Sung Jin-Woo',
                    prefixIcon: Icon(Icons.badge_outlined, color: accent, size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    dialogError!,
                    style: GoogleFonts.rajdhani(
                      color: SystemTheme.getCrimsonAccent(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'CANCEL',
                style: GoogleFonts.orbitron(color: textSecondary, fontSize: 11),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final emailText = gmailCtrl.text.trim();
                if (emailText.isEmpty || !emailText.contains('@')) {
                  setDialogState(() {
                    dialogError = 'Please enter a valid Gmail address.';
                  });
                  return;
                }
                Navigator.of(dialogCtx).pop();

                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });

                final success = await widget.state.signInWithGoogle(
                  email: emailText,
                  displayName: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : null,
                  tryDeviceAuth: false,
                );

                if (!mounted) return;
                setState(() {
                  _isLoading = false;
                  if (!success && !widget.state.isAuthenticated) {
                    _errorMessage = 'Failed to connect Gmail account.';
                  }
                });
              },
              child: Text(
                'SYNC GMAIL',
                style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final registeredAccounts = state.accounts;
    final isDark = SystemTheme.isDark(context);
    final accent = SystemTheme.getPrimaryAccent(context);
    final textPrimary = SystemTheme.getTextPrimary(context);
    final textSecondary = SystemTheme.getTextSecondary(context);

    return Scaffold(
      backgroundColor: SystemTheme.getBackground(context),
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
                        color: accent.withValues(alpha: isDark ? 0.12 : 0.1),
                        border: Border.all(color: accent, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: isDark ? 0.4 : 0.2),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(Icons.shield_outlined, color: accent, size: 32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // System Title
                  Center(
                    child: Text(
                      'THE SYSTEM',
                      style: GoogleFonts.orbitron(
                        color: accent,
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
                        color: textPrimary,
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
                        color: textSecondary,
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
                        color: SystemTheme.getCrimsonAccent(context).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: SystemTheme.getCrimsonAccent(context), width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: SystemTheme.getCrimsonAccent(context), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.rajdhani(color: SystemTheme.getCrimsonAccent(context), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Main Card Container with Holographic Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: SystemTheme.getPanelBg(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accent.withValues(alpha: isDark ? 0.4 : 0.5), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: isDark ? 0.1 : 0.08),
                          blurRadius: 16,
                        ),
                        if (!isDark)
                          const BoxShadow(
                            color: Color(0x0A0F172A),
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Tab Selector (Sign In vs Register)
                        TabBar(
                          controller: _tabController,
                          indicatorColor: accent,
                          indicatorWeight: 3,
                          labelColor: accent,
                          unselectedLabelColor: isDark ? Colors.white54 : SystemTheme.getTextMuted(context),
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
                                      style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 15),
                                      decoration: InputDecoration(
                                        labelText: 'Gmail / Email Address',
                                        hintText: 'e.g. yourname@gmail.com',
                                        prefixIcon: Icon(Icons.email_outlined, color: accent, size: 18),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _signInPassCtrl,
                                      obscureText: _obscureSignInPass,
                                      style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 15),
                                      decoration: InputDecoration(
                                        labelText: 'Hunter Passcode',
                                        prefixIcon: Icon(Icons.lock_outline, color: accent, size: 18),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscureSignInPass ? Icons.visibility_off : Icons.visibility, color: SystemTheme.getTextMuted(context), size: 18),
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
                                            style: GoogleFonts.rajdhani(color: accent, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accent,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        onPressed: _isLoading ? null : _handleSignIn,
                                        child: _isLoading
                                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
                                      style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 15),
                                      decoration: InputDecoration(
                                        labelText: 'Hunter Codename (e.g. Sung Jin-Woo)',
                                        prefixIcon: Icon(Icons.badge_outlined, color: accent, size: 18),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _signUpEmailCtrl,
                                      style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 15),
                                      decoration: InputDecoration(
                                        labelText: 'Gmail / Email Address',
                                        hintText: 'e.g. yourname@gmail.com',
                                        prefixIcon: Icon(Icons.email_outlined, color: accent, size: 18),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _signUpPassCtrl,
                                      obscureText: _obscureSignUpPass,
                                      style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 15),
                                      decoration: InputDecoration(
                                        labelText: 'Security Passcode (min 4 chars)',
                                        prefixIcon: Icon(Icons.lock_outline, color: accent, size: 18),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscureSignUpPass ? Icons.visibility_off : Icons.visibility, color: SystemTheme.getTextMuted(context), size: 18),
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
                                          backgroundColor: SystemTheme.getPurpleAccent(context),
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
                      Expanded(child: Divider(color: SystemTheme.getPanelBorder(context))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('OR CONNECT VIA', style: GoogleFonts.orbitron(color: SystemTheme.getTextMuted(context), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider(color: SystemTheme.getPanelBorder(context))),
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
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? Colors.white30 : SystemColors.lightPanelBorder, width: 1.0),
                        boxShadow: [
                          if (!isDark)
                            const BoxShadow(
                              color: Color(0x0A0F172A),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                        ],
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
                              color: textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: TextButton.icon(
                      onPressed: _isLoading ? null : _promptGmailConnectDialog,
                      icon: Icon(Icons.alternate_email, color: accent, size: 14),
                      label: Text(
                        'ENTER GMAIL DIRECTLY',
                        style: GoogleFonts.orbitron(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Guest Awakening Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: SystemTheme.getGreenAccent(context).withValues(alpha: 0.7), width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => widget.state.signInAsGuest(),
                    icon: Icon(Icons.person_outline, color: SystemTheme.getGreenAccent(context), size: 18),
                    label: Text(
                      'ENTER AS GUEST HUNTER',
                      style: GoogleFonts.orbitron(
                        color: SystemTheme.getGreenAccent(context),
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
                      style: GoogleFonts.orbitron(color: SystemTheme.getTextMuted(context), fontSize: 10, fontWeight: FontWeight.bold),
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
                              color: isDark ? Colors.black45 : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: accent.withValues(alpha: isDark ? 0.3 : 0.5)),
                              boxShadow: [
                                if (!isDark)
                                  const BoxShadow(
                                    color: Color(0x060F172A),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(acc.provider.icon, style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 6),
                                Text(
                                  acc.displayName,
                                  style: GoogleFonts.rajdhani(color: textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
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
