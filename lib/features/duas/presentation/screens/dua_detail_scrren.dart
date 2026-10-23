import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/storage/shared_preferences_storage.dart';
import '../../../tasbeeh/screens/dhikr_journeys_screen.dart';
import '../../../tasbeeh/data/repositories/dhikr_journey_repository.dart';
import '../../../tasbeeh/domain/models/dhikr_journey.dart';

import '../../data/repositories/dua_repository.dart';

class DuaDetailScreen extends StatefulWidget {
  const DuaDetailScreen({super.key, required this.duaId});

  final String duaId;

  @override
  State<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends State<DuaDetailScreen> {
  final DuaRepository _repository = DuaRepository();
  late Future<Map<String, dynamic>?> _duaFuture;

  @override
  void initState() {
    super.initState();
    _duaFuture = _loadDua();
  }

  Future<Map<String, dynamic>?> _loadDua() async {
    final duas = await _repository.getAllDuas();
    for (final dua in duas) {
      if (dua['id']?.toString() == widget.duaId) {
        return dua;
      }
    }
    return null;
  }

  String _value(Map<String, dynamic> dua, String key) {
    return dua[key]?.toString().trim() ?? '';
  }

  Future<void> _copyArabic(String arabic) async {
    if (arabic.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: arabic));
    await HapticFeedback.lightImpact();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Arabic text copied to clipboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _shareDua(Map<String, dynamic> dua) async {
    await HapticFeedback.lightImpact();
    final String title = _value(dua, 'title');
    final String arabic = _value(dua, 'arabic');
    final String englishTransliteration = _value(
      dua,
      'english_transliteration',
    );
    final String malayalamTransliteration = _value(
      dua,
      'malayalam_transliteration',
    );
    final String englishMeaning = _value(dua, 'english_translation');
    final String malayalamMeaning = _value(dua, 'malayalam_translation');
    final String source = _value(dua, 'source');

    final StringBuffer shareBuffer = StringBuffer();
    if (title.isNotEmpty) shareBuffer.writeln('✨ $title ✨\n');
    if (arabic.isNotEmpty) shareBuffer.writeln('$arabic\n');
    if (englishTransliteration.isNotEmpty) {
      shareBuffer.writeln(
        '• English Transliteration:\n$englishTransliteration\n',
      );
    }
    if (malayalamTransliteration.isNotEmpty) {
      shareBuffer.writeln(
        '• Malayalam Transliteration:\n$malayalamTransliteration\n',
      );
    }
    if (englishMeaning.isNotEmpty) {
      shareBuffer.writeln('• English Meaning:\n$englishMeaning\n');
    }
    if (malayalamMeaning.isNotEmpty) {
      shareBuffer.writeln('• Malayalam Meaning:\n$malayalamMeaning\n');
    }
    if (source.isNotEmpty) {
      shareBuffer.writeln('• Reference: $source\n');
    }
    shareBuffer.write('--- \nShared via RUSHD App');

    await Share.share(
      shareBuffer.toString(),
      subject: title.isEmpty ? 'Dua' : title,
    );
  }

  Future<void> _createRecitationJourney(Map<String, dynamic> dua) async {
    final name = _value(dua, 'title');

    final formKey = GlobalKey<FormState>();
    var saving = false;
    String? createdJourneyId;

    final targetCount = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        // The controller belongs to this bottom sheet's widget subtree.
        return _CreateRecitationJourneySheet(
          name: name,
          formKey: formKey,
          onCreate: (target) async {
            if (saving) return;

            saving = true;

            try {
              final preferences = await SharedPreferences.getInstance();

              final repository = DhikrJourneyRepository(
                SharedPreferencesStorage(preferences),
              );

              final journeyId = DateTime.now().microsecondsSinceEpoch
                  .toString();

              final journey = DhikrJourney(
                id: journeyId,
                name: name,
                currentCount: 0,
                targetCount: target,
                createdAt: DateTime.now(),
                duaId: widget.duaId,
              );

              await repository.createJourney(journey);
              createdJourneyId = journeyId;

              if (!sheetContext.mounted) return;

              Navigator.of(sheetContext).pop(target);
            } catch (error) {
              saving = false;

              if (!sheetContext.mounted) return;

              ScaffoldMessenger.of(sheetContext).showSnackBar(
                SnackBar(content: Text('Could not create journey: $error')),
              );
            }
          },
        );
      },
    );

    if (!mounted || targetCount == null || createdJourneyId == null) {
      return;
    }

    ProviderScope.containerOf(context).invalidate(dhikrJourneysProvider);

    context.push('/tasbeeh/counter/$createdJourneyId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'DUA DETAILS',
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _duaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 42,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    const Text('Unable to load this Dua. Please try again.'),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _duaFuture = _loadDua();
                        });
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                      ),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final dua = snapshot.data;

          if (dua == null) {
            return const Center(child: Text('Dua not found.'));
          }

          final title = _value(dua, 'title');
          final category = _value(dua, 'category');
          final arabic = _value(dua, 'arabic');
          final englishTransliteration = _value(dua, 'english_transliteration');
          final malayalamTransliteration = _value(
            dua,
            'malayalam_transliteration',
          );
          final englishTranslation = _value(dua, 'english_translation');
          final malayalamTranslation = _value(dua, 'malayalam_translation');
          final source = _value(dua, 'source');
          final tags = (dua['tags'] ?? []) as List<dynamic>;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            physics: const BouncingScrollPhysics(),
            children: [
              // 1. Hero Card (Category & Title)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (category.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    Text(
                      title.isEmpty ? 'Dua Details' : title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Arabic Display Container
              if (arabic.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1E3A8A).withOpacity(0.05),
                        const Color(0xFF1E3A8A).withOpacity(0.01),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    ),
                  ),
                  child: SelectableText(
                    arabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 30,
                      height: 1.9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),

              // 3. Transliterations & Translations Sections
              _buildSectionCard(
                title: 'English Transliteration',
                content: englishTransliteration,
                icon: Icons.translate_rounded,
              ),
              _buildSectionCard(
                title: 'English Meaning',
                content: englishTranslation,
                icon: Icons.menu_book_rounded,
              ),
              _buildSectionCard(
                title: 'Malayalam Transliteration',
                content: malayalamTransliteration,
                icon: Icons.translate_rounded,
              ),
              _buildSectionCard(
                title: 'Malayalam Meaning',
                content: malayalamTranslation,
                icon: Icons.menu_book_rounded,
              ),

              // 4. Source & Tags Card
              if (source.isNotEmpty || tags.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.025),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.04)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_stories_rounded,
                            size: 18,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Reference & Tags',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      if (source.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          source,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.06),
                                ),
                              ),
                              child: Text(
                                tag.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),

              // Create a linked Tasbeeh recitation journey.
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _createRecitationJourney(dua),
                    icon: const Icon(Icons.repeat_rounded),
                    label: const Text(
                      'Create recitation journey',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),

              // 5. Action Buttons (Copy Arabic & Share Dua)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _copyArabic(arabic),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text(
                        'Copy Arabic',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _shareDua(dua),
                      icon: const Icon(
                        Icons.ios_share_rounded,
                        size: 18,
                        color: Color(0xFF1E3A8A),
                      ),
                      label: const Text(
                        'Share Dua',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF1E3A8A,
                        ).withOpacity(0.08),
                        foregroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    if (content.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.black45),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            content,
            style: const TextStyle(
              height: 1.6,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

/// The text controller is owned and disposed by this widget.
class _CreateRecitationJourneySheet extends StatefulWidget {
  const _CreateRecitationJourneySheet({
    required this.name,
    required this.formKey,
    required this.onCreate,
  });

  final String name;
  final GlobalKey<FormState> formKey;
  final Future<void> Function(int target) onCreate;

  @override
  State<_CreateRecitationJourneySheet> createState() =>
      _CreateRecitationJourneySheetState();
}

class _CreateRecitationJourneySheetState
    extends State<_CreateRecitationJourneySheet> {
  late final TextEditingController _targetController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _targetController = TextEditingController(text: '100');
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !widget.formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);

    final target = int.parse(_targetController.text.trim());

    try {
      await widget.onCreate(target);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Form(
          key: widget.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a recitation journey',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(widget.name, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              TextFormField(
                controller: _targetController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Target recitation count',
                  hintText: 'e.g. 100',
                  prefixIcon: const Icon(Icons.flag_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) {
                  final count = int.tryParse(value?.trim() ?? '');

                  if (count == null || count < 1) {
                    return 'Enter a count greater than zero';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    _saving ? 'Creating journey...' : 'Create journey',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
