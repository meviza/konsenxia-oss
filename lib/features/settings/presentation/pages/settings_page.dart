import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/cubits/theme_cubit.dart';
import '../../../../core/cubits/locale_cubit.dart';
import '../../../../design_system/design_system.dart';

/// KONSENXIA — Ayarlar
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Notification toggles
  bool _caseNotifs    = true;
  bool _messageNotifs = true;
  bool _leaderNotifs  = false;
  bool _systemNotifs  = true;

  // Privacy toggles
  bool _profileVisible = true;
  bool _activityVisible = false;

  // Appearance
  String _language = 'Türkçe';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Firestore ve SharedPreferences'dan mevcut ayarlari yukle
  Future<void> _loadSettings() async {
    // Locale cubit'ten dil al
    if (mounted) {
      final localeCubit = context.read<LocaleCubit>();
      _language = localeCubit.isTurkish ? 'Türkçe' : 'English';
    }

    // Firestore'dan kullanici ayarlarini yukle
    final uid = _currentUid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _profileVisible = data['isProfilePublic'] as bool? ?? true;
          _activityVisible = data['isActivityVisible'] as bool? ?? false;
          _caseNotifs = data['notifications']?['case'] as bool? ?? true;
          _messageNotifs = data['notifications']?['message'] as bool? ?? true;
          _leaderNotifs = data['notifications']?['leaderboard'] as bool? ?? false;
          _systemNotifs = data['notifications']?['system'] as bool? ?? true;
        });
      }
    } catch (_) {
      // Offline veya hata — varsayilan degerlerle devam et
    }
  }

  String? get _currentUid {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) return authState.user.id;
    return fb_auth.FirebaseAuth.instance.currentUser?.uid;
  }

  // ── Snackbar yardimcilari ────────────────────────────────────

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded,
              color: KxColors.jade300, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: KxTypography.bodyMd
                    .copyWith(color: KxColors.textPrimary)),
          ),
        ]),
        backgroundColor: KxColors.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: KxSpacing.radiusMd,
          side: BorderSide(color: KxColors.jade300.withOpacity(0.3)),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline_rounded,
              color: KxColors.crimson300, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: KxTypography.bodyMd
                    .copyWith(color: KxColors.textPrimary)),
          ),
        ]),
        backgroundColor: KxColors.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: KxSpacing.radiusMd,
          side: BorderSide(color: KxColors.crimson300.withOpacity(0.3)),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── 1. Profili Duzenle ───────────────────────────────────────

  void _showEditProfileSheet() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;

    final firstNameCtrl = TextEditingController(text: user.firstName);
    final lastNameCtrl = TextEditingController(text: user.lastName);
    final specialtyCtrl = TextEditingController();
    final bioCtrl = TextEditingController();
    final institutionCtrl = TextEditingController();

    // Firestore'dan ek alanlari yukle
    final uid = _currentUid;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          final data = doc.data()!;
          specialtyCtrl.text = data['specialty'] as String? ?? '';
          bioCtrl.text = data['biography'] as String? ?? '';
          institutionCtrl.text = data['institution'] as String? ?? '';
        }
      }).catchError((_) {});
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: KxColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: KxColors.textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Profili Düzenle',
                        style: KxTypography.headingMd),
                    const SizedBox(height: 20),
                    KxTextField(
                      label: 'Ad',
                      controller: firstNameCtrl,
                      hint: 'Adınız',
                    ),
                    const SizedBox(height: 14),
                    KxTextField(
                      label: 'Soyad',
                      controller: lastNameCtrl,
                      hint: 'Soyadınız',
                    ),
                    const SizedBox(height: 14),
                    KxTextField(
                      label: 'Uzmanlık',
                      controller: specialtyCtrl,
                      hint: 'Kardiyoloji, Nöroloji...',
                    ),
                    const SizedBox(height: 14),
                    KxTextField(
                      label: 'Biyografi',
                      controller: bioCtrl,
                      hint: 'Kısa biyografiniz...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),
                    KxTextField(
                      label: 'Kurum',
                      controller: institutionCtrl,
                      hint: 'Çalıştığınız hastane/üniversite',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: KxButton(
                        label: 'Kaydet',
                        isLoading: saving,
                        onPressed: saving
                            ? null
                            : () async {
                                setSheetState(() => saving = true);
                                try {
                                  final uid = _currentUid;
                                  if (uid != null) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .set({
                                      'firstName': firstNameCtrl.text.trim(),
                                      'lastName': lastNameCtrl.text.trim(),
                                      'specialty': specialtyCtrl.text.trim(),
                                      'biography': bioCtrl.text.trim(),
                                      'institution':
                                          institutionCtrl.text.trim(),
                                      'updatedAt':
                                          FieldValue.serverTimestamp(),
                                    }, SetOptions(merge: true));
                                  }
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  _showSuccess('Profil güncellendi');
                                } catch (e) {
                                  setSheetState(() => saving = false);
                                  _showError(
                                      'Profil güncellenemedi: ${e.toString()}');
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── 2. Kimlik Dogrulama ──────────────────────────────────────

  void _showVerificationStatus() {
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
    final emailVerified = fbUser?.emailVerified ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: KxColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool sendingEmail = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: KxColors.textMuted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Kimlik Doğrulama Durumu',
                      style: KxTypography.headingMd),
                  const SizedBox(height: 20),

                  // E-posta dogrulama
                  _VerificationRow(
                    icon: Icons.email_rounded,
                    label: 'E-posta Doğrulama',
                    isVerified: emailVerified,
                    detail: fbUser?.email ?? 'Bilinmiyor',
                  ),
                  const SizedBox(height: 12),

                  // Doktor sertifikasi
                  FutureBuilder<DocumentSnapshot>(
                    future: _currentUid != null
                        ? FirebaseFirestore.instance
                            .collection('users')
                            .doc(_currentUid)
                            .get()
                        : null,
                    builder: (context, snapshot) {
                      final data =
                          snapshot.data?.data() as Map<String, dynamic>?;
                      final certUploaded =
                          data?['certificateUploaded'] as bool? ?? false;
                      final certUrl =
                          data?['certificateUrl'] as String? ?? '';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _VerificationRow(
                            icon: Icons.badge_rounded,
                            label: 'Doktor Sertifikası',
                            isVerified: certUploaded,
                            detail: certUploaded
                                ? 'Yüklendi'
                                : 'Henüz yüklenmedi',
                          ),
                          if (certUploaded && certUrl.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Belge: $certUrl',
                              style: KxTypography.caption.copyWith(
                                color: KxColors.teal400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // E-posta dogrulama gonder butonu
                  if (!emailVerified && fbUser != null)
                    SizedBox(
                      width: double.infinity,
                      child: KxButton.secondary(
                        label: 'Doğrulama E-postası Gönder',
                        icon: Icons.send_rounded,
                        isLoading: sendingEmail,
                        onPressed: sendingEmail
                            ? null
                            : () async {
                                setSheetState(
                                    () => sendingEmail = true);
                                try {
                                  await fbUser
                                      .sendEmailVerification();
                                  if (ctx.mounted) {
                                    Navigator.pop(ctx);
                                  }
                                  _showSuccess(
                                      'Doğrulama e-postası gönderildi');
                                } catch (e) {
                                  setSheetState(
                                      () => sendingEmail = false);
                                  _showError(
                                      'E-posta gönderilemedi');
                                }
                              },
                      ),
                    ),

                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── 3. Sifre & Guvenlik ──────────────────────────────────────

  void _showChangePasswordDialog() {
    final currentPwCtrl = TextEditingController();
    final newPwCtrl = TextEditingController();
    final confirmPwCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        String? errorMsg;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: KxColors.bgCard,
              shape: RoundedRectangleBorder(
                  borderRadius: KxSpacing.radiusLg),
              title: Text('Şifre Değiştir',
                  style: KxTypography.headingMd),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KxTextField.password(
                      label: 'Mevcut Şifre',
                      controller: currentPwCtrl,
                    ),
                    const SizedBox(height: 14),
                    KxTextField.password(
                      label: 'Yeni Şifre',
                      controller: newPwCtrl,
                    ),
                    const SizedBox(height: 14),
                    KxTextField.password(
                      label: 'Yeni Şifre (Tekrar)',
                      controller: confirmPwCtrl,
                    ),
                    if (errorMsg != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMsg!,
                        style: KxTypography.caption
                            .copyWith(color: KxColors.crimson300),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('İptal',
                      style: KxTypography.labelSm
                          .copyWith(color: KxColors.textMuted)),
                ),
                KxButton(
                  label: 'Kaydet',
                  size: KxButtonSize.sm,
                  isLoading: saving,
                  onPressed: saving
                      ? null
                      : () async {
                          // Validasyon
                          if (newPwCtrl.text.length < 6) {
                            setDialogState(() => errorMsg =
                                'Yeni şifre en az 6 karakter olmalı');
                            return;
                          }
                          if (newPwCtrl.text != confirmPwCtrl.text) {
                            setDialogState(
                                () => errorMsg = 'Şifreler eşleşmiyor');
                            return;
                          }

                          setDialogState(() {
                            saving = true;
                            errorMsg = null;
                          });

                          try {
                            final fbUser = fb_auth
                                .FirebaseAuth.instance.currentUser;
                            if (fbUser == null || fbUser.email == null) {
                              throw Exception('Oturum açık değil');
                            }

                            // Mevcut sifre ile yeniden kimlik dogrula
                            final credential =
                                fb_auth.EmailAuthProvider.credential(
                              email: fbUser.email!,
                              password: currentPwCtrl.text,
                            );
                            await fbUser.reauthenticateWithCredential(
                                credential);

                            // Yeni sifre ayarla
                            await fbUser
                                .updatePassword(newPwCtrl.text);

                            if (ctx.mounted) Navigator.pop(ctx);
                            _showSuccess('Şifre başarıyla güncellendi');
                          } on fb_auth.FirebaseAuthException catch (e) {
                            String msg;
                            switch (e.code) {
                              case 'wrong-password':
                                msg = 'Mevcut şifre yanlış';
                                break;
                              case 'weak-password':
                                msg =
                                    'Yeni şifre çok zayıf. Daha güçlü bir şifre seçin';
                                break;
                              case 'requires-recent-login':
                                msg =
                                    'Güvenlik nedeniyle yeniden giriş yapmanız gerekiyor';
                                break;
                              default:
                                msg = 'Şifre değiştirilemedi: ${e.message}';
                            }
                            setDialogState(() {
                              saving = false;
                              errorMsg = msg;
                            });
                          } catch (e) {
                            setDialogState(() {
                              saving = false;
                              errorMsg = 'Şifre değiştirilemedi: $e';
                            });
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── 4. Bildirim kaydet ───────────────────────────────────────

  Future<void> _saveNotificationPref(String key, bool value) async {
    final uid = _currentUid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'notifications': {key: value},
      }, SetOptions(merge: true));
    } catch (_) {
      // Offline — yerel state yeterli
    }
  }

  // ── 5. Gizlilik kaydet ──────────────────────────────────────

  Future<void> _savePrivacyPref(String field, bool value) async {
    final uid = _currentUid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        field: value,
      }, SetOptions(merge: true));
      _showSuccess('Gizlilik ayarı güncellendi');
    } catch (_) {
      _showError('Ayar kaydedilemedi');
    }
  }

  // ── 6. Dil degistir ─────────────────────────────────────────

  void _onLanguageChanged(String lang) {
    setState(() => _language = lang);
    final locale = lang == 'English'
        ? const Locale('en', 'US')
        : const Locale('tr', 'TR');
    context.read<LocaleCubit>().setLocale(locale);
    _showSuccess(
        lang == 'English' ? 'Language changed to English' : 'Dil Türkçe olarak değiştirildi');
  }

  // ── 7. Tema degistir ────────────────────────────────────────

  void _showThemePicker() {
    final themeCubit = context.read<ThemeCubit>();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: KxColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusLg),
          title: Text('Tema Seçin', style: KxTypography.headingMd),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeOptionTile(
                icon: Icons.dark_mode_rounded,
                label: 'Koyu Tema',
                subtitle: 'Clinical Noir (varsayılan)',
                isSelected: themeCubit.isDark,
                onTap: () {
                  themeCubit.setTheme(ThemeMode.dark);
                  Navigator.pop(ctx);
                  _showSuccess('Koyu tema etkinleştirildi');
                },
              ),
              const SizedBox(height: 8),
              _ThemeOptionTile(
                icon: Icons.light_mode_rounded,
                label: 'Açık Tema',
                subtitle: 'Gündüz kullanımı için',
                isSelected: !themeCubit.isDark,
                onTap: () {
                  themeCubit.setTheme(ThemeMode.light);
                  Navigator.pop(ctx);
                  _showSuccess('Açık tema etkinleştirildi');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── 8. AI Sohbet Gecmisi temizle ─────────────────────────────

  void _showAIChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: KxColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: KxColors.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('AI Sohbet Geçmişi', style: KxTypography.headingMd),
              const SizedBox(height: 16),
              _NavTile(
                icon: Icons.chat_rounded,
                label: 'Konuşmaları Görüntüle',
                subtitle: 'Tüm AI sohbetlerinizi açın',
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/ai-chat');
                },
              ),
              Container(height: 1, color: KxColors.border),
              _NavTile(
                icon: Icons.delete_outline_rounded,
                label: 'Geçmişi Temizle',
                subtitle: 'Tüm AI sohbet geçmişini sil',
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmClearChatHistory();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _confirmClearChatHistory() {
    showDialog(
      context: context,
      builder: (ctx) {
        bool deleting = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: KxColors.bgCard,
              shape: RoundedRectangleBorder(
                  borderRadius: KxSpacing.radiusLg),
              title: Text('Geçmişi Temizle',
                  style: KxTypography.headingMd),
              content: Text(
                'Tüm AI sohbet geçmişiniz kalıcı olarak silinecek. Bu işlem geri alınamaz.',
                style: KxTypography.bodyMd
                    .copyWith(color: KxColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('İptal',
                      style: KxTypography.labelSm
                          .copyWith(color: KxColors.textMuted)),
                ),
                KxButton(
                  label: 'Temizle',
                  variant: KxButtonVariant.danger,
                  size: KxButtonSize.sm,
                  isLoading: deleting,
                  onPressed: deleting
                      ? null
                      : () async {
                          setDialogState(() => deleting = true);
                          try {
                            final uid = _currentUid;
                            if (uid != null) {
                              final chats = await FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .doc(uid)
                                  .collection('ai_chats')
                                  .get();
                              final batch =
                                  FirebaseFirestore.instance.batch();
                              for (final doc in chats.docs) {
                                batch.delete(doc.reference);
                              }
                              await batch.commit();
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                            _showSuccess(
                                'Sohbet geçmişi temizlendi');
                          } catch (e) {
                            setDialogState(() => deleting = false);
                            _showError(
                                'Geçmiş temizlenemedi');
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Build ───────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KxColors.bgBase,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          backgroundColor: KxColors.bgBase,
          floating: true, snap: true, elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                color: KxColors.textPrimary, size: 18),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
          title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Ayarlar', style: KxTypography.headingMd),
            Text('Hesap & uygulama tercihleri',
                style: KxTypography.caption.copyWith(color: KxColors.teal400)),
          ]),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Hesap ─────────────────────────────────────────────
                _SectionHeader('Hesap', Icons.person_rounded, KxColors.teal400),
                const SizedBox(height: 10),
                _SettingsCard(children: [
                  _NavTile(
                    icon: Icons.edit_rounded,
                    label: 'Profili Düzenle',
                    subtitle: 'Ad, uzmanlık, biyografi',
                    onTap: _showEditProfileSheet,
                  ),
                  _Divider(),
                  _NavTile(
                    icon: Icons.verified_user_rounded,
                    label: 'Kimlik Doğrulama',
                    subtitle: 'Doktor sertifikası, ünvan',
                    onTap: _showVerificationStatus,
                  ),
                  _Divider(),
                  _NavTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Şifre & Güvenlik',
                    subtitle: 'Şifre değiştir, 2FA',
                    onTap: _showChangePasswordDialog,
                  ),
                ]),

                const SizedBox(height: 20),

                // ── Rol Değiştir (geliştirme) ──────────────────────────
                _SectionHeader('Rol Değiştir', Icons.swap_horiz_rounded, KxColors.amber300),
                const SizedBox(height: 10),
                _RoleSwitcherCard(),

                const SizedBox(height: 20),

                // ── Bildirimler ────────────────────────────────────────
                _SectionHeader('Bildirimler', Icons.notifications_rounded, KxColors.blue400),
                const SizedBox(height: 10),
                _SettingsCard(children: [
                  _ToggleTile(
                    icon: Icons.folder_rounded,
                    label: 'Vaka Bildirimleri',
                    subtitle: 'Yeni vaka, katkı, yorum',
                    value: _caseNotifs,
                    onChanged: (v) {
                      setState(() => _caseNotifs = v);
                      _saveNotificationPref('case', v);
                    },
                    activeColor: KxColors.teal400,
                  ),
                  _Divider(),
                  _ToggleTile(
                    icon: Icons.chat_bubble_rounded,
                    label: 'Mesaj Bildirimleri',
                    subtitle: 'Direkt mesajlar, grup',
                    value: _messageNotifs,
                    onChanged: (v) {
                      setState(() => _messageNotifs = v);
                      _saveNotificationPref('message', v);
                    },
                    activeColor: KxColors.teal400,
                  ),
                  _Divider(),
                  _ToggleTile(
                    icon: Icons.leaderboard_rounded,
                    label: 'Sıralama Değişimleri',
                    subtitle: 'Haftalık liderboard özeti',
                    value: _leaderNotifs,
                    onChanged: (v) {
                      setState(() => _leaderNotifs = v);
                      _saveNotificationPref('leaderboard', v);
                    },
                    activeColor: KxColors.teal400,
                  ),
                  _Divider(),
                  _ToggleTile(
                    icon: Icons.info_outline_rounded,
                    label: 'Sistem Bildirimleri',
                    subtitle: 'Bakım, güncellemeler',
                    value: _systemNotifs,
                    onChanged: (v) {
                      setState(() => _systemNotifs = v);
                      _saveNotificationPref('system', v);
                    },
                    activeColor: KxColors.teal400,
                  ),
                ]),

                const SizedBox(height: 20),

                // ── Gizlilik ──────────────────────────────────────────
                _SectionHeader('Gizlilik', Icons.shield_rounded, KxColors.jade300),
                const SizedBox(height: 10),
                _SettingsCard(children: [
                  _ToggleTile(
                    icon: Icons.visibility_rounded,
                    label: 'Profil Görünürlüğü',
                    subtitle: 'Diğer doktorlar profilini görebilir',
                    value: _profileVisible,
                    onChanged: (v) {
                      setState(() => _profileVisible = v);
                      _savePrivacyPref('isProfilePublic', v);
                    },
                    activeColor: KxColors.jade300,
                  ),
                  _Divider(),
                  _ToggleTile(
                    icon: Icons.timeline_rounded,
                    label: 'Aktivite Görünürlüğü',
                    subtitle: 'Vaka katkılarınız herkese açık',
                    value: _activityVisible,
                    onChanged: (v) {
                      setState(() => _activityVisible = v);
                      _savePrivacyPref('isActivityVisible', v);
                    },
                    activeColor: KxColors.jade300,
                  ),
                  _Divider(),
                  _NavTile(
                    icon: Icons.privacy_tip_rounded,
                    label: 'KVKK & Veri Yönetimi',
                    subtitle: 'Kişisel veri talebi, silme',
                    onTap: () => context.push('/kvkk'),
                  ),
                ]),

                const SizedBox(height: 20),

                // ── Görünüm & Dil ─────────────────────────────────────
                _SectionHeader('Görünüm & Dil', Icons.palette_rounded, KxColors.amber300),
                const SizedBox(height: 10),
                _SettingsCard(children: [
                  _SelectTile(
                    icon: Icons.language_rounded,
                    label: 'Dil',
                    value: _language,
                    options: const ['Türkçe', 'English'],
                    onChanged: _onLanguageChanged,
                  ),
                  _Divider(),
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      return _NavTile(
                        icon: themeMode == ThemeMode.dark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        label: 'Tema',
                        subtitle: themeMode == ThemeMode.dark
                            ? 'Koyu (varsayılan)'
                            : 'Açık',
                        onTap: _showThemePicker,
                      );
                    },
                  ),
                ]),

                const SizedBox(height: 20),

                // ── Yapay Zeka ────────────────────────────────────────
                _SectionHeader('Yapay Zeka', Icons.psychology_rounded, KxColors.teal400),
                const SizedBox(height: 10),
                _SettingsCard(children: [
                  _NavTile(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Gelişmiş AI Modu',
                    subtitle: 'Diferansiyel tanı, kanıta dayalı analiz',
                    onTap: () => context.push('/advanced-ai-chat'),
                    badge: 'YENİ',
                  ),
                  _Divider(),
                  _NavTile(
                    icon: Icons.history_rounded,
                    label: 'AI Sohbet Geçmişi',
                    subtitle: 'Tüm konuşmalarınızı görüntüleyin',
                    onTap: _showAIChatOptions,
                  ),
                ]),

                const SizedBox(height: 20),

                // ── Destek & Hukuki ───────────────────────────────────
                _SectionHeader('Destek & Hukuki', Icons.gavel_rounded, KxColors.textMuted),
                const SizedBox(height: 10),
                _SettingsCard(children: [
                  _NavTile(
                    icon: Icons.help_rounded,
                    label: 'Destek Merkezi',
                    subtitle: 'SSS, iletişim, hata bildirimi',
                    onTap: () => context.push('/support'),
                  ),
                  _Divider(),
                  _NavTile(
                    icon: Icons.description_rounded,
                    label: 'Kullanım Koşulları',
                    onTap: () => context.push('/terms'),
                  ),
                  _Divider(),
                  _NavTile(
                    icon: Icons.lock_person_rounded,
                    label: 'Gizlilik Politikası',
                    onTap: () => context.push('/privacy'),
                  ),
                  _Divider(),
                  _NavTile(
                    icon: Icons.balance_rounded,
                    label: 'KVKK Aydınlatma Metni',
                    onTap: () => context.push('/kvkk'),
                  ),
                ]),

                const SizedBox(height: 20),

                // ── Sistem ────────────────────────────────────────────
                _SettingsCard(children: [
                  _NavTile(
                    icon: Icons.monitor_heart_rounded,
                    label: 'Sistem Durumu',
                    onTap: () => context.push('/system-status'),
                  ),
                  _Divider(),
                  _NavTile(
                    icon: Icons.info_rounded,
                    label: 'Uygulama Hakkında',
                    subtitle: 'KONSENXIA v1.0.0',
                    onTap: () => _showAbout(context),
                  ),
                ]),

                const SizedBox(height: 32),

                // Çıkış
                SizedBox(
                  width: double.infinity,
                  child: KxButton(
                    label: 'Çıkış Yap',
                    onPressed: () async {
                      // Önce token'ı sil, sonra navigate et
                      final prefs = GetIt.instance<SharedPreferences>();
                      await prefs.remove('auth_token');
                      await prefs.remove('auth_user');
                      context.read<AuthBloc>().add(LogoutEvent());
                      if (context.mounted) context.go('/login');
                    },
                    variant: KxButtonVariant.danger,
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: KxColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: KxSpacing.radiusLg),
        title: Text('KONSENXIA', style: KxTypography.headingMd),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: KxColors.teal400.withOpacity(0.12),
              borderRadius: KxSpacing.radiusMd,
            ),
            child: const Icon(Icons.medical_services_rounded,
                color: KxColors.teal400, size: 36),
          ),
          const SizedBox(height: 16),
          Text('Versiyon 1.0.0',
              style: KxTypography.labelMd.copyWith(color: KxColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Doktordan Doktora Tıbbi Öğrenme Platformu',
              style: KxTypography.caption.copyWith(color: KxColors.textMuted),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text('© 2024 KONSENXIA — Tüm hakları saklıdır.',
              style: KxTypography.caption.copyWith(color: KxColors.textMuted),
              textAlign: TextAlign.center),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam',
                style: KxTypography.labelSm.copyWith(color: KxColors.teal400)),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionHeader(this.title, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 6),
      Text(title.toUpperCase(),
          style: KxTypography.caption.copyWith(
              color: color, fontSize: 11, letterSpacing: 0.8,
              fontWeight: FontWeight.w600)),
    ]),
  );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: KxColors.bgCard,
      borderRadius: KxSpacing.radiusMd,
      border: Border.all(color: KxColors.border),
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: KxColors.border);
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.badge,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: KxSpacing.radiusMd,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(children: [
        Icon(icon, size: 18, color: KxColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(label, style: KxTypography.labelSm),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: KxColors.teal400.withOpacity(0.15),
                    borderRadius: KxSpacing.radiusPill,
                    border: Border.all(color: KxColors.teal400.withOpacity(0.4)),
                  ),
                  child: Text(badge!,
                      style: KxTypography.caption.copyWith(
                          color: KxColors.teal400, fontSize: 9)),
                ),
              ],
            ]),
            if (subtitle != null)
              Text(subtitle!,
                  style: KxTypography.caption.copyWith(
                      color: KxColors.textMuted, fontSize: 11)),
          ]),
        ),
        const Icon(Icons.chevron_right_rounded,
            color: KxColors.textMuted, size: 16),
      ]),
    ),
  );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(children: [
      Icon(icon, size: 18, color: KxColors.textSecondary),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: KxTypography.labelSm),
          if (subtitle != null)
            Text(subtitle!,
                style: KxTypography.caption.copyWith(
                    color: KxColors.textMuted, fontSize: 11)),
        ]),
      ),
      Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        activeTrackColor: activeColor.withOpacity(0.3),
        inactiveTrackColor: KxColors.bgSurface,
        inactiveThumbColor: KxColors.textMuted,
      ),
    ]),
  );
}

class _RoleSwitcherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final currentRole = state is AuthAuthenticated
            ? UserRole.fromString(state.user.role)
            : UserRole.resident;

        // Admin hariç 4 ana rolü göster
        final roles = UserRole.values
            .where((r) => r != UserRole.admin)
            .toList();

        return _SettingsCard(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: Text(
                'Platformu farklı roller ile test edin. '
                'Rol değiştirince dashboard ve yetkiler güncellenir.',
                style: KxTypography.caption.copyWith(
                  color: KxColors.textMuted, fontSize: 11),
              ),
            ),
            ...roles.map((role) {
              final isSelected = role == currentRole;
              return InkWell(
                onTap: isSelected
                    ? null
                    : () {
                        context.read<AuthBloc>().add(
                          SwitchRoleEvent(newRole: role.apiValue),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${role.emoji} ${role.displayName} rolüne geçildi',
                              style: KxTypography.bodyMd.copyWith(
                                color: KxColors.textPrimary),
                            ),
                            backgroundColor: KxColors.bgElevated,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: KxSpacing.radiusMd,
                              side: BorderSide(
                                color: KxColors.teal400.withOpacity(0.3)),
                            ),
                          ),
                        );
                      },
                borderRadius: KxSpacing.radiusMd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? KxColors.teal400.withOpacity(0.06)
                        : null,
                    border: Border(
                      top: BorderSide(color: KxColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(role.emoji,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role.displayName,
                              style: KxTypography.labelSm.copyWith(
                                color: isSelected
                                    ? KxColors.teal300
                                    : KxColors.textPrimary,
                              ),
                            ),
                            Text(
                              _roleDescription(role),
                              style: KxTypography.caption.copyWith(
                                color: KxColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded,
                            color: KxColors.teal400, size: 18)
                      else
                        const Icon(Icons.circle_outlined,
                            color: KxColors.textMuted, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  String _roleDescription(UserRole role) => switch (role) {
        UserRole.intern =>
          'Vaka gör, rapor yaz, atanan vakaları tamamla',
        UserRole.resident =>
          'Vaka katkısı yap, AI kullan, atanan vakaları tamamla',
        UserRole.specialist =>
          'Vaka ata, yorum yap, uzman görüşü ver',
        UserRole.professor =>
          'Vaka ata, akademik değerlendirme, tam yetki',
        UserRole.admin => 'Platform yönetimi',
      };
}

class _SelectTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _SelectTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(children: [
      Icon(icon, size: 18, color: KxColors.textSecondary),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: KxTypography.labelSm)),
      DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        dropdownColor: KxColors.bgCard,
        style: KxTypography.labelSm.copyWith(color: KxColors.teal400),
        icon: const Icon(Icons.expand_more_rounded,
            color: KxColors.textMuted, size: 16),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    ]),
  );
}

// ── Kimlik Dogrulama satir widget'i ──────────────────────────

class _VerificationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isVerified;
  final String detail;

  const _VerificationRow({
    required this.icon,
    required this.label,
    required this.isVerified,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KxColors.bgCard,
        borderRadius: KxSpacing.radiusMd,
        border: Border.all(
          color: isVerified
              ? KxColors.jade300.withOpacity(0.3)
              : KxColors.amber300.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20,
              color: isVerified ? KxColors.jade300 : KxColors.amber300),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: KxTypography.labelSm),
                const SizedBox(height: 2),
                Text(detail,
                    style: KxTypography.caption
                        .copyWith(color: KxColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified
                  ? KxColors.jade300.withOpacity(0.12)
                  : KxColors.amber300.withOpacity(0.12),
              borderRadius: KxSpacing.radiusPill,
            ),
            child: Text(
              isVerified ? 'Doğrulandı' : 'Beklemede',
              style: KxTypography.caption.copyWith(
                color: isVerified ? KxColors.jade300 : KxColors.amber300,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tema secim satir widget'i ────────────────────────────────

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: KxSpacing.radiusMd,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? KxColors.teal400.withOpacity(0.06)
              : KxColors.bgSurface,
          borderRadius: KxSpacing.radiusMd,
          border: Border.all(
            color: isSelected
                ? KxColors.teal400.withOpacity(0.4)
                : KxColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22,
                color: isSelected ? KxColors.teal400 : KxColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: KxTypography.labelSm.copyWith(
                        color: isSelected
                            ? KxColors.teal300
                            : KxColors.textPrimary,
                      )),
                  Text(subtitle,
                      style: KxTypography.caption
                          .copyWith(color: KxColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: KxColors.teal400, size: 18)
            else
              const Icon(Icons.circle_outlined,
                  color: KxColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
