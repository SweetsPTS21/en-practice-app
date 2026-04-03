import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/network/api_error.dart';
import '../../../core/theme/page_palettes.dart';
import '../../../core/theme/theme_extensions.dart';
import '../auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _registerMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(authControllerProvider);

    try {
      if (_registerMode) {
        await controller.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim(),
        );
      } else {
        await controller.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on ApiError catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context
                  .pagePalette(
                    _registerMode
                        ? AppPagePaletteKey.profile
                        : AppPagePaletteKey.dashboard,
                  )
                  .heroTop,
              tokens.background.body,
              tokens.background.canvas,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: tokens.background.mobileDrawer,
                    borderRadius: BorderRadius.circular(tokens.radius.xxl),
                    border: Border.all(color: tokens.border.subtle),
                    boxShadow: [
                      BoxShadow(
                        color: tokens.shadow.shell,
                        blurRadius: tokens.motion.blurStrong + 10,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    context
                                        .pagePalette(
                                          AppPagePaletteKey.dashboard,
                                        )
                                        .heroTop,
                                    context
                                        .pagePalette(
                                          AppPagePaletteKey.dashboard,
                                        )
                                        .heroBottom,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  tokens.radius.xl,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: context
                                        .pagePalette(
                                          AppPagePaletteKey.dashboard,
                                        )
                                        .accent
                                        .withValues(alpha: 0.24),
                                    blurRadius: tokens.motion.blurStrong,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.tr('common.appName'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          context.tr(
                            _registerMode
                                ? 'auth.login.hero.registerTitle'
                                : 'auth.login.hero.loginTitle',
                          ),
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          context.tr(
                            _registerMode
                                ? 'auth.login.hero.registerSubtitle'
                                : 'auth.login.hero.loginSubtitle',
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _ModeToggle(
                        registerMode: _registerMode,
                        onChanged: auth.isSubmitting
                            ? null
                            : (value) {
                                setState(() {
                                  _registerMode = value;
                                });
                              },
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_registerMode) ...[
                              _LabeledField(
                                label: context.tr('auth.form.displayName'),
                                child: TextFormField(
                                  controller: _displayNameController,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    hintText: context.tr(
                                      'auth.form.displayNameHint',
                                    ),
                                  ),
                                  validator: (value) {
                                    if (!_registerMode) {
                                      return null;
                                    }
                                    if (value == null || value.trim().isEmpty) {
                                      return context.tr(
                                        'auth.validation.displayNameRequired',
                                      );
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            _LabeledField(
                              label: context.tr('auth.form.email'),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.username,
                                  AutofillHints.email,
                                ],
                                decoration: InputDecoration(
                                  hintText: context.tr('auth.form.emailHint'),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.tr(
                                      'auth.validation.emailRequired',
                                    );
                                  }
                                  if (!value.contains('@')) {
                                    return context.tr(
                                      'auth.validation.emailInvalid',
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            _LabeledField(
                              label: context.tr('auth.form.password'),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                textInputAction: _registerMode
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                decoration: InputDecoration(
                                  hintText: context.tr(
                                    'auth.form.passwordHint',
                                  ),
                                ),
                                onFieldSubmitted: (_) {
                                  if (!_registerMode) {
                                    _submit();
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return context.tr(
                                      'auth.validation.passwordRequired',
                                    );
                                  }
                                  if (value.length < 8) {
                                    return context.tr(
                                      'auth.validation.passwordMin',
                                    );
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (_registerMode) ...[
                              const SizedBox(height: 16),
                              _LabeledField(
                                label: context.tr('auth.form.confirmPassword'),
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  decoration: InputDecoration(
                                    hintText: context.tr(
                                      'auth.form.confirmPasswordHint',
                                    ),
                                  ),
                                  onFieldSubmitted: (_) => _submit(),
                                  validator: (value) {
                                    if (!_registerMode) {
                                      return null;
                                    }
                                    if (value == null || value.isEmpty) {
                                      return context.tr(
                                        'auth.validation.confirmPasswordRequired',
                                      );
                                    }
                                    if (value != _passwordController.text) {
                                      return context.tr(
                                        'auth.validation.confirmPasswordMismatch',
                                      );
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            if (auth.errorMessage != null &&
                                auth.errorMessage!.isNotEmpty)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: tokens.danger.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(
                                    tokens.radius.lg,
                                  ),
                                  border: Border.all(
                                    color: tokens.danger.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  auth.errorMessage!,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: tokens.danger),
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: auth.isSubmitting ? null : _submit,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  child: auth.isSubmitting
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: tokens.text.inverse,
                                          ),
                                        )
                                      : Text(
                                          context.tr(
                                            _registerMode
                                                ? 'auth.actions.createAccount'
                                                : 'auth.actions.signIn',
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.registerMode, required this.onChanged});

  final bool registerMode;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: tokens.background.panelStrong,
        borderRadius: BorderRadius.circular(tokens.radius.hero),
        border: Border.all(color: tokens.border.subtle),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ModeToggleButton(
              active: !registerMode,
              label: context.tr('auth.tabs.signIn'),
              onTap: onChanged == null ? null : () => onChanged!(false),
            ),
          ),
          Expanded(
            child: _ModeToggleButton(
              active: registerMode,
              label: context.tr('auth.tabs.register'),
              onTap: onChanged == null ? null : () => onChanged!(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  const _ModeToggleButton({
    required this.active,
    required this.label,
    required this.onTap,
  });

  final bool active;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AnimatedContainer(
      duration: tokens.motion.normal,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: active ? tokens.primaryStrong : Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.radius.hero),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tokens.radius.hero),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: active ? tokens.text.inverse : tokens.text.secondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
