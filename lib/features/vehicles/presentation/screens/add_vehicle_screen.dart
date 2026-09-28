// lib/features/vehicles/presentation/screens/add_vehicle_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:servis_aja/core/constants/route_constants.dart';
import 'package:servis_aja/core/theme/app_colors.dart';
import 'package:servis_aja/core/theme/app_radius.dart';
import 'package:servis_aja/core/theme/app_spacing.dart';
import 'package:servis_aja/core/theme/app_typography.dart';
import 'package:servis_aja/features/vehicles/domain/vehicle.dart';
import 'package:servis_aja/features/vehicles/presentation/providers/vehicle_providers.dart';
import 'package:servis_aja/shared/providers/shared_providers.dart';
import 'package:servis_aja/shared/widgets/layout/sticky_bottom_bar.dart';

/// Screen: Add a new vehicle to the user's garage.
/// Uses autoDispose form state that resets when user leaves.
class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _aliasController = TextEditingController();
  final _colorController = TextEditingController();

  // Track if user has interacted with plate field (for showing errors)
  bool _plateDirty = false;

  @override
  void dispose() {
    _plateController.dispose();
    _aliasController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(addVehicleFormProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tambah Kendaraan'),
        leading: BackButton(onPressed: _handleBack),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handleBack();
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal,
              vertical: AppSpacing.pageVertical,
            ),
            children: [
              // ── Step indicator ─────────────────────────────────────
              _StepIndicator(
                steps: const ['Kategori', 'Merek & Model', 'Detail'],
                currentStep: _currentStep(form),
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── Section 1: Category ────────────────────────────────
              _SectionHeader(
                number: 1,
                title: 'Jenis Kendaraan',
                isActive: true,
              ),
              const SizedBox(height: AppSpacing.sectionHeaderGap),
              _CategorySelector(
                selectedId: form.selectedCategoryId,
                onSelect: (id) =>
                    ref.read(addVehicleFormProvider.notifier).setCategory(id),
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── Section 2: Brand & Model (visible once category selected) ──
              AnimatedOpacity(
                opacity: form.selectedCategoryId != null ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      number: 2,
                      title: 'Merek & Model',
                      isActive: form.selectedCategoryId != null,
                    ),
                    const SizedBox(height: AppSpacing.sectionHeaderGap),
                    _BrandModelSelector(form: form),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // ── Section 3: Details (visible once model selected) ───
              AnimatedOpacity(
                opacity: form.selectedModelId != null ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      number: 3,
                      title: 'Detail Kendaraan',
                      isActive: form.selectedModelId != null,
                    ),
                    const SizedBox(height: AppSpacing.sectionHeaderGap),
                    _DetailFields(
                      form: form,
                      plateDirty: _plateDirty,
                      plateController: _plateController,
                      aliasController: _aliasController,
                      colorController: _colorController,
                      onPlateDirty: () => setState(() => _plateDirty = true),
                    ),
                  ],
                ),
              ),
              // Bottom padding for sticky bar
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StickyBottomBar(
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: form.isValid && !form.isSubmitting
                ? () => _handleSubmit(form)
                : null,
            style: FilledButton.styleFrom(
              minimumSize:
                  const Size(double.infinity, AppSpacing.buttonHeightLg),
            ),
            child: form.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : const Text('Simpan Kendaraan'),
          ),
        ),
      ),
    );
  }

  int _currentStep(AddVehicleFormState form) {
    if (form.selectedModelId != null) return 2;
    if (form.selectedBrandId != null) return 1;
    if (form.selectedCategoryId != null) return 1;
    return 0;
  }

  void _handleBack() {
    final form = ref.read(addVehicleFormProvider);
    final hasInput = form.selectedCategoryId != null ||
        form.plateNumber.isNotEmpty ||
        form.alias.isNotEmpty;

    if (!hasInput) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed(RouteConstants.nameSelectVehicle);
      }
      return;
    }

    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan?'),
        content: const Text(
            'Data kendaraan yang sudah diisi akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(RouteConstants.nameSelectVehicle);
        }
      }
    });
  }

  Future<void> _handleSubmit(AddVehicleFormState form) async {
    setState(() => _plateDirty = true);
    if (!_formKey.currentState!.validate()) return;
    if (!form.isPlateValid) return;

    ref.read(addVehicleFormProvider.notifier).setSubmitting(true);

    final brands = ref.read(vehicleBrandsProvider).valueOrNull ?? [];
    final models = ref.read(vehicleModelsProvider).valueOrNull ?? [];
    final brand =
        brands.where((b) => b.id == form.selectedBrandId).firstOrNull;
    final model =
        models.where((m) => m.id == form.selectedModelId).firstOrNull;

    final newVehicle = Vehicle(
      id: 'vhc-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'usr-001',
      plateNumber: form.plateNumber.toUpperCase().trim(),
      categoryId: form.selectedCategoryId!,
      brandId: form.selectedBrandId!,
      modelId: form.selectedModelId!,
      brandName: brand?.name ?? '',
      modelName: model?.name ?? '',
      alias: form.alias.isNotEmpty ? form.alias.trim() : null,
      year: form.selectedYear,
      color: form.color.isNotEmpty ? form.color.trim() : null,
      createdAt: DateTime.now(),
    );

    // Persist vehicle in repository
    ref.read(vehicleDataSourceProvider).addUserVehicle(newVehicle);
    ref.invalidate(userVehiclesProvider);

    // Simulate save delay (would be an API call in production)
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    // Success feedback + pop back to vehicle selection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${form.alias.isNotEmpty ? form.alias : newVehicle.displayName} berhasil ditambahkan!',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    context.pop();
  }
}

// ── Step Indicator ─────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.steps, required this.currentStep});
  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i <= currentStep;
        final isDone = i < currentStep;
        return Expanded(
          child: Row(
            children: [
              // Step circle
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.neutral200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: AppColors.onPrimary)
                      : Text(
                          '${i + 1}',
                          style: AppTypography.labelSmall.copyWith(
                            color: isActive
                                ? AppColors.onPrimary
                                : AppColors.textDisabled,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Step label + connector
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[i],
                      style: AppTypography.labelSmall.copyWith(
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                      ),
                    ),
                    if (i < steps.length - 1)
                      Container(
                        margin: const EdgeInsets.only(top: AppSpacing.xs2),
                        height: 2,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.neutral200,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.number,
    required this.title,
    required this.isActive,
  });
  final int number;
  final String title;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.neutral200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: AppTypography.labelSmall.copyWith(
                color:
                    isActive ? AppColors.onPrimary : AppColors.textDisabled,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: isActive ? AppColors.textPrimary : AppColors.textDisabled,
          ),
        ),
      ],
    );
  }
}

// ── Category Selector ──────────────────────────────────────────────────────────

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.selectedId,
    required this.onSelect,
  });

  final String? selectedId;
  final void Function(String) onSelect;

  static const _categories = [
    (id: 'motor', label: 'Motor', icon: Icons.two_wheeler_rounded,
     desc: 'Matic, bebek, sport'),
    (id: 'mobil', label: 'Mobil', icon: Icons.directions_car_rounded,
     desc: 'Sedan, SUV, MPV'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _categories.map((cat) {
        final isSelected = selectedId == cat.id;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: cat.id == 'motor' ? AppSpacing.cardGap : 0,
            ),
            child: _CategoryCard(
              label: cat.label,
              description: cat.desc,
              icon: cat.icon,
              isSelected: isSelected,
              onTap: () => onSelect(cat.id),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer.withValues(alpha: 0.4)
              : AppColors.surface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: isSelected ? AppColors.primary : AppColors.neutral400,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.titleSmall.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
            Text(
              description,
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Brand & Model Selector ─────────────────────────────────────────────────────

class _BrandModelSelector extends ConsumerWidget {
  const _BrandModelSelector({required this.form});
  final AddVehicleFormState form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBrands = ref.watch(vehicleBrandsProvider);
    final asyncModels = ref.watch(vehicleModelsProvider);

    return asyncBrands.when(
      data: (brands) {
        final filteredBrands = form.selectedCategoryId != null
            ? brands
                .where((b) => b.supportsCategory(form.selectedCategoryId!))
                .toList()
            : brands;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand dropdown
            DropdownButtonFormField<String>(
              key: ValueKey('brand_${form.selectedCategoryId}'),
              initialValue: form.selectedBrandId,
              decoration: const InputDecoration(
                labelText: 'Merek *',
                hintText: 'Pilih merek kendaraan',
                prefixIcon: Icon(Icons.business_rounded),
              ),
              items: filteredBrands
                  .map(
                    (b) => DropdownMenuItem(
                      value: b.id,
                      child: Text(b.name),
                    ),
                  )
                  .toList(),
              onChanged: form.selectedCategoryId == null
                  ? null
                  : (val) {
                      if (val != null) {
                        ref
                            .read(addVehicleFormProvider.notifier)
                            .setBrand(val);
                      }
                    },
              validator: (val) =>
                  val == null ? 'Pilih merek kendaraan' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // Model dropdown (depends on brand)
            asyncModels.when(
              data: (models) {
                final filteredModels = models
                    .where(
                      (m) =>
                          m.brandId == form.selectedBrandId &&
                          m.categoryId == form.selectedCategoryId,
                    )
                    .toList();

                return DropdownButtonFormField<String>(
                  key: ValueKey('model_${form.selectedBrandId}'),
                  initialValue: form.selectedModelId,
                  decoration: const InputDecoration(
                    labelText: 'Model *',
                    hintText: 'Pilih model kendaraan',
                    prefixIcon: Icon(Icons.directions_car_outlined),
                  ),
                  items: filteredModels
                      .map(
                        (m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name),
                        ),
                      )
                      .toList(),
                  onChanged: form.selectedBrandId == null
                      ? null
                      : (val) {
                          if (val != null) {
                            ref
                                .read(addVehicleFormProvider.notifier)
                                .setModel(val);
                          }
                        },
                  validator: (val) =>
                      val == null ? 'Pilih model kendaraan' : null,
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}

// ── Detail Fields ──────────────────────────────────────────────────────────────

class _DetailFields extends ConsumerWidget {
  const _DetailFields({
    required this.form,
    required this.plateDirty,
    required this.plateController,
    required this.aliasController,
    required this.colorController,
    required this.onPlateDirty,
  });

  final AddVehicleFormState form;
  final bool plateDirty;
  final TextEditingController plateController;
  final TextEditingController aliasController;
  final TextEditingController colorController;
  final VoidCallback onPlateDirty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(addVehicleFormProvider.notifier);
    final isEnabled = form.selectedModelId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Plate number (required)
        TextFormField(
          controller: plateController,
          enabled: isEnabled,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            // Auto-uppercase
            TextInputFormatter.withFunction(
              (old, next) => next.copyWith(
                text: next.text.toUpperCase(),
              ),
            ),
          ],
          decoration: InputDecoration(
            labelText: 'Nomor Plat *',
            hintText: 'B 1234 SKY',
            prefixIcon: const Icon(Icons.badge_rounded),
            errorText: plateDirty ? form.plateError : null,
            helperText: 'Format: [huruf] [angka] [huruf]',
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Nomor plat tidak boleh kosong';
            }
            if (!form.isPlateValid) {
              return 'Format plat tidak valid (contoh: B 1234 SKY)';
            }
            return null;
          },
          onChanged: (val) {
            onPlateDirty();
            notifier.setPlateNumber(val);
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // Alias / nickname (optional)
        TextFormField(
          controller: aliasController,
          enabled: isEnabled,
          decoration: const InputDecoration(
            labelText: 'Nama Panggilan',
            hintText: 'Motor Harian, Mobil Keluarga...',
            prefixIcon: Icon(Icons.label_rounded),
            helperText: 'Opsional — memudahkan identifikasi',
          ),
          maxLength: 30,
          onChanged: notifier.setAlias,
        ),
        const SizedBox(height: AppSpacing.md),

        // Year (optional — simple dropdown for now)
        _YearDropdown(
          selectedModel: _findModel(ref, form.selectedModelId),
          selectedYear: form.selectedYear,
          isEnabled: isEnabled,
          onChanged: notifier.setYear,
        ),
        const SizedBox(height: AppSpacing.md),

        // Color (optional)
        TextFormField(
          controller: colorController,
          enabled: isEnabled,
          decoration: const InputDecoration(
            labelText: 'Warna',
            hintText: 'Hitam, Putih, Merah...',
            prefixIcon: Icon(Icons.palette_rounded),
            helperText: 'Opsional',
          ),
          onChanged: notifier.setColor,
        ),
      ],
    );
  }

  VehicleModel? _findModel(WidgetRef ref, String? modelId) {
    if (modelId == null) return null;
    final async = ref.read(vehicleModelsProvider);
    return async.valueOrNull?.where((m) => m.id == modelId).firstOrNull;
  }
}

class _YearDropdown extends StatelessWidget {
  const _YearDropdown({
    required this.selectedModel,
    required this.selectedYear,
    required this.isEnabled,
    required this.onChanged,
  });

  final VehicleModel? selectedModel;
  final int? selectedYear;
  final bool isEnabled;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    final years = selectedModel != null
        ? List.generate(
            selectedModel!.yearEnd - selectedModel!.yearStart + 1,
            (i) => selectedModel!.yearStart + i,
          ).reversed.toList()
        : <int>[];

    return DropdownButtonFormField<int>(
      initialValue: selectedYear,
      decoration: const InputDecoration(
        labelText: 'Tahun',
        hintText: 'Pilih tahun kendaraan',
        prefixIcon: Icon(Icons.calendar_today_rounded),
        helperText: 'Opsional',
      ),
      items: years
          .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
          .toList(),
      onChanged: isEnabled && years.isNotEmpty
          ? (val) {
              if (val != null) onChanged(val);
            }
          : null,
    );
  }
}
