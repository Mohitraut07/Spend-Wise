import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:spendwise/data/constant_values.dart';
import 'package:spendwise/model/transaction.dart';
import 'package:spendwise/provider/monetary_units.dart';

import 'package:spendwise/provider/transaction_provider.dart';
import 'package:spendwise/provider/user_provider.dart';
import 'package:spendwise/screens/add_update_transaction_screen.dart';
import 'package:spendwise/screens/setting_screen.dart';
import 'package:spendwise/screens/user_detail_screen.dart';
import 'package:spendwise/screens/view_all_transaction_screen.dart';
import 'package:spendwise/utils/fetch_all_data.dart';

import 'package:spendwise/widgits/transaction_card.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TransactionFilter {
  byMonth,
  byWeek,
}

class HomeScreen extends HookConsumerWidget {
  HomeScreen({super.key});
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = useMemoized(SharedPreferences.getInstance);
    final snapshot = useFuture(future, initialData: null);

    final isVisibile = useState(false);
    final filter = useState(TransactionFilter.byMonth);
    final transactions = filter.value == TransactionFilter.byMonth
        ? ref.watch(transactionProvider.notifier).transactionsofMonth()
        : ref.watch(transactionProvider.notifier).transactionofWeek();

    useEffect(() {
      final preferences = snapshot.data;
      if (preferences == null) {
        return;
      }
      filter.value = preferences.getString('filter') == "week"
          ? TransactionFilter.byWeek
          : TransactionFilter.byMonth;
      return null;
    }, [snapshot.data]);

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Home",
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const UserDetailScreen();
                }));
              },
              icon: Icon(
                MdiIcons.accountCircleOutline,
                color: Theme.of(context).colorScheme.onBackground,
                size: 25,
              ),
            ),
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const SettingScreen();
                  }));
                },
                icon: Icon(
                  MdiIcons.cog,
                  color: Theme.of(context).colorScheme.onBackground,
                ))
          ]),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchData(ref);
        },
        child: Padding(
            padding: const EdgeInsets.only(
              left: padding,
              right: padding,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(
                  //   height: 40,
                  // ),
                  header(context, ref),
                  const SizedBox(
                    height: 40,
                  ),
                  balanceCard(context, ref, transactions, isVisibile),
                  const SizedBox(
                    height: 20,
                  ),
                  filterChips(
                    context,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  pastTransactions(context, transactions, filter, ref),
                ],
              )),
            )),
      ),
      floatingActionButton: isVisibile.value
          ? FloatingActionButton.large(
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AddTransactionScreen();
                }));
              },
              child: Icon(
                MdiIcons.plus,
                size: 40,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            )
          : null,
    );
  }

  Widget header(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ref.watch(userProvider.notifier).captalizeUsername(),
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    )),
            Text(
              "Welcome back!",
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.5),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget balanceCard(
    BuildContext context,
    WidgetRef ref,
    List<Transaction> transactions,
    ValueNotifier<bool> isVisible,
  ) {
    return SizedBox(
      height: 200,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: (MediaQuery.of(context).size.width - 20) * .6,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(.8),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Balance",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    FittedBox(
                      child: Text(
                        "${ref.watch(monetaryUnitProvider.notifier).get()}${ref.watch(userProvider.notifier).getTotalBalance().toStringAsFixed(2)}",
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Total Expenses",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    FittedBox(
                      child: Text(
                        "${ref.watch(monetaryUnitProvider.notifier).get()}${ref.watch(transactionProvider.notifier).totalExpenses().toStringAsFixed(2)}",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                    ),
                  ]),
            ),
            const Spacer(),
            VisibilityDetector(
              key: const Key("add_transaction_button"),
              onVisibilityChanged: (visibilityInfo) {
                double visiblePercentage = visibilityInfo.visibleFraction * 100;
                if (visiblePercentage > 60) {
                  isVisible.value = false;
                } else {
                  isVisible.value = true;
                }
              },
              child: Material(
                color: Theme.of(context)
                    .colorScheme
                    .tertiaryContainer
                    .withOpacity(.8),
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddTransactionScreen()));
                  },
                  borderRadius: BorderRadius.circular(30),
                  splashColor: Theme.of(context).colorScheme.tertiaryContainer,
                  highlightColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    width: (MediaQuery.of(context).size.width - 20) * .35,
                    height: double.infinity,
                    child: Icon(MdiIcons.plus,
                        color: Theme.of(context).colorScheme.onBackground,
                        size: 50),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterChips(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ...TransactionCatergory.values
              .sublist(0, 5)
              .map((e) => Ink(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddTransactionScreen(
                                      userSelectedCategory: e,
                                    )));
                      },
                      borderRadius: BorderRadius.circular(10),
                      splashColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          getTransactionCatergoryIcon(e),
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                      ),
                    ),
                  ))
              .toList()
        ],
      ),
    );
  }

  Widget pastTransactions(
    BuildContext context,
    List<Transaction> transactions,
    ValueNotifier<TransactionFilter> filter,
    WidgetRef ref,
  ) {
    void setFilter() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(10),
              height: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text("Transactions of Month",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                            )),
                    onTap: () async {
                      filter.value = TransactionFilter.byMonth;
                      final SharedPreferences prefs = await _prefs;
                      prefs.setString("filter", "month");
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      "Transactions of Week",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    onTap: () async {
                      filter.value = TransactionFilter.byWeek;
                      final SharedPreferences prefs = await _prefs;
                      prefs.setString("filter", "week");
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            );
          });
    }

    double getTotalExpenses() {
      double total = 0;
      for (var transaction in transactions) {
        if (transaction.type == TransactionType.expense) {
          total -= transaction.amount;
        } else {
          total += transaction.amount;
        }
      }

      return total;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  setFilter();
                },
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Text(
                        filter.value == TransactionFilter.byMonth
                            ? "All Transactions of Month"
                            : "All Transactions of Week",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        MdiIcons.unfoldMoreHorizontal,
                        color: Theme.of(context).colorScheme.onBackground,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                "${ref.watch(monetaryUnitProvider.notifier).get()}${getTotalExpenses().abs().toStringAsFixed(2)}",
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: getTotalExpenses() >= 0
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        ...transactions.map((e) => TransactionCard(transaction: e)).toList(),
        transactions.isNotEmpty
            ? Container(
                margin: const EdgeInsets.only(top: 20),
                child: FilledButton.tonal(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ViewAllTransactionScreen(
                          title: "All Transactions",
                          transactions: ref
                              .read(transactionProvider.notifier)
                              .getSorted(),
                        );
                      }));
                    },
                    child: Text(
                      "View All",
                      softWrap: false,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    )))
            : Text(
                "No Transactions",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(),
              ),
        const SizedBox(
          height: 80,
        )
      ],
    );
  }
}
