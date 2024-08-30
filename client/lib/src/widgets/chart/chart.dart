import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/widgets/chart/chart_data.dart';
import 'package:starter_architecture_flutter_firebase/widgets/chart/chart_painter.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:starter_architecture_flutter_firebase/widgets/tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:natasha/entities/wallet_balance_history_report/wallet_interest_history.dart';
import 'package:natasha/entities/wallet_controller/client_wallet/client_wallet.dart';
import 'package:natasha/notifiers/index.dart';

class Chart extends ConsumerStatefulWidget {
  const Chart({super.key, required this.graph, required this.hide});

  final WalletInterestHistoryReport graph;
  final bool hide;

  @override
  ConsumerState createState() => _ChartState();
}

class _ChartState extends ConsumerState<Chart>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ChartData _data;
  late int _lastIndex;

  final hideChart = ChartData(values: [0.0], labels: ['']);

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    _tabController.index = 0;

    _lastIndex = _tabController.index;

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _lastIndex = _tabController.index;
          _data = _plotPoints(_lastIndex);
        });
      } else {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ChartData _plotPoints(section) {
    if (widget.hide) {
      return hideChart;
    }

    switch (section) {
      case 0:
        return _chartAdapter(widget.graph.last7Days);
      case 1:
        return _chartAdapter(widget.graph.month);
      case 2:
        return _chartAdapter(widget.graph.year);
      case 3:
        return _chartAdapter(widget.graph.allTime);

      default:
        return hideChart;
    }
  }

  ChartData _chartAdapter(Map<String, double> plotPoints) {
    List<String> keys = [];
    List<double> values = [];

    plotPoints.forEach((key, value) {
      keys.add(key);
      values.add(value);
    });

    return ChartData(
      values: values,
      labels: keys,
    );
  }

  @override
  Widget build(BuildContext context) {
    CustomAppTheme customAppTheme = ref.read(appThemeProvider);

    _data = _plotPoints(_lastIndex);

    final ClientWallets? baseWallet =
        ref.watch(clientWalletStateNotifierProvider).maybeWhen(
              orElse: () => null,
              data: (data) => data.base,
            );

    return Column(
      children: [
        Center(
          child: Tabs(
            height: 30,
            backgroundColor: Colors.transparent,
            controller: _tabController,
            indicatorColor: Colors.transparent,
            indicatorBorder: Border.all(
              color: widget.hide
                  ? Colors.transparent
                  : customAppTheme.colorsPalette.secondary7,
            ),
            tabs: [
              Tab(
                text: 'home.graph_filter.last_7'.t().toUpperCase(),
              ),
              Tab(
                text: 'home.graph_filter.month'.t().toUpperCase(),
              ),
              Tab(
                text: 'home.graph_filter.year'.t().toUpperCase(),
              ),
              Tab(
                text: 'home.graph_filter.all_time'.t().toUpperCase(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        chartPainter(customAppTheme, baseWallet)
      ],
    );
  }

  CustomPaint chartPainter(
    CustomAppTheme customAppTheme,
    ClientWallets? baseWallet,
  ) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      foregroundPainter: ChartPainter(
        axisTextStyle: customAppTheme.textStyles.bodySmall,
        labelTextStyle: customAppTheme.textStyles.bodySmall,
        color: customAppTheme.colorsPalette.primary,
        data: _data,
        currency: baseWallet?.currency ?? 'EUR',
      ),
    );
  }
}
