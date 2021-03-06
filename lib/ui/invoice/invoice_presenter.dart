import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/ui/app/presenters/entity_presenter.dart';
import 'package:invoiceninja_flutter/utils/formatting.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class InvoicePresenter extends EntityPresenter {
  static List<String> getDefaultTableFields(UserCompanyEntity userCompany) {
    return [
      InvoiceFields.invoiceNumber,
      InvoiceFields.client,
      InvoiceFields.amount,
      InvoiceFields.balance,
      InvoiceFields.status,
      InvoiceFields.invoiceDate,
      InvoiceFields.dueDate,
    ];
  }

  static List<String> getAllTableFields(UserCompanyEntity userCompany) {
    return [
      ...getDefaultTableFields(userCompany),
      ...EntityPresenter.getBaseFields(),
      InvoiceFields.discount,
      InvoiceFields.poNumber,
      InvoiceFields.publicNotes,
      InvoiceFields.privateNotes,
      InvoiceFields.documents,
      InvoiceFields.customValue1,
      InvoiceFields.customValue2,
      InvoiceFields.customValue3,
      InvoiceFields.customValue4,
    ];
  }

  @override
  Widget getField({String field, BuildContext context}) {
    final localization = AppLocalization.of(context);
    final state = StoreProvider.of<AppState>(context).state;
    final invoice = entity as InvoiceEntity;

    switch (field) {
      case InvoiceFields.status:
        return Text(
          localization.lookup(kInvoiceStatuses[invoice.calculatedStatusId]),
        );
      case InvoiceFields.invoiceNumber:
        return Text((invoice.number ?? '').isEmpty
            ? localization.pending
            : invoice.number);
      case InvoiceFields.client:
        return Text((state.clientState.map[invoice.clientId] ??
                ClientEntity(id: invoice.clientId))
            .listDisplayName);
      case InvoiceFields.invoiceDate:
        return Text(formatDate(invoice.date, context));
      case InvoiceFields.amount:
        return Align(
          alignment: Alignment.centerRight,
          child: Text(formatNumber(invoice.amount, context,
              clientId: invoice.clientId)),
        );
      case InvoiceFields.balance:
        return Align(
          alignment: Alignment.centerRight,
          child: Text(formatNumber(invoice.balance, context,
              clientId: invoice.clientId)),
        );
      case InvoiceFields.dueDate:
        return Text(formatDate(invoice.dueDate, context));
      case InvoiceFields.customValue1:
        return Text(invoice.customValue1);
      case InvoiceFields.customValue2:
        return Text(invoice.customValue2);
      case InvoiceFields.customValue3:
        return Text(invoice.customValue3);
      case InvoiceFields.customValue4:
        return Text(invoice.customValue4);
      case InvoiceFields.publicNotes:
        return Text(invoice.publicNotes);
      case InvoiceFields.privateNotes:
        return Text(invoice.privateNotes);
      case InvoiceFields.discount:
        return Text(invoice.isAmountDiscount
            ? formatNumber(invoice.discount, context,
                formatNumberType: FormatNumberType.money,
                clientId: invoice.clientId)
            : formatNumber(invoice.discount, context,
                formatNumberType: FormatNumberType.percent));
      case InvoiceFields.poNumber:
        return Text(invoice.poNumber);
      case InvoiceFields.documents:
        return Text('${invoice.documents.length}');
    }

    return super.getField(field: field, context: context);
  }
}
