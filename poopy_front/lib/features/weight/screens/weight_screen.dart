import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/poopy_widgets.dart';
import '../../../shared/models/models.dart';
import '../services/weight_service.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  final WeightService _service = WeightService();
  List<Weight> _weights = [];
  bool _isLoading = true;
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWeightData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadWeightData() async {
    setState(() => _isLoading = true);
    final data = await _service.getWeights(AppConstants.currentUserId);
    setState(() {
      _weights = data;
      _isLoading = false;
    });
  }

  void _openAddWeightDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.t.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Ajouter un poids',
              style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  color: context.t.text)),
          content: TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(fontFamily: 'Quicksand', color: context.t.text),
            decoration: InputDecoration(
              hintText: 'Ex: 62.8',
              hintStyle: TextStyle(color: context.t.textMuted),
              suffixText: 'kg',
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: context.t.border)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.poids)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler',
                  style: TextStyle(
                      fontFamily: 'Quicksand', color: context.t.textDim)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.poids,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final val = double.tryParse(
                    _weightController.text.replaceAll(',', '.'));
                if (val != null) {
                  await _service.addWeight(Weight(
                    userId: AppConstants.currentUserId,
                    value: val,
                    date: DateTime.now(),
                  ));
                  _weightController.clear();
                  if (mounted) Navigator.pop(context);
                  _loadWeightData();
                }
              },
              child: const Text('Enregistrer',
                  style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasData = _weights.isNotEmpty;

    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(
              color: AppColors.poids, strokeWidth: 3));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          0, MediaQuery.of(context).padding.top + 56, 0, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EyebrowLabel('Suivi corporel'),
                Text('Mon Poids',
                    style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: t.text)),
              ],
            ),
          ),

          // Encart violet avec gestion N/C
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: PoopyCard(
              backgroundColor: AppColors.poids,
              borderRadius: 26,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('POIDS ACTUEL',
                          style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // ⚡️ DYNAMIQUE : Si vide ➔ "N/C", sinon le vrai poids
                          Text(
                            hasData ? '${_weights.last.value}' : 'N/C',
                            style: const TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1),
                          ),
                          if (hasData) ...[
                            const SizedBox(width: 4),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Text('kg',
                                  style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  Icon(Icons.scale_rounded,
                      size: 40, color: Colors.white.withOpacity(0.7)),
                ],
              ),
            ),
          ),

          // Bouton Ajouter une pesée
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            child: GestureDetector(
              onTap: _openAddWeightDialog,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: t.border, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        size: 20, color: t.text),
                    const SizedBox(width: 10),
                    Text('Nouvelle pesée',
                        style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: t.text)),
                  ],
                ),
              ),
            ),
          ),

          // Conteneur de la Courbe ou de l'état vide
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text('ÉVOLUTION',
                      style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: t.textDim)),
                ),

                // ⚡️ LOOK PROPRE : Si pas de données, on met une jolie carte d'invite
                if (!hasData)
                  PoopyCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.symmetric(
                        vertical: 40, horizontal: 20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.analytics_outlined,
                              size: 44, color: t.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'Aucune pesée enregistrée',
                            style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: t.text),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ajoute ton premier poids pour créer ta courbe !',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: t.textDim),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // Si on a des données, on dessine la courbe fl_chart originale
                  PoopyCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.fromLTRB(10, 24, 24, 10),
                    child: SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) =>
                                FlLine(color: t.border, strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  int idx = value.toInt();
                                  if (idx >= 0 && idx < _weights.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                          DateFormat('dd/MM')
                                              .format(_weights[idx].date),
                                          style: TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontSize: 10,
                                              color: t.textMuted,
                                              fontWeight: FontWeight.w600)),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 38,
                                getTitlesWidget: (value, meta) {
                                  return Text('${value.toStringAsFixed(1)}',
                                      style: TextStyle(
                                          fontFamily: 'Quicksand',
                                          fontSize: 10,
                                          color: t.textMuted,
                                          fontWeight: FontWeight.w600));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: (_weights.length - 1).toDouble(),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _weights
                                  .asMap()
                                  .entries
                                  .map((e) =>
                                      FlSpot(e.key.toDouble(), e.value.value))
                                  .toList(),
                              isCurved: _weights.length >
                                  1, // On courbe uniquement s'il y a plusieurs points
                              color: AppColors.poids,
                              barWidth: 3.5,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter:
                                    (spot, percent, barData, index) =>
                                        FlDotCirclePainter(
                                  radius: 4,
                                  color: isDark
                                      ? AppColors.surfaceDark
                                      : Colors.white,
                                  strokeWidth: 2.5,
                                  strokeColor: AppColors.poids,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.poids
                                        .withOpacity(isDark ? 0.08 : 0.25),
                                    AppColors.poids.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
