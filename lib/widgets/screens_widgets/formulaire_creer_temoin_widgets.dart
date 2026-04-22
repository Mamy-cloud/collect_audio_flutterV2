import 'package:flutter/material.dart';
import '../global/app_styles.dart';

// ── Départements et régions ───────────────────────────────────────────────────

const List<Map<String, dynamic>> kDepartements = [
  {'id': 'dept_2A', 'nom': 'Corse-du-Sud'},
  {'id': 'dept_2B', 'nom': 'Haute-Corse'},
];

const List<Map<String, dynamic>> kRegions = [
  {'id': 'reg_2A_01', 'departement_id': 'dept_2A', 'nom': 'Ajaccio'},
  {'id': 'reg_2A_02', 'departement_id': 'dept_2A', 'nom': 'Ajaccio — Gravona'},
  {'id': 'reg_2A_03', 'departement_id': 'dept_2A', 'nom': 'Ajaccio — Prunelli'},
  {'id': 'reg_2A_04', 'departement_id': 'dept_2A', 'nom': 'Ajaccio — Alata'},
  {'id': 'reg_2A_05', 'departement_id': 'dept_2A', 'nom': 'Ajaccio — Appietto'},
  {'id': 'reg_2A_06', 'departement_id': 'dept_2A', 'nom': 'Ajaccio — Afa'},
  {'id': 'reg_2A_07', 'departement_id': 'dept_2A', 'nom': 'Alta Rocca — Aullène'},
  {'id': 'reg_2A_08', 'departement_id': 'dept_2A', 'nom': 'Alta Rocca — Levie'},
  {'id': 'reg_2A_09', 'departement_id': 'dept_2A', 'nom': 'Alta Rocca — Serra-di-Scopamène'},
  {'id': 'reg_2A_10', 'departement_id': 'dept_2A', 'nom': 'Sartenais-Valinco — Sartène'},
  {'id': 'reg_2A_11', 'departement_id': 'dept_2A', 'nom': 'Sartenais-Valinco — Propriano'},
  {'id': 'reg_2A_12', 'departement_id': 'dept_2A', 'nom': 'Sartenais-Valinco — Olmeto'},
  {'id': 'reg_2A_13', 'departement_id': 'dept_2A', 'nom': 'Taravo — Petreto-Bicchisano'},
  {'id': 'reg_2A_14', 'departement_id': 'dept_2A', 'nom': 'Taravo — Santa-Maria-Sicché'},
  {'id': 'reg_2A_15', 'departement_id': 'dept_2A', 'nom': 'Gravona-Prunelli — Cauro'},
  {'id': 'reg_2A_16', 'departement_id': 'dept_2A', 'nom': 'Gravona-Prunelli — Bastelicaccia'},
  {'id': 'reg_2A_17', 'departement_id': 'dept_2A', 'nom': 'Gravona-Prunelli — Eccica-Suarella'},
  {'id': 'reg_2A_18', 'departement_id': 'dept_2A', 'nom': 'Cinarca — Calcatoggio'},
  {'id': 'reg_2A_19', 'departement_id': 'dept_2A', 'nom': 'Cinarca — Cannelle'},
  {'id': 'reg_2A_20', 'departement_id': 'dept_2A', 'nom': 'Cinarca — Ambiegna'},
  {'id': 'reg_2A_21', 'departement_id': 'dept_2A', 'nom': 'Cruzzini-Cinarca — Azzana'},
  {'id': 'reg_2A_22', 'departement_id': 'dept_2A', 'nom': 'Cruzzini-Cinarca — Murzo'},
  {'id': 'reg_2A_23', 'departement_id': 'dept_2A', 'nom': 'Cruzzini-Cinarca — Poggiolo'},
  {'id': 'reg_2A_24', 'departement_id': 'dept_2A', 'nom': 'Porto — Ota'},
  {'id': 'reg_2A_25', 'departement_id': 'dept_2A', 'nom': 'Porto — Serriera'},
  {'id': 'reg_2A_26', 'departement_id': 'dept_2A', 'nom': 'Porto — Osani'},
  {'id': 'reg_2A_27', 'departement_id': 'dept_2A', 'nom': 'Niolu-Omessa — Calacuccia'},
  {'id': 'reg_2A_28', 'departement_id': 'dept_2A', 'nom': 'Niolu-Omessa — Casamaccioli'},
  {'id': 'reg_2A_29', 'departement_id': 'dept_2A', 'nom': 'Niolu-Omessa — Corscia'},
  {'id': 'reg_2A_30', 'departement_id': 'dept_2A', 'nom': 'Balagne Sud — Mela'},
  {'id': 'reg_2A_31', 'departement_id': 'dept_2A', 'nom': 'Balagne Sud — Zilia'},
  {'id': 'reg_2A_32', 'departement_id': 'dept_2A', 'nom': 'Balagne Sud — Montegrosso'},
  {'id': 'reg_2B_01', 'departement_id': 'dept_2B', 'nom': 'Bastia'},
  {'id': 'reg_2B_02', 'departement_id': 'dept_2B', 'nom': 'Bastia — Cardo'},
  {'id': 'reg_2B_03', 'departement_id': 'dept_2B', 'nom': 'Bastia — Lupino'},
  {'id': 'reg_2B_04', 'departement_id': 'dept_2B', 'nom': 'Cap Corse — Ersa'},
  {'id': 'reg_2B_05', 'departement_id': 'dept_2B', 'nom': 'Cap Corse — Rogliano'},
  {'id': 'reg_2B_06', 'departement_id': 'dept_2B', 'nom': 'Cap Corse — Pino'},
  {'id': 'reg_2B_07', 'departement_id': 'dept_2B', 'nom': 'Cap Corse — Nonza'},
  {'id': 'reg_2B_08', 'departement_id': 'dept_2B', 'nom': 'Nebbio — Saint-Florent'},
  {'id': 'reg_2B_09', 'departement_id': 'dept_2B', 'nom': 'Nebbio — Oletta'},
  {'id': 'reg_2B_10', 'departement_id': 'dept_2B', 'nom': 'Nebbio — Murato'},
  {'id': 'reg_2B_11', 'departement_id': 'dept_2B', 'nom': "Conca d'Oro — San-Martino-di-Lota"},
  {'id': 'reg_2B_12', 'departement_id': 'dept_2B', 'nom': "Conca d'Oro — Ville-di-Pietrabugno"},
  {'id': 'reg_2B_13', 'departement_id': 'dept_2B', 'nom': 'Casinca — Vescovato'},
  {'id': 'reg_2B_14', 'departement_id': 'dept_2B', 'nom': 'Casinca — Penta-di-Casinca'},
  {'id': 'reg_2B_15', 'departement_id': 'dept_2B', 'nom': 'Casinca — Venzolasca'},
  {'id': 'reg_2B_16', 'departement_id': 'dept_2B', 'nom': 'Castagniccia — Piedicroce'},
  {'id': 'reg_2B_17', 'departement_id': 'dept_2B', 'nom': 'Castagniccia — Cervione'},
  {'id': 'reg_2B_18', 'departement_id': 'dept_2B', 'nom': 'Castagniccia — Orezza'},
  {'id': 'reg_2B_19', 'departement_id': 'dept_2B', 'nom': 'Fiumorbo-Castello — Ghisonaccia'},
  {'id': 'reg_2B_20', 'departement_id': 'dept_2B', 'nom': 'Fiumorbo-Castello — Aléria'},
  {'id': 'reg_2B_21', 'departement_id': 'dept_2B', 'nom': 'Fiumorbo-Castello — Serra-di-Fiumorbo'},
  {'id': 'reg_2B_22', 'departement_id': 'dept_2B', 'nom': 'Plaine Orientale — Linguizzetta'},
  {'id': 'reg_2B_23', 'departement_id': 'dept_2B', 'nom': 'Plaine Orientale — Tallone'},
  {'id': 'reg_2B_24', 'departement_id': 'dept_2B', 'nom': 'Plaine Orientale — Prunete'},
  {'id': 'reg_2B_25', 'departement_id': 'dept_2B', 'nom': 'Cortenais-Venaco — Corte'},
  {'id': 'reg_2B_26', 'departement_id': 'dept_2B', 'nom': 'Cortenais-Venaco — Venaco'},
  {'id': 'reg_2B_27', 'departement_id': 'dept_2B', 'nom': 'Cortenais-Venaco — Soveria'},
  {'id': 'reg_2B_28', 'departement_id': 'dept_2B', 'nom': 'Bozio — Sermano'},
  {'id': 'reg_2B_29', 'departement_id': 'dept_2B', 'nom': 'Bozio — Bustanico'},
  {'id': 'reg_2B_30', 'departement_id': 'dept_2B', 'nom': 'Bozio — Mazzola'},
  {'id': 'reg_2B_31', 'departement_id': 'dept_2B', 'nom': 'Balagne — Calvi'},
  {'id': 'reg_2B_32', 'departement_id': 'dept_2B', 'nom': "Balagne — L'Île-Rousse"},
  {'id': 'reg_2B_33', 'departement_id': 'dept_2B', 'nom': 'Balagne — Belgodère'},
  {'id': 'reg_2B_34', 'departement_id': 'dept_2B', 'nom': 'Balagne — Pigna'},
  {'id': 'reg_2B_35', 'departement_id': 'dept_2B', 'nom': 'Ostriconi — Pietralba'},
  {'id': 'reg_2B_36', 'departement_id': 'dept_2B', 'nom': 'Ostriconi — Novella'},
  {'id': 'reg_2B_37', 'departement_id': 'dept_2B', 'nom': 'Ostriconi — Palasca'},
];

// ── Champ texte formulaire ────────────────────────────────────────────────────

class FormulaireTextField extends StatelessWidget {
  final TextEditingController controller;
  final String                label;
  final String?               hint;
  final bool                  readOnly;
  final VoidCallback?         onTap;
  final Widget?               suffix;

  const FormulaireTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style:      AppTextStyles.input,
      readOnly:   readOnly,
      onTap:      onTap,
      decoration: AppInputDecoration.of(label, hint: hint).copyWith(
        suffixIcon: suffix,
      ),
    );
  }
}

// ── Dropdown département ──────────────────────────────────────────────────────

class DepartementDropdown extends StatelessWidget {
  final String?               value;
  final ValueChanged<String?> onChanged;

  const DepartementDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value:         value,
      onChanged:     onChanged,
      dropdownColor: AppColors.surface,
      style:         AppTextStyles.input,
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
      decoration: AppInputDecoration.of('Département'),
      items: kDepartements.map((d) => DropdownMenuItem<String>(
        value: d['id'] as String,
        child: Text(d['nom'] as String, style: AppTextStyles.input),
      )).toList(),
    );
  }
}

// ── Dropdown région ───────────────────────────────────────────────────────────

class RegionDropdown extends StatelessWidget {
  final String?               value;
  final String?               departementId;
  final ValueChanged<String?> onChanged;

  const RegionDropdown({
    super.key,
    required this.value,
    required this.departementId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (departementId == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        AppColors.inputFill,
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: const Color(0xFF333333)),
        ),
        child: const Row(children: [
          Icon(Icons.info_outline, color: AppColors.textMuted, size: 16),
          SizedBox(width: 8),
          Text("Sélectionnez d'abord un département",
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ]),
      );
    }

    final regions = kRegions
        .where((r) => r['departement_id'] == departementId)
        .toList();

    return DropdownButtonFormField<String>(
      value:         value,
      onChanged:     onChanged,
      dropdownColor: AppColors.surface,
      style:         AppTextStyles.input,
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
      decoration: AppInputDecoration.of('Région / Micro-région'),
      items: regions.map((r) => DropdownMenuItem<String>(
        value: r['id'] as String,
        child: Text(r['nom'] as String, style: AppTextStyles.input),
      )).toList(),
    );
  }
}

// ── Widget contacts ───────────────────────────────────────────────────────────

class ContactsField extends StatefulWidget {
  final List<Map<String, String>> contacts;
  final void Function(List<Map<String, String>> contacts) onChanged;

  const ContactsField({
    super.key,
    required this.contacts,
    required this.onChanged,
  });

  @override
  State<ContactsField> createState() => _ContactsFieldState();
}

class _ContactsFieldState extends State<ContactsField> {
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();

  void _addContact() {
    final nom = _nomCtrl.text.trim();
    final tel = _telCtrl.text.trim();
    if (nom.isEmpty) return;

    final updated = List<Map<String, String>>.from(widget.contacts)
      ..add({'nom': nom, 'telephone': tel});

    widget.onChanged(updated);
    _nomCtrl.clear();
    _telCtrl.clear();
  }

  void _removeContact(int index) {
    final updated = List<Map<String, String>>.from(widget.contacts)
      ..removeAt(index);
    widget.onChanged(updated);
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contacts', style: AppTextStyles.label),
        const SizedBox(height: 8),

        // ── Liste des contacts ajoutés ────────────────────────────────────
        if (widget.contacts.isNotEmpty) ...[
          ...widget.contacts.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color:        AppColors.inputFill,
                borderRadius: BorderRadius.circular(10),
                border:       Border.all(color: const Color(0xFF333333)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['nom'] ?? '',
                            style: AppTextStyles.input
                                .copyWith(fontSize: 14)),
                        if ((c['telephone'] ?? '').isNotEmpty)
                          Text(c['telephone']!,
                              style: AppTextStyles.label
                                  .copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _removeContact(i),
                    child: const Icon(Icons.close,
                        size: 16, color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
        ],

        // ── Formulaire ajout contact ──────────────────────────────────────
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _nomCtrl,
                style:      AppTextStyles.input,
                decoration: AppInputDecoration.of(
                    'Nom du contact', hint: 'ex. Marie'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _telCtrl,
                style:      AppTextStyles.input,
                keyboardType: TextInputType.phone,
                decoration: AppInputDecoration.of(
                    'Tél.', hint: '06...'),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _addContact,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color:        AppColors.buttonBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add,
                    color: AppColors.background, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Bouton Ajouter / Modifier ─────────────────────────────────────────────────

class AjouterTemoinButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool          isLoading;
  final String?       label;

  const AjouterTemoinButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style:     AppButtonStyle.primary,
        child: isLoading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.black))
            : Text(label ?? 'Ajouter', style: AppTextStyles.button),
      ),
    );
  }
}
