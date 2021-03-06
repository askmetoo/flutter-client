import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_actions.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/auth/auth_actions.dart';
import 'package:invoiceninja_flutter/redux/client/client_actions.dart';
import 'package:invoiceninja_flutter/redux/dashboard/dashboard_actions.dart';
import 'package:invoiceninja_flutter/redux/ui/pref_state.dart';
import 'package:invoiceninja_flutter/ui/app/app_builder.dart';
import 'package:invoiceninja_flutter/ui/app/dialogs/loading_dialog.dart';
import 'package:invoiceninja_flutter/ui/settings/device_settings_list.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';
import 'package:invoiceninja_flutter/utils/dialogs.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:local_auth/local_auth.dart';
import 'package:redux/redux.dart';

class DeviceSettingsScreen extends StatelessWidget {
  const DeviceSettingsScreen({Key key}) : super(key: key);
  static const String route = '/$kSettings/$kSettingsDeviceSettings';

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, DeviceSettingsVM>(
      converter: DeviceSettingsVM.fromStore,
      builder: (context, viewModel) {
        return DeviceSettings(viewModel: viewModel);
      },
    );
  }
}

class DeviceSettingsVM {
  DeviceSettingsVM({
    @required this.state,
    @required this.onLogoutTap,
    @required this.onRefreshTap,
    @required this.onDarkModeChanged,
    @required this.onLayoutChanged,
    @required this.onAutoStartTasksChanged,
    @required this.onRequireAuthenticationChanged,
    @required this.onLongPressSelectionIsDefault,
    @required this.authenticationSupported,
    @required this.onMenuModeChanged,
    @required this.onHistoryModeChanged,
    @required this.onFullHeightFilterChanged,
    @required this.onFullWidthEditorChanged,
  });

  static DeviceSettingsVM fromStore(Store<AppState> store) {
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    void _refreshData(BuildContext context) async {
      final completer = snackBarCompleter<Null>(
          context, AppLocalization.of(context).refreshComplete,
          shouldPop: true);

      store.dispatch(RefreshData(
        completer: completer,
      ));

      await showDialog<AlertDialog>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => SimpleDialog(
                children: <Widget>[LoadingDialog()],
              ));

      AppBuilder.of(context).rebuild();
      store.dispatch(LoadClients());
    }

    return DeviceSettingsVM(
      state: store.state,
      onLogoutTap: (BuildContext context) => confirmCallback(
          context: context,
          callback: () async {
            if (store.state.user.oauthProvider ==
                UserEntity.OAUTH_PROVIDER_GOOGLE) {
              await _googleSignIn.signOut();
            }
            store.dispatch(UserLogout(context));
          }),
      onRefreshTap: (BuildContext context) => _refreshData(context),
      onDarkModeChanged: (BuildContext context, bool value) async {
        store.dispatch(UserPreferencesChanged(enableDarkMode: value));
        AppBuilder.of(context).rebuild();
      },
      onAutoStartTasksChanged: (BuildContext context, bool value) async {
        store.dispatch(UserPreferencesChanged(autoStartTasks: value));
      },
      onLongPressSelectionIsDefault: (BuildContext context, bool value) async {
        store.dispatch(
            UserPreferencesChanged(longPressSelectionIsDefault: value));
      },
      onMenuModeChanged: (context, value) async {
        store.dispatch(UserPreferencesChanged(menuMode: value));
      },
      onHistoryModeChanged: (context, value) async {
        store.dispatch(UserPreferencesChanged(historyMode: value));
      },
      onFullHeightFilterChanged: (context, value) async {
        store.dispatch(UserPreferencesChanged(fullHeightFilter: value));
      },
      onFullWidthEditorChanged: (context, value) async {
        store.dispatch(UserPreferencesChanged(fullWidthEditor: value));
      },
      onLayoutChanged: (BuildContext context, AppLayout value) async {
        if (store.state.prefState.appLayout == value) {
          return;
        }
        store.dispatch(UserPreferencesChanged(layout: value));
        AppBuilder.of(context).rebuild();
        WidgetsBinding.instance.addPostFrameCallback((duration) {
          if (value == AppLayout.mobile) {
            store.dispatch(ViewDashboard(navigator: Navigator.of(context)));
          } else {
            store.dispatch(ViewMainScreen(
                navigator: Navigator.of(context), addDelay: true));
          }
        });
      },
      onRequireAuthenticationChanged: (BuildContext context, bool value) async {
        bool authenticated = false;
        try {
          authenticated = await LocalAuthentication()
              .authenticateWithBiometrics(
                  localizedReason:
                      AppLocalization.of(context).authenticateToChangeSetting,
                  useErrorDialogs: true,
                  stickyAuth: false);
        } catch (e) {
          print(e);
        }
        if (authenticated) {
          store.dispatch(UserPreferencesChanged(requireAuthentication: value));
        } else {}
      },
      //authenticationSupported: LocalAuthentication().canCheckBiometrics,
      // TODO remove this once issue is resolved:
      // https://github.com/flutter/flutter/issues/24339
      authenticationSupported: Future<bool>(() async {
        bool enable = false;
        try {
          enable = await LocalAuthentication().canCheckBiometrics;
        } catch (e) {
          // do nothing
        }
        return enable;
      }),
    );
  }

  final AppState state;
  final Function(BuildContext) onLogoutTap;
  final Function(BuildContext) onRefreshTap;
  final Function(BuildContext, bool) onFullHeightFilterChanged;
  final Function(BuildContext, bool) onFullWidthEditorChanged;
  final Function(BuildContext, bool) onDarkModeChanged;
  final Function(BuildContext, AppLayout) onLayoutChanged;
  final Function(BuildContext, AppSidebarMode) onMenuModeChanged;
  final Function(BuildContext, AppSidebarMode) onHistoryModeChanged;
  final Function(BuildContext, bool) onAutoStartTasksChanged;
  final Function(BuildContext, bool) onLongPressSelectionIsDefault;
  final Function(BuildContext, bool) onRequireAuthenticationChanged;
  final Future<bool> authenticationSupported;
}
