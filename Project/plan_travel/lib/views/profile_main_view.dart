import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'profile_info_view.dart';
import 'profile_edit_view.dart';

class ProfileMainView extends StatefulWidget {
  const ProfileMainView({super.key});

  @override
  State<ProfileMainView> createState() => _ProfileMainViewState();
}

class _ProfileMainViewState extends State<ProfileMainView> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? "แก้ไขโปรไฟล์" : "โปรไฟล์ของฉัน"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, child) {
          final profile = vm.profile;
          
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isEditing
                ? ProfileEditView(
                    currentProfile: profile,
                    onSave: (nickname, photoUrl) async {
                      await vm.saveProfile(
                        nickname: nickname, 
                        photoUrl: photoUrl,
                      );
                      setState(() => _isEditing = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('บันทึกข้อมูลลง Cloud สำเร็จ'), backgroundColor: Colors.green),
                        );
                      }
                    },
                    onCancel: () => setState(() => _isEditing = false),
                  )
                : ProfileInfoView(
                    profile: profile,
                    onEdit: () => setState(() => _isEditing = true),
                  ),
          );
        },
      ),
    );
  }
}
