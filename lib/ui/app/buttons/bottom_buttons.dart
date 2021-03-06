import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/ui/app/app_border.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class BottomButtons extends StatelessWidget {
  const BottomButtons({
    @required this.entity,
    @required this.action1,
    @required this.action2,
    this.action1Enabled = true,
    this.action2Enabled = true,
  });

  final BaseEntity entity;
  final EntityAction action1;
  final EntityAction action2;
  final bool action1Enabled;
  final bool action2Enabled;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final store = StoreProvider.of<AppState>(context);
    final state = store.state;
    final textColor = state.prefState.enableDarkMode
        ? Theme.of(context).textTheme.bodyText1.color
        : Colors.blue;

    return SizedBox(
      height: kTopBottomBarHeight,
      child: AppBorder(
        isTop: true,
        child: Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: action1Enabled
                    ? () {
                        handleEntityAction(context, entity, action1);
                      }
                    : null,
                child: Center(
                  child: Text(
                    localization.lookup('$action1'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: textColor.withOpacity(action1Enabled ? 1 : .5)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AppBorder(
                isLeft: true,
                child: InkWell(
                  onTap: action2Enabled
                      ? () {
                          handleEntityAction(context, entity, action2);
                        }
                      : null,
                  child: Center(
                    child: Text(
                      localization.lookup('$action2'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color:
                              textColor.withOpacity(action2Enabled ? 1 : .6)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
