import 'package:built_collection/built_collection.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/company/company_state.dart';
import 'package:memoize/memoize.dart';

var memoizedDropdownExpenseCategoriesList = memo2(
    (BuiltMap<String, ExpenseCategoryEntity> categoryMap,
            BuiltList<ExpenseCategoryEntity> categoryList) =>
        dropdownExpenseCategoriesSelector(categoryMap, categoryList));

List<String> dropdownExpenseCategoriesSelector(
    BuiltMap<String, ExpenseCategoryEntity> categoryMap,
    BuiltList<ExpenseCategoryEntity> categoryList) {
  final list = categoryList
      //.where((category) => category.isActive)
      .map((category) => category.id)
      .toList();

  list.sort((categoryAId, categoryBId) {
    final categoryA = categoryMap[categoryAId];
    final categoryB = categoryMap[categoryBId];
    return categoryA.compareTo(categoryB, ExpenseCategoryFields.name, true);
  });

  return list;
}

var memoizedHasMultipleCurrencies = memo2(
    (CompanyEntity company, BuiltMap<String, ClientEntity> clientMap) =>
        hasMultipleCurrencies(company, clientMap));

bool hasMultipleCurrencies(
        CompanyEntity company, BuiltMap<String, ClientEntity> clientMap) =>
    memoizedGetCurrencyIds(company, clientMap).length > 1;

var memoizedGetCurrencyIds = memo2(
    (CompanyEntity company, BuiltMap<String, ClientEntity> clientMap) =>
        getCurrencyIds(company, clientMap));

List<String> getCurrencyIds(
    CompanyEntity company, BuiltMap<String, ClientEntity> clientMap) {
  final currencyIds = <String>[];
  currencyIds.add(company.currencyId);
  clientMap.forEach((clientId, client) {
    if (client.hasCurrency &&
        !client.isDeleted &&
        !currencyIds.contains(client.currencyId)) {
      currencyIds.add(client.currencyId);
    }
  });
  return currencyIds;
}

var memoizedFilteredSelector = memo2(
    (String filter, UserCompanyState state) => filteredSelector(filter, state));

List<BaseEntity> filteredSelector(String filter, UserCompanyState state) {
  final List<BaseEntity> list = []
    ..addAll(state.productState.list
        .map((productId) => state.productState.map[productId])
        .where((product) {
      return product.matchesFilter(filter);
    }).toList())
    ..addAll(state.clientState.list
        .map((clientId) => state.clientState.map[clientId])
        .where((client) {
      return client.matchesFilter(filter);
    }).toList())
    ..addAll(state.quoteState.list
        .map((quoteId) => state.quoteState.map[quoteId])
        .where((quote) {
      return quote.matchesFilter(filter);
    }).toList())
    ..addAll(state.paymentState.list
        .map((paymentId) => state.paymentState.map[paymentId])
        .where((payment) {
      return payment.matchesFilter(filter);
    }).toList())
    ..addAll(state.projectState.list
        .map((projectId) => state.projectState.map[projectId])
        .where((project) {
      return project.matchesFilter(filter);
    }).toList())
    ..addAll(state.taskState.list
        .map((taskId) => state.taskState.map[taskId])
        .where((task) {
      return task.matchesFilter(filter);
    }).toList())
    ..addAll(state.invoiceState.list
        .map((invoiceId) => state.invoiceState.map[invoiceId])
        .where((invoice) {
      return invoice.matchesFilter(filter);
    }).toList());

  list.sort((BaseEntity entityA, BaseEntity entityB) {
    return entityA.listDisplayName.compareTo(entityB.listDisplayName);
  });

  return list;
}

List<CompanyEntity> companiesSelector(AppState state) {
  final List<CompanyEntity> list = [];

  for (var companyState in state.userCompanyStates) {
    if (companyState.company != null) {
      list.add(companyState.company);
    }
  }

  return list
      .where((CompanyEntity company) => company.displayName.isNotEmpty)
      .toList();
}

String localeSelector(AppState state) {
  final locale = state.staticState
          ?.languageMap[state.company?.settings?.languageId]?.locale ??
      'en';

  // https://github.com/flutter/flutter/issues/32090
  if (locale == 'mk_MK' || locale == 'sq') {
    return 'en';
  } else {
    return locale;
  }
}
