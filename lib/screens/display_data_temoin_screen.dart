import 'package:flutter/material.dart';
import '../../../database/conserve_data/conserve_data_to_sqlite.dart';
import '../../../widgets/screens_widgets/display_data_temoin_widget.dart';

class DisplayDataTemoinScreen extends StatefulWidget {
  const DisplayDataTemoinScreen({super.key});

  @override
  State<DisplayDataTemoinScreen> createState() =>
      _DisplayDataTemoinScreenState();
}

class _DisplayDataTemoinScreenState extends State<DisplayDataTemoinScreen> {
  List<Map<String, dynamic>> _temoins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemoins();
  }

  Future<void> _loadTemoins() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final data = await ConserveDataToSqlite.getAllInfoPersoTemoin();
    if (!mounted) return;
    setState(() {
      _temoins   = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_temoins.isEmpty) {
      return const EmptyTemoinState();
    }

    return RefreshIndicator(
      color:    Colors.white,
      onRefresh: _loadTemoins,
      child: ListView.builder(
        padding:     const EdgeInsets.only(top: 4),
        itemCount:   _temoins.length,
        itemBuilder: (_, i) => TemoinCard(temoin: _temoins[i]),
      ),
    );
  }
}
