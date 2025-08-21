import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'dart:io';
import '../../models/chat_profile.dart';
import '../../services/storage/chat_profile_service.dart';

class UserProfileCustomizationDialog extends StatefulWidget {
  final ChatUserProfile initialProfile;
  final Function(ChatUserProfile) onProfileUpdated;

  const UserProfileCustomizationDialog({
    super.key,
    required this.initialProfile,
    required this.onProfileUpdated,
  });

  @override
  State<UserProfileCustomizationDialog> createState() =>
      _UserProfileCustomizationDialogState();
}

class _UserProfileCustomizationDialogState
    extends State<UserProfileCustomizationDialog> {
  late TextEditingController _usernameController;
  String? _avatarUrl;
  bool _isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.initialProfile.username,
    );
    _avatarUrl = widget.initialProfile.avatarUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(l10n.takePhoto),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.chooseFromGallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
    );

    if (source != null) {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _avatarUrl = pickedFile.path;
        });
      }
    }
  }

  void _removeAvatar() {
    setState(() {
      _avatarUrl = null;
    });
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;

    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.requiredField)));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedProfile = widget.initialProfile.copyWith(
        username: _usernameController.text.trim(),
        avatarUrl: _avatarUrl,
        lastUpdated: DateTime.now(),
      );

      final success = await ChatProfileService.saveUserProfile(updatedProfile);

      if (success && mounted) {
        widget.onProfileUpdated(updatedProfile);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profileSaveFailed)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.profileSaveFailed)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAvatarSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 2,
              ),
            ),
            child:
                _avatarUrl != null
                    ? ClipOval(
                      child:
                          _avatarUrl!.startsWith('http')
                              ? Image.network(
                                _avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        _buildDefaultAvatar(),
                              )
                              : Image.file(
                                File(_avatarUrl!),
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        _buildDefaultAvatar(),
                              ),
                    )
                    : _buildDefaultAvatar(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt, size: 18),
              label: Text(l10n.changeAvatar),
            ),
            if (_avatarUrl != null) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _removeAvatar,
                icon: const Icon(Icons.delete, size: 18),
                label: Text(l10n.removeAvatar),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 40,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.editUserProfile),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: l10n.username,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _saveProfile(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          child:
              _isLoading
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                  : Text(l10n.save),
        ),
      ],
    );
  }
}
