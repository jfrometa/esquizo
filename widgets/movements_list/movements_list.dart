import 'dart:async';
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:starter_architecture_flutter_firebase/helpers/currency_converter.dart';
import 'package:starter_architecture_flutter_firebase/helpers/text_capitalization.dart';
import 'package:starter_architecture_flutter_firebase/navigation/app_router.dart';
import 'package:starter_architecture_flutter_firebase/src/theme/app_theme.dart';
import 'package:starter_architecture_flutter_firebase/themes/colors_palette.dart';
import 'package:starter_architecture_flutter_firebase/widgets/localization/teapayment_localization.dart';
import 'package:starter_architecture_flutter_firebase/widgets/movements_list/movement_not_found.dart';
import 'package:starter_architecture_flutter_firebase/widgets/movements_list/movements_filters.dart';
import 'package:starter_architecture_flutter_firebase/widgets/movements_list/no_movements_sign.dart';
import 'package:starter_architecture_flutter_firebase/widgets/nav_component/nav_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:natasha/movements_wallet/domain/infrastructure/dto/movements_details_dto.dart';
import 'package:natasha/subscriptions/application/subscription_notifier_providers.dart';
import 'package:natasha/subscriptions/infrastructure/dto/subscription_movement_dto.dart';

class MovementListData {
  const MovementListData(
    this.title,
    this.type,
    this.amount,
    this.status,
    this.date,
    this.id,
  );
  final String title;
  final String id;
  final String type;
  final double amount;
  final String status;
  final int date;

  String get dateTime {
    final DateFormat formatter = DateFormat.yMMMMd('en_US');
    final date = DateTime.fromMillisecondsSinceEpoch(date);
    return formatter.format(date);
  }

  String get stringAmount => amount.toStringAsFixed(2);

  Widget get icon =>
      _movementsMapIcon(type.toMovementType(), status.toMovementStatus());

  TextStyle get statusTextStyle => _getStatusColor(this);

  TextStyle _getStatusColor(MovementListData movement) {
    CustomAppTheme customAppTheme = CustomAppTheme(
      colorsPalette: ColorsPalette.light,
    );

    switch (movement.status) {
      case 'Completed':
        return customAppTheme.textStyles.bodyMedium.copyWith(
          color: customAppTheme.colorsPalette.positiveAction,
        );
      case 'Pending':
        return customAppTheme.textStyles.bodyMedium.copyWith(
          color: customAppTheme.colorsPalette.alert,
        );
      case 'Canceled':
        return customAppTheme.textStyles.bodyMedium.copyWith(
          color: customAppTheme.colorsPalette.neutral6,
        );
      default:
        return customAppTheme.textStyles.bodyMedium.copyWith(
          color: customAppTheme.colorsPalette.black,
        );
    }
  }

  Widget _movementsMapIcon(MovementType type, MovementStatus status) {
    switch (type) {
      case MovementType.DEPOSIT:
        switch (status) {
          case MovementStatus.PENDING:
            return _buildIconWidget('movement_deposit_pending');

          case MovementStatus.COMPLETED:
            return _buildIconWidget('movement_deposit_complete');

          case MovementStatus.CANCELLED:
            return _buildIconWidget('movement_deposit_cancelled');

          case MovementStatus.NEW:
          case MovementStatus.UNKNOWN:
            return _buildIconWidget('movement_deposit_pending');
        }

      case MovementType.WITHDRAWAL:
        switch (status) {
          case MovementStatus.PENDING:
            return _buildIconWidget('movement_withdrawal_complete');

          case MovementStatus.COMPLETED:
            return _buildIconWidget('movement_withdrawal_complete');

          case MovementStatus.CANCELLED:
            return _buildIconWidget('movement_withdrawal_cancelled');

          case MovementStatus.UNKNOWN:
          case MovementStatus.NEW:
            return _buildIconWidget('movement_withdrawal_complete');
        }

      case MovementType.TRANSFER:
        switch (status) {
          case MovementStatus.PENDING:
            return _buildIconWidget('movement_transfer_received');

          case MovementStatus.COMPLETED:
            return _buildIconWidget('movement_transfer_received');

          case MovementStatus.CANCELLED:
            return _buildIconWidget('movement_transfer_received');

          case MovementStatus.NEW:
          case MovementStatus.UNKNOWN:
            return _buildIconWidget('movement_transfer_received');
        }

      case MovementType.INTEREST:
        switch (status) {
          case MovementStatus.PENDING:
            return _buildIconWidget('movement_Interest_received');

          case MovementStatus.COMPLETED:
            return _buildIconWidget('movement_Interest_received');

          case MovementStatus.CANCELLED:
            return _buildIconWidget('movement_Interest_received');

          case MovementStatus.NEW:
          case MovementStatus.UNKNOWN:
            return _buildIconWidget('movement_Interest_received');
        }

      case MovementType.PRODUCT_SUBSCRIBED:
        switch (status) {
          case MovementStatus.PENDING:
            return _buildIconWidget('movement_product_subscription_pending');

          case MovementStatus.COMPLETED:
            return _buildIconWidget('movement_product_subscribed');

          case MovementStatus.CANCELLED:
            return _buildIconWidget('movement_product_subscribed');

          case MovementStatus.NEW:
          case MovementStatus.UNKNOWN:
            return _buildIconWidget('movement_product_subscription_pending');
        }
      case MovementType.UNKNOWN:
        switch (status) {
          case MovementStatus.PENDING:
            return _buildIconWidget('movement_general');

          case MovementStatus.COMPLETED:
            return _buildIconWidget('movement_general');

          case MovementStatus.CANCELLED:
            return _buildIconWidget('movement_general');

          case MovementStatus.NEW:
          case MovementStatus.UNKNOWN:
            return _buildIconWidget('movement_general');
        }
      case MovementType.FEE:
        return _buildIconWidget('movement_general');
    }
  }

  Widget _buildIconWidget(String type) {
    return Center(
      child: SvgPicture.asset(
        'assets/movements/$type.svg',
      ),
    );
  }
}

class MovementsList extends ConsumerStatefulWidget {
  const MovementsList({
    super.key,
    this.hide = false,
    required this.id,
    required this.type,
    required this.scrollController,
    this.resetMovementsProvider,
  });

  final bool hide;
  final String id;
  final FilterType type;
  final ScrollController scrollController;
  final Provider<bool?>? resetMovementsProvider;

  @override
  ConsumerState createState() => _MovementsListState();
}

class _MovementsListState extends ConsumerState<MovementsList> {
  List<MovementListData> _currentMovementsList = [];

  MovementsFilters _filters = MovementsFilters();

  bool _needsNotFoundSign = false;
  bool _isResetFilterAvaliable = false;

  int _currentPage = 0;
  int _totalPages = 1;
  int _totalMovements = 0;
  bool _isLoading = true;
  bool _isResetingMovements = false;
  bool _isFilterOptionEnabled = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setScrollingToBottomMovementsFetchTrigger();
    });
  }

  @override
  void dispose() {
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeScreen();
      _setOnRefreshMovementsTrigger();
    });
  }

  bool get _isLastMovement => _totalMovements <= _currentMovementsList.length;
  bool get _isLastPage => _currentPage == _totalPages;
  bool get _isMovementListAvailable =>
      _currentMovementsList.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return _isLoading ? loading : walletMovements;
  }

  //////////   //////////  //////////  ////////// WIDGETS   //////////  //////////  //////////  //////////

  Widget get _noMovementsFoundOrUnavailable => _needsNotFoundSign &&
          _isResetFilterAvaliable
      ? const Padding(
          padding:
              EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 40.0),
          child: MovementsNotFound(),
        )
      : Padding(
          padding: const EdgeInsets.only(
              top: 16.0, left: 16.0, right: 16.0, bottom: 40.0),
          child: EmptyMovementsSign(
            onTap: () async => context.router.push(const DepositRouterRoute()),
          ),
        );

  Widget get _movementsWidget => GroupedListView<MovementListData, String>(
        sort: false,
        useStickyGroupSeparators: true,
        elements: _currentMovementsList,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        groupBy: (element) => element.dateTime,
        groupHeaderBuilder: (movement) => _createHeader(movement.dateTime),
        groupSeparatorBuilder: (date) => _createSeparator(),
        indexedItemBuilder: (_, movement, index) => _createRow(movement, index),
      );

  Widget get listOrSign => !_isMovementListAvailable
      ? _noMovementsFoundOrUnavailable
      : _movementsWidget;

  CustomAppTheme get _theme => ref.read(appThemeProvider);

  ColorsPalette get _colorsPalette => ref.read(appThemeProvider).colorsPalette;

  SizedBox get loading => const SizedBox(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );

  InkWell get filterButton => InkWell(
        onTap: () async {
          await showModalBottomSheet(
            useRootNavigator: true,
            context: context,
            isScrollControlled: true,
            builder: (context) => SafeArea(
              bottom: false,
              child: MovementsFiltersModal(
                filters: _filters,
                onApplyFilters: (filters) async {
                  _isFilterOptionEnabled = true;
                  await _applyNewFilter(filters);
                },
                filterType: widget.type,
              ),
            ),
          );
        },
        child: Text(
          'movements.filters_label'.t(),
          style: _theme.textStyles.button,
        ),
      );

  InkWell get clearButton => InkWell(
        enableFeedback: _isResetFilterAvaliable,
        onTap: () async {
          if (!_isResetFilterAvaliable) {
            return;
          }
          _isLoading = true;
          _filters = MovementsFilters();
          _isFilterOptionEnabled = false;
          _isResetFilterAvaliable = false;

          _updateCurrentMovementsList([]);

          await _applyNewFilter(_filters);
        },
        child: _isResetFilterAvaliable
            ? Text(
                'home.filters.clear_filters'.t(),
                style: _isResetFilterAvaliable
                    ? _theme.textStyles.button
                    : _theme.textStyles.button.copyWith(
                        color: _colorsPalette.secondary.withOpacity(0.3),
                      ),
              )
            : const SizedBox(),
      );

  Column get walletMovements => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'movements.movements_label'.t()} ($_totalMovements)',
                  style: _theme.textStyles.headlineLarge,
                ),
                Row(
                  children: [
                    (_isResetFilterAvaliable | !_needsNotFoundSign)
                        ? filterButton
                        : const SizedBox(),
                    const SizedBox(
                      width: 8,
                    ),
                    _isResetFilterAvaliable ? clearButton : const SizedBox(),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          listOrSign,
        ],
      );

  //////////  //////////  //////////  ////////// FUNCTIONS   //////////  //////////  //////////  //////////

  Future<void> _initializeScreen() async {
    try {
      if (!mounted) {
        return;
      }
      _isResetingMovements = true;
      _isLoading = true;

      var walletMovements = await _fetchMovementsList(_filters);
      _updateCurrentMovementsList(walletMovements);
    } catch (error) {
      log(error.toString());
      _updateCurrentMovementsList([]);
    }
  }

  void _updateCurrentMovementsList(List<MovementListData> walletMovements) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _currentMovementsList = walletMovements;
      });
    }
  }

  void _setScrollingToBottomMovementsFetchTrigger() {
    widget.scrollController.addListener(() async {
      if (widget.scrollController.position.pixels ==
          widget.scrollController.position.maxScrollExtent) {
        if (!_isLoading && _isLastPage || _isLastMovement) {
          return;
        }

        _isLoading = true;

        final movementsUpdated =
            await _fetchMovementsListNextPage(_filters, _currentPage);

        _updateCurrentMovementsList(movementsUpdated);
      }
    });
  }

  void _setOnRefreshMovementsTrigger() {
    switch (widget.type) {
      case FilterType.BASEWALLETS:
      case FilterType.SMARTWALLETS:
        if (widget.resetMovementsProvider == null) {
          return;
        }

        ref.listenManual(widget.resetMovementsProvider!, (_, __) async {
          _isResetingMovements = true;
          _currentMovementsList = [];

          final refreshed = await _fetchMovementsList(_filters);

          _updateCurrentMovementsList(refreshed);
        });

        break;
      case FilterType.SUBSCRIPTIONS:
        break;
    }
  }

  Widget _createSeparator() {
    return ColoredBox(
      color: Colors.grey.withOpacity(0.3),
      child: const SizedBox(
        height: 1,
      ),
    );
  }

  Widget _createHeader(String date) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          date.toUpperCase(),
          textAlign: TextAlign.left,
          style: ref.read(appThemeProvider).textStyles.bodyMedium,
        ),
      ),
    );
  }

  Widget _createRow(MovementListData movement, int index) {
    CustomAppTheme theme = ref.read(appThemeProvider);
    final isBottomMovement = index == _currentMovementsList.length - 1;

    return Column(
      children: [
        NavComponent(
          leading: movement.icon,
          backgroundColor: theme.colorsPalette.white,
          leadingBackgroundColor: theme.colorsPalette.neutral2,
          title: 'movements.${movement.type.toLowerCase()}'.t(),
          subtitle: movement.title.capitalize(),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    widget.hide
                        ? '€ --.--'
                        : movement.amount.convertToCurrency('EUR'),
                    style: theme.textStyles.headlineLarge,
                  ),
                ],
              ),
              Text(
                movement.status.capitalize(),
                style: movement.statusTextStyle,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (isBottomMovement && !_isLastMovement)
          Center(
            child: CircularProgressIndicator(
              color: theme.colorsPalette.tertiary,
            ),
          )
      ],
    );
  }

  //////////  //////////  //////////  ////////// fetch movements   //////////  //////////  //////////  //////////

  Future<List<MovementListData>> _fetchMovementsList(
    MovementsFilters filters,
  ) async {
    try {
      // ignore: prefer_typing_uninitialized_variables
      var rawData;

      Map<String, dynamic> params = _createQueryParamsFrom(filters, null);

      switch (widget.type) {
        case FilterType.SMARTWALLETS:
        case FilterType.BASEWALLETS:
          rawData = await _fetchWalletsMovements(params);

          break;
        case FilterType.SUBSCRIPTIONS:
          rawData = await _fetchSubscriptionsMovements(params);

          break;
      }

      return _createMovementList(filters, rawData);
    } catch (e) {
      throw Exception('Error while getting filters $e');
    }
  }

  Future<List<MovementListData>> _fetchMovementsListNextPage(
    MovementsFilters filters,
    int page,
  ) async {
    try {
      // ignore: prefer_typing_uninitialized_variables
      List<MovementListData> rawData;
      _isResetingMovements = false;
      _isResetFilterAvaliable = false;

      Map<String, dynamic> params = _createQueryParamsFrom(filters, page);

      switch (widget.type) {
        case FilterType.SMARTWALLETS:
        case FilterType.BASEWALLETS:
          rawData = await _fetchWalletsMovements(params);

          break;
        case FilterType.SUBSCRIPTIONS:
          rawData = await _fetchSubscriptionsMovements(params);

          break;
      }

      return _createMovementList(filters, rawData);
    } catch (e) {
      throw Exception('Error while getting filters $e');
    }
  }

  Future<List<MovementListData>> _fetchSubscriptionsMovements(
    Map<String, dynamic> params,
  ) async {
    final movements = await ref
        .read(subscriptionMovementsNotifierProvider.notifier)
        .subscriptionMovements(widget.id, params);

    return movements.fold((error) {
      setState(() {
        _needsNotFoundSign = true;
      });

      return [];
    }, (success) {
      setState(() {
        _totalPages = success.pages.totalPages;
        _currentPage = success.pages.page;
        _totalMovements = success.pages.totalElements;
        _needsNotFoundSign = success.isEmpty ?? true;
      });

      final newMovements = success.embedded.movementsSubscriptions;

      return _castMovementsToSubscriptionsMovements(
        newMovements,
        _currentMovementsList,
      );
    });
  }

  Future<List<MovementListData>> _fetchWalletsMovements(
    Map<String, dynamic> params,
  ) async {
    final movements = await ref
        .read(walletsMovementsNotifierProvider.notifier)
        .getWalletMovementsList(widget.id, params);

    return movements.fold((error) {
      setState(() {
        _needsNotFoundSign = true;
      });
      log('errro fetching wallet movements: $error');
      return [];
    }, (success) {
      setState(() {
        _totalPages = success.pages.totalPages;
        _currentPage = success.pages.page;
        _totalMovements = success.pages.totalElements;
        _needsNotFoundSign = success.isEmpty ?? true;
      });

      final newMovements = success.embedded.MovementsWallet;

      return _castMovementsToWalletMovements(
        newMovements,
        _currentMovementsList,
      );
    });
  }

  //////////  //////////  //////////  //////////  transform data //////////  //////////  //////////  //////////

  List<MovementListData> _createMovementList(
    MovementsFilters filters,
    List<MovementListData> movements,
  ) {
    List<MovementListData> complete = [];

    if (_currentMovementsList.isNotEmpty && !_isResetingMovements) {
      List<MovementListData> combination = [
        ..._currentMovementsList,
        ...movements
      ];
      complete = combination.toSet().toList();

      complete.sort(
        (a, b) {
          return b.date.compareTo(a.date);
        },
      );
    }

    if (_currentMovementsList.isEmpty && _isResetingMovements) {
      complete = movements;
    }

    final filtered = _applyLocalfiltering(filters, complete);

    _toggleClearButtonAvailability(filters);

    return filtered;
  }

  void _toggleClearButtonAvailability(MovementsFilters filters) {
    final date = filters.from != null || filters.to != null;
    final amount = filters.minAmount != null || filters.maxAmount != null;
    final typeField = filters.types != null && filters.types!.isNotEmpty;
    final typeFieldArr = typeField && ((filters.types?.length ?? 0) > 1);
    final status = filters.status != null && filters.status != 'all';

    if (date || amount || typeField || typeFieldArr || status) {
      _isResetFilterAvaliable = true;
    }
  }

  List<MovementListData> _castMovementsToSubscriptionsMovements(
    movements,
    List<MovementListData> list,
  ) {
    try {
      final subsMovements = movements as List<SubscriptionMovementsDTO>;

      list = subsMovements
          .map(
            (e) => MovementListData(
              e.subscriptionType.capitalize(),
              e.type.capitalize(),
              e.amount,
              e.status.capitalize(),
              e.movementDate,
              e.movementId,
            ),
          )
          .toList();

      _needsNotFoundSign = false;
    } catch (err) {
      log(err.toString());
      _needsNotFoundSign = true;
      list = [];
    }
    return list;
  }

  List<MovementListData> _castMovementsToWalletMovements(
    movements,
    List<MovementListData> list,
  ) {
    try {
      final walletMovements = movements as List<MovementsDetailsDTO>;

      list = walletMovements
          .map(
            (e) => MovementListData(
              (e.productName?.t() ?? 'unknown').capitalize(),
              e.type.capitalize(),
              e.amount,
              e.status.capitalize(),
              e.movementDate,
              e.movementId,
            ),
          )
          .toList();

      _needsNotFoundSign = false;
    } catch (err) {
      log(err.toString());

      _needsNotFoundSign = true;
      list = [];
    }

    return list;
  }

  Map<String, dynamic> _createQueryParamsFrom(
    MovementsFilters filters,
    int? page,
  ) {
    final typeField = filters.types != null && filters.types!.isNotEmpty;
    final typeFieldArr = typeField && ((filters.types?.length ?? 0) > 1);
    final status = filters.status != null && filters.status != 'all';

    Map<String, dynamic> output = {};

    if (status) {
      output.addAll({'status~eq': filters.status!.toUpperCase()});
    }

    if (typeFieldArr) {
      filters.types?.forEach((element) {
        output.addAll({'type~in': element});
      });
    }

    if (!typeFieldArr && typeField) {
      output.addAll({'type~eq': filters.types!});
    }

    if (page != null && _currentPage <= _totalPages) {
      _currentPage++;
      output.addAll({'page': '$_currentPage'});
    }

    return output;
  }

  //////////  //////////  //////////  //////////  filtering //////////  //////////  //////////  //////////

  List<MovementListData> _applyLocalfiltering(
    MovementsFilters filters,
    List<MovementListData> movementsListData,
  ) {
    _isResetingMovements = false;

    final date = filters.from != null || filters.to != null;
    final amount = filters.minAmount != null || filters.maxAmount != null;
    final all = date && amount;
    //TODO: - ADD DATES as section header TO LIST

    final List<MovementListData> filteredOutput = [];

    try {
      if (date) {
        final filter = movementsListData
            .where(
              (movement) => _dateFilter(filters, movement),
            )
            .toList();

        filteredOutput.addAll(filter);
      }

      if (amount) {
        final filter = movementsListData
            .where(
              (movement) => _amountFilter(filters, movement),
            )
            .toList();

        filteredOutput.addAll(filter);
      }

      if (all) {
        filteredOutput.clear();
        final filter = filteredOutput.where((movement) {
          final bool resultAmount = _amountFilter(filters, movement);
          final bool resultDate = _dateFilter(filters, movement);
          final result = resultAmount && resultDate;
          return result;
        });

        filteredOutput.addAll(filter);
      }

      final result = filteredOutput.isEmpty && !_isResetFilterAvaliable
          ? movementsListData
          : filteredOutput;

      return result;
    } catch (e) {
      throw Exception('Error while getting Filters $e');
    }
  }

  Future<void> _applyNewFilter(MovementsFilters filters) async {
    try {
      _isResetingMovements = true;
      _currentMovementsList = [];
      _filters = filters;
      _isResetFilterAvaliable = false;
      _isLoading = true;

      final walletMovement = await _fetchMovementsList(filters);

      _updateCurrentMovementsList(walletMovement);
    } catch (error) {
      log(error.toString());
    }
  }

  bool _dateFilter(MovementsFilters filters, MovementListData movement) {
    var date = DateTime.fromMillisecondsSinceEpoch(movement.date);

    final isFrom = filters.from != null;
    final isTo = filters.to != null;

    if (isFrom && isTo) {
      final isFromOK = date.compareTo(filters.from!) >= 0;
      final isToOK = date.compareTo(filters.to!) <= 0;

      return isFromOK && isToOK;
    }

    if (isFrom) {
      return date.compareTo(filters.from!) >= 0;
    }

    if (isTo) {
      return date.compareTo(filters.to!) <= 0;
    }

    return false;
  }

  bool _amountFilter(MovementsFilters filters, MovementListData movement) {
    final amount = movement.amount.abs();

    final isMin = filters.minAmount != null;
    final isMax = filters.maxAmount != null;

    if (isMin && isMax) {
      final isMaxOk = amount <= (filters.maxAmount ?? 0.0);
      final isMinOk = amount >= (filters.minAmount ?? 0.0);

      return isMinOk && isMaxOk;
    }

    if (isMin) {
      return amount >= (filters.minAmount!);
    }

    if (isMax) {
      return amount <= (filters.maxAmount!);
    }

    return false;
  }
}
