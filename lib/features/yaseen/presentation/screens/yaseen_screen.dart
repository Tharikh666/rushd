import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:rushd/features/yaseen/presentation/screens/yaseen_bookmarks_screen.dart';

import '../../data/models/yaseen_ayah.dart';
import '../../data/repositories/yaseen_repository.dart';
import '../../domain/services/yaseen_bookmark_services.dart';
import '../../domain/services/yaseen_progress_service.dart';
import '../widgets/yaseen_ayah_card.dart';

class YaseenScreen extends StatefulWidget {
  const YaseenScreen({super.key});

  @override
  State<YaseenScreen> createState() => _YaseenScreenState();
}

class _YaseenScreenState extends State<YaseenScreen> {
  final YaseenRepository _repository = YaseenRepository();
  final YaseenBookmarkService _bookmarkService = YaseenBookmarkService();
  final YaseenProgressService _progressService = YaseenProgressService();

  final ItemScrollController _itemScrollController = ItemScrollController();

  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  List<YaseenAyah> _ayahs = [];
  Set<int> _bookmarks = {};

  bool _isLoading = true;
  String? _errorMessage;

  // Default to false as requested
  bool _showEnglishTransliteration = false;
  bool _showMalayalamTransliteration = false;
  bool _showEnglishTranslation = false;
  bool _showMalayalamTranslation = false;

  double _arabicFontSize = 34;
  int _selectedAyah = 1;

  @override
  void initState() {
    super.initState();
    _loadReader();
    _itemPositionsListener.itemPositions.addListener(
      _updateSelectedAyahFromScroll,
    );
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(
      _updateSelectedAyahFromScroll,
    );
    super.dispose();
  }

  Future<void> _loadReader() async {
    try {
      final results = await Future.wait([
        _repository.getAyahs(),
        _bookmarkService.getBookmarks(),
        _progressService.getLastReadAyah(),
      ]);

      if (!mounted) return;

      setState(() {
        _ayahs = results[0] as List<YaseenAyah>;
        _bookmarks = (results[1] as List<int>).toSet();
        _selectedAyah = results[2] as int;
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_itemScrollController.isAttached) return;

        // Index 0 is the Surah header card, so ayah 1 is at index 1, ayah n is at index n
        _itemScrollController.jumpTo(index: _selectedAyah, alignment: 0.0);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to load Surah Yaseen.\n$error';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProgress(int ayahNumber) async {
    _selectedAyah = ayahNumber;
    await _progressService.saveProgress(ayahNumber);
  }

  Future<void> _toggleBookmark(int ayahNumber) async {
    final wasBookmarked = _bookmarks.contains(ayahNumber);

    setState(() {
      if (wasBookmarked) {
        _bookmarks.remove(ayahNumber);
      } else {
        _bookmarks.add(ayahNumber);
      }
    });

    try {
      if (wasBookmarked) {
        await _bookmarkService.removeBookmark(ayahNumber);
      } else {
        await _bookmarkService.addBookmark(ayahNumber);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        if (wasBookmarked) {
          _bookmarks.add(ayahNumber);
        } else {
          _bookmarks.remove(ayahNumber);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update bookmark.')),
      );
    }
  }

  Future<void> _openBookmarks() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const YaseenBookmarksScreen()),
    );

    if (!mounted) return;

    final bookmarks = await _bookmarkService.getBookmarks();

    setState(() {
      _bookmarks = bookmarks.toSet();
    });
  }

  void _scrollToTop() {
    _saveProgress(1);
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _showReadingSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final theme = Theme.of(context);
            final colors = theme.colorScheme;
            final dark = theme.brightness == Brightness.dark;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  8,
                  24,
                  MediaQuery.of(context).viewInsets.bottom + 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Color(0xFF6366F1),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reading Preferences',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Customize display & text settings',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'DISPLAY LANGUAGES & TEXT',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: dark
                            ? colors.surfaceContainerHighest.withValues(
                                alpha: 0.5,
                              )
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildToggle(
                            context,
                            'English Transliteration',
                            _showEnglishTransliteration,
                            (value) {
                              setModalState(
                                () => _showEnglishTransliteration = value,
                              );
                              setState(() {});
                            },
                          ),
                          Divider(
                            height: 1,
                            color: colors.outline.withValues(alpha: 0.1),
                          ),
                          _buildToggle(
                            context,
                            'Malayalam Transliteration',
                            _showMalayalamTransliteration,
                            (value) {
                              setModalState(
                                () => _showMalayalamTransliteration = value,
                              );
                              setState(() {});
                            },
                          ),
                          Divider(
                            height: 1,
                            color: colors.outline.withValues(alpha: 0.1),
                          ),
                          _buildToggle(
                            context,
                            'English Translation',
                            _showEnglishTranslation,
                            (value) {
                              setModalState(
                                () => _showEnglishTranslation = value,
                              );
                              setState(() {});
                            },
                          ),
                          Divider(
                            height: 1,
                            color: colors.outline.withValues(alpha: 0.1),
                          ),
                          _buildToggle(
                            context,
                            'Malayalam Translation',
                            _showMalayalamTranslation,
                            (value) {
                              setModalState(
                                () => _showMalayalamTranslation = value,
                              );
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ARABIC FONT SIZE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_arabicFontSize.round()} px',
                            style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: dark
                            ? colors.surfaceContainerHighest.withValues(
                                alpha: 0.5,
                              )
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.text_decrease_rounded,
                              size: 18,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              min: 24,
                              max: 48,
                              divisions: 12,
                              value: _arabicFontSize,
                              activeColor: const Color(0xFF6366F1),
                              onChanged: (value) {
                                setModalState(() => _arabicFontSize = value);
                                setState(() {});
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.text_increase_rounded,
                              size: 18,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildToggle(
    BuildContext context,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final colors = Theme.of(context).colorScheme;
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
      ),
      value: value,
      activeColor: const Color(0xFF6366F1),
      onChanged: onChanged,
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Y A S E E N',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('•', style: TextStyle(fontSize: 14, height: 0.9)),
        ),
        Transform.translate(
          offset: const Offset(0, 1),
          child: const Text('يس', style: TextStyle(fontSize: 19)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _header(context),
        actions: [
          IconButton(
            tooltip: 'Reading settings',
            onPressed: _showReadingSettingsBottomSheet,
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            tooltip: 'Bookmarks',
            onPressed: _openBookmarks,
            icon: const Icon(Icons.bookmarks_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _buildUnifiedScrollableList(),
    );
  }

  Widget _buildSurahHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dynamic text color: White for dark mode, Deep Charcoal/Black for light mode
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF312E81),
                  Color(0xFF1E1B4B),
                ] // Rich dark purple gradient
              : const [
                  Color(0xFFEEF2FF),
                  Color(0xFFE0E7FF),
                ], // Soft light purple gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(isDark ? 0.4 : 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Watermark SVG
            Positioned(
              right: -25,
              bottom: -35,
              child: Opacity(
                opacity: isDark ? 0.12 : 0.08,
                child: SvgPicture.asset(
                  'assets/icons/worship_icons/yaseen.svg',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                ),
              ),
            ),
            // Main Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'يس',
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: textColor,
                      fontSize: 42,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yā-Sīn',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '83 Ayahs  •  Makki Surah',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor.withOpacity(0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYaseenDuaCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [const Color(0xFF2E2A67), const Color(0xFF1E1B4B)]
              : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF818CF8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dua After Surah Yaseen',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Concluding supplication',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Traditional',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF818CF8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ بِحَقِّ سُورَةِ يس وَبِمَنْ أَنْزَلَهَا وَبِمَنْ نَزَلَ بِهَا وَبِمَنْ أُنْزِلَتْ عَلَيْهِ أَنْ تُدْخِلَ شِفَاءَكَ فِي كُلِّ دَاءٍ، وَلُطْفَكَ فِي كُلِّ بَلَاءٍ، وَبَرَكَتَكَ فِي كُلِّ عُمُرٍ، وَعَافِيَتَكَ فِي كُلِّ مَرَضٍ، وَرَحْمَتَكَ فِي كُلِّ مَيِّتٍ، وَنُورَكَ فِي كُلِّ ظُلْمَةٍ، وَيُسْرَكَ فِي كُلِّ عُسْرٍ.',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: _arabicFontSize * 0.85,
              height: 2.1,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_showEnglishTransliteration) ...[
            const SizedBox(height: 16),
            Text(
              'Allahumma inni as\'aluka bi-haqqi surati yaseen wa biman anzalaha wa biman nazala biha wa biman unzilat \'alaihi an tudkhila shifa\'aka fi kulli da\'in, wa lutfaka fi kulli bala\'in, wa barakataka fi kulli \'umurin, wa \'afiyataka fi kulli maradin, wa rahmataka fi kulli mayyitin, wa nuraka fi kulli zulmatin, wa yusraka fi kulli \'usrin.',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
          if (_showMalayalamTransliteration) ...[
            const SizedBox(height: 10),
            Text(
              'അല്ലാഹുമ്മ ഇന്നീ അസ്അലുക ബി ഹഖ്ഖി സൂറതി യാസീൻ വ ബിമൻ അൻസലഹാ വ ബിമൻ നസല ബിഹാ വ ബിമൻ ഉൻസിലത് അലൈഹി അൻ തുദ്‌ഖില ശിഫാഅക ഫീ കുല്ലി ദാഇൻ, വ ലുത്‌ഫക ഫീ കുല്ലി ബലാഇൻ, വ ബറകത്തക ഫീ കുല്ലി ഉമുറിൻ, വ ആഫിയത്തക ഫീ കുല്ലി മരദിൻ, വ റഹ്‌മത്തക ഫീ കുല്ലി മയ്യിതിൻ, വ നൂറക ഫീ കുല്ലി സുൽമതിൻ, വ യുസ്‌റക ഫീ കുല്ലി ഉസ്‌റിൻ.',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
          if (_showEnglishTranslation) ...[
            const SizedBox(height: 16),
            Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text(
              'O Allah, I ask You by the right of Surah Yaseen, by the One who revealed it, by the one who brought it down, and by the one upon whom it was revealed, that You place Your healing in every illness, Your kindness in every trial, Your blessing in every life, Your wellness in every sickness, Your mercy upon every deceased, Your light in every darkness, and Your ease in every difficulty.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: colorScheme.onSurface,
              ),
            ),
          ],
          if (_showMalayalamTranslation) ...[
            const SizedBox(height: 12),
            Text(
              'അല്ലാഹുവേ, സൂറത്ത് യാസീന്റെ ഹക്ക് കൊണ്ടും, അത് അവതരിപ്പിച്ചവൻ്റെയും അത് കൊണ്ടുവന്നവൻ്റെയും അത് അവതരിപ്പിക്കപ്പെട്ടവൻ്റെയും ഹക്ക് കൊണ്ടും ഞാൻ നിന്നോട് ചോദിക്കുന്നു; എല്ലാ രോഗങ്ങളിലും നിന്റെ ശമനത്തെയും, എല്ലാ പരീക്ഷണങ്ങളിലും നിന്റെ കാരുണ്യത്തെയും, എല്ലാ ആയുസ്സിലും നിന്റെ ബറകത്തിനെയും, എല്ലാ അസുഖങ്ങളിലും നിന്റെ സുഖത്തെയും, എല്ലാ മരിച്ചവരിലും നിന്റെ റഹ്‌മത്തിനെയും, എല്ലാ ഇരുട്ടുകളിലും നിന്റെ പ്രകാശത്തെയും, എല്ലാ പ്രയാസങ്ങളിലും നിന്റെ എളുപ്പത്തെയും നീ ഉൾപ്പെടുത്തേണമേ.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReciteAgainButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
        ),
        onPressed: _scrollToTop,
        icon: const Icon(Icons.refresh_rounded, size: 20),
        label: const Text(
          'Recite Again',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildUnifiedScrollableList() {
    return ScrollablePositionedList.builder(
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      initialScrollIndex: _selectedAyah,
      padding: const EdgeInsets.only(bottom: 20),
      itemCount:
          _ayahs.length +
          3, // Header (0), Ayahs (1 to 83), Dua (84), Button (85)
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSurahHeader(context);
        }

        if (index > 0 && index <= _ayahs.length) {
          final ayah = _ayahs[index - 1];

          return YaseenAyahCard(
            key: ValueKey(ayah.ayahNumber),
            ayah: ayah,
            showEnglishTransliteration: _showEnglishTransliteration,
            showMalayalamTransliteration: _showMalayalamTransliteration,
            showEnglishTranslation: _showEnglishTranslation,
            showMalayalamTranslation: _showMalayalamTranslation,
            arabicFontSize: _arabicFontSize,
            isBookmarked: _bookmarks.contains(ayah.ayahNumber),
            isSelected: _selectedAyah == ayah.ayahNumber,
            onBookmarkTap: () => _toggleBookmark(ayah.ayahNumber),
            onTap: () => _saveProgress(ayah.ayahNumber),
          );
        }

        if (index == _ayahs.length + 1) {
          return _buildYaseenDuaCard(context);
        }

        return _buildReciteAgainButton(context);
      },
    );
  }

  void _updateSelectedAyahFromScroll() {
    final positions = _itemPositionsListener.itemPositions.value;

    if (positions.isEmpty || _ayahs.isEmpty) return;

    final visiblePositions =
        positions
            .where(
              (position) =>
                  position.itemTrailingEdge > 0 &&
                  position.itemLeadingEdge < 1 &&
                  position.index > 0 &&
                  position.index <= _ayahs.length, // Only track actual ayahs
            )
            .toList()
          ..sort((a, b) => a.itemLeadingEdge.compareTo(b.itemLeadingEdge));

    if (visiblePositions.isEmpty) return;

    final ayahNumber = visiblePositions.first.index;

    if (ayahNumber != _selectedAyah &&
        ayahNumber >= 1 &&
        ayahNumber <= _ayahs.length) {
      setState(() => _selectedAyah = ayahNumber);
      _progressService.saveProgress(ayahNumber);
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadReader();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
