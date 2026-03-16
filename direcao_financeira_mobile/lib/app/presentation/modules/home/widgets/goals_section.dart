import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import 'package:direcao_financeira_mobile/app/core/theme/app_colors.dart';

class GoalsSection extends GetView<HomeController> {
  const GoalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final metas = controller.metas;
      final totalMetas = metas.length;
      final concluidas = metas
          .where((m) => (m['percentual'] as double) >= 100)
          .length;
      final progressoGeral = totalMetas > 0
          ? metas.fold(0.0, (total, m) => total + (m['percentual'] as double)) /
                totalMetas
          : 0.0;

      return LayoutBuilder(
        builder: (context, constraints) {
          final stackHeader = constraints.maxWidth < 400;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                stackHeader
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF6B21A8,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.flag_rounded,
                                  color: Color(0xFF6B21A8),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Minhas Metas',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$concluidas de $totalMetas concluidas',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _buildManageButton(),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF6B21A8,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.flag_rounded,
                                    color: Color(0xFF6B21A8),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Minhas Metas',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '$concluidas de $totalMetas concluidas',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildManageButton(),
                        ],
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progresso Geral',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    Text(
                      '${progressoGeral.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progressoGeral / 100,
                    backgroundColor: Colors.white.withOpacity(0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.teal,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 16),
                ...metas.map((meta) => _buildGoalItem(meta)),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildManageButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Gerenciar',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.6),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(Map<String, dynamic> meta) {
    final atual = meta['atual'] as double;
    final objetivo = meta['meta'] as double;
    final percentual = meta['percentual'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined, color: Colors.white38, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  meta['nome'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${percentual.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'R\$ ${atual.toStringAsFixed(2).replaceAll('.', ',')} de R\$ ${objetivo.toStringAsFixed(2).replaceAll('.', ',')}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentual / 100,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
