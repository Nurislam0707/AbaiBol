import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/monogram_avatar.dart';
import '../../providers/profile_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _avatarLocalPath;
  String? _coverLocalPath;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    
    // Initialize with current data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profile = await ref.read(currentUserProfileProvider.future);
      _nameController.text = profile.displayName;
      _bioController.text = profile.bio ?? '';
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _avatarLocalPath = image.path);
    }
  }

  Future<void> _pickCover() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _coverLocalPath = image.path);
    }
  }

  Future<void> _save() async {
    final strings = ref.read(appStringsProvider);
    
    await ref.read(profileEditProvider.notifier).updateProfile(
      displayName: _nameController.text,
      bio: _bioController.text,
      // Note: In a real app, we would upload to Supabase Storage first
      // and use the resulting URL. For now we pass local paths as placeholders
      // if they exist, or keep existing ones.
      avatarUrl: _avatarLocalPath, 
      coverUrl: _coverLocalPath,
    );

    if (mounted) {
      final state = ref.read(profileEditProvider);
      if (state.error == null) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = ref.watch(appStringsProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final editState = ref.watch(profileEditProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => context.pop(),
          child: Text(strings.cancel, style: TextStyle(color: theme.colorScheme.onSurface)),
        ),
        leadingWidth: 80,
        title: Text(
          strings.editProfile,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: editState.isSaving ? null : _save,
            child: editState.isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    strings.save,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: profileAsync.when(
        data: (profile) => SingleChildScrollView(
          child: Column(
            children: [
              // Cover Photo Area
              GestureDetector(
                onTap: _pickCover,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_coverLocalPath != null)
                        Image.file(File(_coverLocalPath!), fit: BoxFit.cover)
                      else if (profile.coverUrl != null && profile.coverUrl!.isNotEmpty)
                        _buildHeaderImage(profile.coverUrl!)
                      else
                        const Center(child: Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey)),
                      
                      // Overlay for indication
                      Container(color: Colors.black.withValues(alpha: 0.2)),
                      Center(
                        child: Text(
                          strings.changeCover,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Avatar Area (Overlapping the cover slightly)
              Transform.translate(
                offset: const Offset(0, -50),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.surface, width: 4),
                            ),
                            child: _avatarLocalPath != null
                                ? CircleAvatar(
                                    radius: 50,
                                    backgroundImage: FileImage(File(_avatarLocalPath!)),
                                  )
                                : MonogramAvatar(
                                    seedText: profile.displayName,
                                    imageUrl: profile.avatarUrl,
                                    size: 100,
                                    isCircle: true,
                                    showShadow: false,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.colorScheme.surface, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.changePhoto,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildTextField(
                      label: strings.displayName,
                      controller: _nameController,
                      theme: theme,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: strings.biography,
                      controller: _bioController,
                      theme: theme,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ThemeData theme,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    return Image.asset(path, fit: BoxFit.cover);
  }
}
