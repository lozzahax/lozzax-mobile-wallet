import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lozzax_wallet/generated/l10n.dart';
import 'package:lozzax_wallet/src/screens/base_page.dart';
import 'package:lozzax_wallet/src/stores/account_list/account_list_store.dart';
import 'package:lozzax_wallet/src/wallet/lozzax/account.dart';
import 'package:lozzax_wallet/src/widgets/lozzax_text_field.dart';
import 'package:lozzax_wallet/src/widgets/primary_button.dart';
import 'package:lozzax_wallet/src/widgets/scollable_with_bottom_section.dart';
import 'package:provider/provider.dart';

class AccountPage extends BasePage {
  AccountPage({this.account});

  final Account account;

  @override
  String get title => 'Account';

  @override
  Widget body(BuildContext context) => AccountForm(account);
}

class AccountForm extends StatefulWidget {
  AccountForm(this.account);

  final Account account;

  @override
  AccountFormState createState() => AccountFormState();
}

class AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  @override
  void initState() {
    if (widget.account != null) _textController.text = widget.account.label;
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountListStore = Provider.of<AccountListStore>(context);

    return ScrollableWithBottomSection(
      contentPadding: EdgeInsets.all(20),
      content: Form(
          key: _formKey,
          child: Container(
            child: Column(
              children: <Widget>[
                Center(
                  child: LozzaxTextField(
                    hintText: S.of(context).account,
                    controller: _textController,
                    validator: (value) {
                      accountListStore.validateAccountName(value);
                      return accountListStore.errorMessage;
                    },
                  ),
                ),
              ],
            ),
          )),
      bottomSection: Observer(
          builder: (_) => LoadingPrimaryButton(
                onPressed: () async {
                  if (!_formKey.currentState.validate()) {
                    return;
                  }

                  if (widget.account != null) {
                    await accountListStore.renameAccount(
                        index: widget.account.id, label: _textController.text);
                  } else {
                    await accountListStore.addAccount(
                        label: _textController.text);
                  }
                  Navigator.of(context).pop(_textController.text);
                },
                text: widget.account != null ? 'Rename' : S.of(context).add,
                color:
                    Theme.of(context).primaryTextTheme.button.backgroundColor,
                borderColor:
                    Theme.of(context).primaryTextTheme.button.decorationColor,
                isLoading: accountListStore.isAccountCreating,
              )),
    );
  }
}
