import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';

enum _ProfileMenuAction {
  editProfile,
  beProvider,
  upgradeToPremium,
  about,
  logout,
}

// Displays the logged-in user's profile with editable name, photo URL,
// and service category when role is provider.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _serviceCategories = const [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Tailoring',
    'Tutoring',
    'Cleaning',
    'Painting',
    'Gardening',
    'Appliance Repair',
    'Beauty Services',
  ];

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _redirectIfSignedOut();
  }

  void _redirectIfSignedOut() {
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/authentication-screen',
          (route) => false,
        );
      });
    }
  }

  Future<void> _handleLogout() async {
    try {
      await Future.wait([
        GoogleSignIn().signOut(),
        FacebookAuth.instance.logOut(),
        FirebaseAuth.instance.signOut(),
      ]);
    } catch (_) {
      // Best-effort sign-out
    }

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/authentication-screen',
      (route) => false,
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'GebeyaNow',
      applicationLegalese: 'Local services marketplace',
    );
  }

  Future<void> _saveProfile({
    required String name,
    String? serviceCategory,
    String? photoUrl,
  }) async {
    final user = _user;
    if (user == null) return;

    await Future.wait([
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'serviceCategory': serviceCategory,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
      user.updateDisplayName(name.trim()),
      if (photoUrl != null && photoUrl.isNotEmpty)
        user.updatePhotoURL(photoUrl),
    ]);
  }

  Future<void> _showEditSheet(Map<String, dynamic> data) async {
    final theme = Theme.of(context);
    final role = (data['role'] as String?) ?? 'customer';
    final nameController = TextEditingController(
      text: data['name'] as String? ?? '',
    );
    final photoController = TextEditingController(
      text: data['photoUrl'] as String? ?? _user?.photoURL ?? '',
    );
    String? selectedCategory = data['serviceCategory'] as String?;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: photoController,
                decoration: const InputDecoration(
                  labelText: 'Photo URL',
                  hintText: 'Paste an image URL',
                ),
              ),
              const SizedBox(height: 16),
              if (role == 'provider') ...[
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Service Category',
                  ),
                  items: _serviceCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) => selectedCategory = value,
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name cannot be empty')),
                      );
                      return;
                    }
                    await _saveProfile(
                      name: name,
                      serviceCategory: role == 'provider'
                          ? selectedCategory
                          : data['serviceCategory'] as String?,
                      photoUrl: photoController.text.trim(),
                    );
                    if (!mounted || !ctx.mounted) return;
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: theme.colorScheme.primary),
            SizedBox(width: 3.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not set' : value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final theme = Theme.of(context);

    if (user == null) {
      return const SizedBox.shrink();
    }

    final docStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docStream,
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? {};
        final name = data['name'] as String? ?? user.displayName ?? '';
        final email = user.email ?? data['email'] as String? ?? '';
        final phone = data['phone'] as String? ?? user.phoneNumber ?? '';
        final role = data['role'] as String? ?? 'customer';
        final providerApplicationStatusRaw =
            (data['providerApplicationStatus'] as String?);
        final providerApplicationStatus = providerApplicationStatusRaw
            ?.trim()
            .toLowerCase();
        final isPendingVerification = providerApplicationStatus == 'pending';
        final isVerifiedProvider = role == 'provider';
        final serviceCategory = data['serviceCategory'] as String? ?? '';
        final photoUrl = data['photoUrl'] as String? ?? user.photoURL ?? '';
        final createdAt = data['createdAt'];

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: CustomAppBar(
            title: 'Profile',
            variant: CustomAppBarVariant.standard,
            actions: [
              PopupMenuButton<_ProfileMenuAction>(
                icon: Icon(Icons.menu, color: theme.colorScheme.onSurface),
                onSelected: (action) async {
                  switch (action) {
                    case _ProfileMenuAction.editProfile:
                      await _showEditSheet(data);
                      break;
                    case _ProfileMenuAction.beProvider:
                      Navigator.pushNamed(
                        context,
                        '/provider-registration-screen',
                      );
                      break;
                    case _ProfileMenuAction.upgradeToPremium:
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Premium upgrade coming soon'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      break;
                    case _ProfileMenuAction.about:
                      _showAbout();
                      break;
                    case _ProfileMenuAction.logout:
                      await _handleLogout();
                      break;
                  }
                },
                itemBuilder: (context) {
                  return <PopupMenuEntry<_ProfileMenuAction>>[
                    const PopupMenuItem<_ProfileMenuAction>(
                      value: _ProfileMenuAction.editProfile,
                      child: Text('Edit profile'),
                    ),
                    if (role != 'provider')
                      const PopupMenuItem<_ProfileMenuAction>(
                        value: _ProfileMenuAction.beProvider,
                        child: Text('Be provider'),
                      ),
                    if (isVerifiedProvider)
                      const PopupMenuItem<_ProfileMenuAction>(
                        value: _ProfileMenuAction.upgradeToPremium,
                        child: Text('Upgrade to premium'),
                      ),
                    const PopupMenuItem<_ProfileMenuAction>(
                      value: _ProfileMenuAction.about,
                      child: Text('About'),
                    ),
                    const PopupMenuItem<_ProfileMenuAction>(
                      value: _ProfileMenuAction.logout,
                      child: Text('Logout'),
                    ),
                  ];
                },
              ),
              SizedBox(width: 2.w),
            ],
          ),
          body: SafeArea(
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 3.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: theme.colorScheme.primary,
                                backgroundImage: photoUrl.isNotEmpty
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: photoUrl.isEmpty
                                    ? Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : 'U',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      )
                                    : null,
                              ),
                              SizedBox(height: 1.5.h),
                              Text(
                                name.isEmpty ? 'Your Name' : name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (isPendingVerification || isVerifiedProvider)
                                Padding(
                                  padding: EdgeInsets.only(top: 0.75.h),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isVerifiedProvider
                                            ? Icons.verified
                                            : Icons.hourglass_top,
                                        size: 16,
                                        color: isVerifiedProvider
                                            ? theme.colorScheme.primary
                                            : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        isVerifiedProvider
                                            ? 'Verified provider'
                                            : 'Pending verification',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: isVerifiedProvider
                                                  ? theme.colorScheme.primary
                                                  : theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(height: 0.5.h),
                              Text(
                                role == 'provider'
                                    ? 'Service Provider'
                                    : 'Customer',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 3.h),
                        _buildInfoRow(
                          label: 'Email',
                          value: email,
                          icon: Icons.email_outlined,
                        ),
                        _buildInfoRow(
                          label: 'Phone',
                          value: phone,
                          icon: Icons.phone_outlined,
                        ),
                        _buildInfoRow(
                          label: 'Full Name',
                          value: name,
                          icon: Icons.person_outline,
                        ),
                        _buildInfoRow(
                          label: 'Role',
                          value: role,
                          icon: Icons.verified_user_outlined,
                        ),
                        if (role == 'provider')
                          _buildInfoRow(
                            label: 'Service Category',
                            value: serviceCategory,
                            icon: Icons.work_outline,
                          ),
                        if (createdAt is Timestamp)
                          _buildInfoRow(
                            label: 'Member since',
                            value: createdAt
                                .toDate()
                                .toLocal()
                                .toString()
                                .split(' ')
                                .first,
                            icon: Icons.calendar_today_outlined,
                          ),
                        SizedBox(height: 3.h),
                      ],
                    ),
                  ),
          ),
          bottomNavigationBar: CustomBottomBar(
            currentIndex: 3,
            onTap: (index) {
              if (index == 3) return;
              const routes = [
                '/service-categories-screen',
                '/provider-list-screen',
                '/provider-list-screen',
                '/profile-screen',
              ];
              final route = (index >= 0 && index < routes.length)
                  ? routes[index]
                  : '/service-categories-screen';
              Navigator.pushReplacementNamed(context, route);
            },
          ),
        );
      },
    );
  }
}
