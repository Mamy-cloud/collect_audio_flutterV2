import 'package:flutter/material.dart';
import '../database/research_data/research_temoin.dart';
import '../widgets/global/app_styles.dart';
import '../widgets/screens_widgets/list_temoin_widgets.dart';
import '../widgets/screens_widgets/display_data_temoin_widget.dart';
import 'formulaire_creer_temoin_screen.dart';

class ListTemoinScreen extends StatefulWidget {
  const ListTemoinScreen({super.key});

  @override
  State<ListTemoinScreen> createState() => _ListTemoinScreenState();
}

class _ListTemoinScreenState extends State<ListTemoinScreen> {
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _temoins   = [];
  bool                       _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemoins('');
    _searchCtrl.addListener(() => _loadTemoins(_searchCtrl.text));
  }

  Future<void> _loadTemoins(String query) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await ResearchTemoin.search(query);
    if (!mounted) return;
    setState(() {
      _temoins   = data;
      _isLoading = false;
    });
  }

  void _ouvrirFormulaire() {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => const FormulaireCreerTemoinScreen(),
    ).then((_) => _loadTemoins(_searchCtrl.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [

              const SizedBox(height: 24),

              const ListTemoinTitle(),

              const SizedBox(height: 20),

              SearchField(
                controller: _searchCtrl,
                onChanged:  (_) {},
              ),

              const SizedBox(height: 16),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : _temoins.isEmpty
                        ? const EmptyTemoinState()
                        : RefreshIndicator(
                            color:     Colors.white,
                            onRefresh: () => _loadTemoins(_searchCtrl.text),
                            child: ListView.builder(
                              padding:     const EdgeInsets.only(top: 4),
                              itemCount:   _temoins.length,
                              itemBuilder: (_, i) =>
                                  TemoinCard(temoin: _temoins[i]),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AddTemoinButton(onTap: _ouvrirFormulaire),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
