import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/resume_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _linkedInController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().firebaseUser;
    _nameController = TextEditingController(
      text: user?.displayName ?? 'Alex Doe',
    );
    _emailController = TextEditingController(
      text: user?.email ?? 'alex.doe@email.com',
    );
    _phoneController = TextEditingController(text: '+1 (123) 456-7890');
    _linkedInController = TextEditingController(
      text: 'linkedin.com/in/alexdoe',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _linkedInController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final user = authProvider.firebaseUser;
            final memberSince = user?.metadata.creationTime;
            final memberSinceText = memberSince != null
                ? 'Member since ${_formatMemberDate(memberSince)}'
                : 'Member since Feb 2024';

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Custom App Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 12, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back Button
                          IconButton(
                            icon: Icon(
                              Icons.chevron_left_rounded,
                              size: 32,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          // Title
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          // Save Button
                          GestureDetector(
                            onTap: _saveProfile,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile Photo
                    Stack(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGreen,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child:
                                user?.photoURL != null &&
                                    user!.photoURL!.isNotEmpty
                                ? Image.network(
                                    user.photoURL!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildDefaultAvatar(isDark),
                                  )
                                : _buildDefaultAvatar(isDark),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: bgColor, width: 3),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 14,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Name
                    Text(
                      user?.displayName ?? 'Alex Doe',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Member Since
                    Text(
                      memberSinceText,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Personal Information Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('PERSONAL INFORMATION', isDark),
                          const SizedBox(height: 10),
                          _buildInfoCard(isDark, [
                            _buildInfoRow('Name', _nameController, isDark),
                            _buildDivider(isDark),
                            _buildInfoRow(
                              'Email',
                              _emailController,
                              isDark,
                              enabled: false,
                            ),
                            _buildDivider(isDark),
                            _buildInfoRow('Phone', _phoneController, isDark),
                            _buildDivider(isDark),
                            _buildInfoRow(
                              'LinkedIn',
                              _linkedInController,
                              isDark,
                            ),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Appearance Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('APPEARANCE', isDark),
                          const SizedBox(height: 10),
                          _buildAppearanceCard(isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Manage Resumes Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionHeader('MANAGE RESUMES', isDark),
                              GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Resume upload coming soon!',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        size: 16,
                                        color: AppColors.primaryDark,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Upload',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Consumer<ResumeProvider>(
                            builder: (context, resumeProvider, _) {
                              // Always show mock data for design purposes
                              return Column(
                                children: [
                                  _buildResumeCard(
                                    name: 'Software_Engineer_Resume.pdf',
                                    date: 'July 15, 2024',
                                    isDefault: true,
                                    isDark: isDark,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildResumeCard(
                                    name: 'Design_Portfolio_2024.pdf',
                                    date: 'June 02, 2024',
                                    isDefault: false,
                                    isDark: isDark,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(bool isDark) {
    return Container(
      color: const Color(0xFFE8D5C4),
      child: Center(
        child: Icon(Icons.person, size: 50, color: Colors.brown[300]),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white54 : Colors.black45,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    String label,
    TextEditingController controller,
    bool isDark, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      height: 0.5,
      color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08),
    );
  }

  Widget _buildAppearanceCard(bool isDark) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildThemeOption(
                  label: 'Light',
                  icon: Icons.light_mode_rounded,
                  isSelected: themeProvider.themeMode == ThemeMode.light,
                  isDark: isDark,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildThemeOption(
                  label: 'Dark',
                  icon: Icons.dark_mode_rounded,
                  isSelected: themeProvider.themeMode == ThemeMode.dark,
                  isDark: isDark,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildThemeOption(
                  label: 'System',
                  icon: Icons.settings_suggest_rounded,
                  isSelected: themeProvider.themeMode == ThemeMode.system,
                  isDark: isDark,
                  onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : (isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primaryDark
                  : (isDark ? Colors.white60 : Colors.black54),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryDark
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeCard({
    required String name,
    required String date,
    required bool isDefault,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            child: Row(
              children: [
                // File Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBackground
                        : const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                // File Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Added $date',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                // More Options
                Icon(
                  Icons.more_horiz,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ],
            ),
          ),
          // Divider
          Container(
            height: 0.5,
            color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08),
          ),
          // Default Toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isDefault ? 'Default for applications' : 'Set as default',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: isDefault,
                    onChanged: (value) {},
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primaryGreen,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: isDark
                        ? Colors.white24
                        : Colors.black12,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMemberDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
