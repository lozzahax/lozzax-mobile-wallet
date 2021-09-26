import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lozzax_wallet/generated/l10n.dart';
import 'package:lozzax_wallet/palette.dart';
import 'package:lozzax_wallet/routes.dart';
import 'package:lozzax_wallet/src/domain/common/crypto_currency.dart';
import 'package:lozzax_wallet/src/screens/base_page.dart';
import 'package:lozzax_wallet/src/stores/address_book/address_book_store.dart';
import 'package:lozzax_wallet/src/widgets/lozzax_dialog.dart';
import 'package:provider/provider.dart';

class AddressBookPage extends BasePage {
  AddressBookPage({this.isEditable = true});

  final bool isEditable;

  @override
  String get title => S.current.address_book;

  @override
  Widget trailing(BuildContext context) {
    if (!isEditable) return null;

    final addressBookStore = Provider.of<AddressBookStore>(context);

    return Container(
        width: 28.0,
        height: 28.0,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Theme.of(context).selectedRowColor),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(Icons.add, color: LozzaxPalette.teal, size: 22.0),
            ButtonTheme(
              minWidth: 28.0,
              height: 28.0,
              child: FlatButton(
                  shape: CircleBorder(),
                  onPressed: () async {
                    await Navigator.of(context)
                        .pushNamed(Routes.addressBookAddContact);
                    await addressBookStore.updateContactList();
                  },
                  child: Offstage()),
            )
          ],
        ));
  }

  @override
  Widget body(BuildContext context) {
    final addressBookStore = Provider.of<AddressBookStore>(context);

    return Container(
        padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: Observer(
          builder: (_) => ListView.separated(
              separatorBuilder: (_, __) => Divider(
                    color: Theme.of(context).dividerTheme.color,
                    height: 1.0,
                  ),
              itemCount: addressBookStore.contactList == null
                  ? 0
                  : addressBookStore.contactList.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = addressBookStore.contactList[index];

                final content = ListTile(
                  onTap: () async {
                    if (!isEditable) {
                      Navigator.of(context).pop(contact);
                      return;
                    }

                    final isCopied = await showNameAndAddressDialog(
                        context, contact.name, contact.address);

                    if (isCopied) {
                      await Clipboard.setData(
                          ClipboardData(text: contact.address));
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Copied to Clipboard'),
                          backgroundColor: Colors.green,
                          duration: Duration(milliseconds: 1500),
                        ),
                      );
                    }
                  },
                  leading: Container(
                    height: 25.0,
                    width: 48.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _getCurrencyBackgroundColor(contact.type),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      contact.type.toString(),
                      style: TextStyle(
                        fontSize: 11.0,
                        color: _getCurrencyTextColor(contact.type),
                      ),
                    ),
                  ),
                  title: Text(
                    contact.name,
                    style: TextStyle(
                        fontSize: 16.0,
                        color:
                            Theme.of(context).primaryTextTheme.headline6.color),
                  ),
                );

                return !isEditable
                    ? content
                    : Slidable(
                        key: Key('${contact.key}'),
                        actionPane: SlidableDrawerActionPane(),
                        child: content,
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: 'Edit',
                            color: Colors.blue,
                            icon: Icons.edit,
                            onTap: () async {
                              await Navigator.of(context).pushNamed(
                                  Routes.addressBookAddContact,
                                  arguments: contact);
                              await addressBookStore.updateContactList();
                            },
                          ),
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: CupertinoIcons.delete,
                            onTap: () async {
                              await showAlertDialog(context)
                                  .then((isDelete) async {
                                if (isDelete != null && isDelete) {
                                  await addressBookStore.delete(
                                      contact: contact);
                                  await addressBookStore.updateContactList();
                                }
                              });
                            },
                          ),
                        ],
                        dismissal: SlidableDismissal(
                          child: SlidableDrawerDismissal(),
                          onDismissed: (actionType) async {
                            await addressBookStore.delete(contact: contact);
                            await addressBookStore.updateContactList();
                          },
                          onWillDismiss: (actionType) async {
                            return await showAlertDialog(context);
                          },
                        ),
                      );
              }),
        ));
  }

  Color _getCurrencyBackgroundColor(CryptoCurrency currency) {
    Color color;
    switch (currency) {
      case CryptoCurrency.lozzax:
        color = LozzaxPalette.tealWithOpacity;
        break;
      case CryptoCurrency.ada:
        color = Colors.blue[200];
        break;
      case CryptoCurrency.bch:
        color = Colors.orangeAccent;
        break;
      case CryptoCurrency.bnb:
        color = Colors.blue;
        break;
      case CryptoCurrency.btc:
        color = Colors.orange;
        break;
      case CryptoCurrency.dash:
        color = Colors.blue;
        break;
      case CryptoCurrency.eos:
        color = Colors.orangeAccent;
        break;
      case CryptoCurrency.eth:
        color = Colors.black;
        break;
      case CryptoCurrency.ltc:
        color = Colors.blue[200];
        break;
      case CryptoCurrency.nano:
        color = Colors.orange;
        break;
      case CryptoCurrency.trx:
        color = Colors.black;
        break;
      case CryptoCurrency.usdt:
        color = Colors.blue[200];
        break;
      case CryptoCurrency.xlm:
        color = color = Colors.blue;
        break;
      case CryptoCurrency.xrp:
        color = Colors.orangeAccent;
        break;
      default:
        color = Colors.white;
    }
    return color;
  }

  Color _getCurrencyTextColor(CryptoCurrency currency) {
    Color color;
    switch (currency) {
      case CryptoCurrency.xmr:
        color = LozzaxPalette.teal;
        break;
      case CryptoCurrency.ltc:
      case CryptoCurrency.ada:
      case CryptoCurrency.usdt:
        color = Palette.lightBlue;
        break;
      default:
        color = Colors.white;
    }
    return color;
  }

  Future<bool> showAlertDialog(BuildContext context) async {
    var result = false;
    await showConfirmLozzaxDialog(context, 'Remove contact',
        'Are you sure that you want to remove selected contact?',
        onDismiss: (context) => Navigator.pop(context, false),
        onConfirm: (context) {
          result = true;
          Navigator.pop(context, true);
          return true;
        });
    return result;
  }

  Future<bool> showNameAndAddressDialog(
      BuildContext context, String name, String address) async {
    var result = false;
    await showSimpleLozzaxDialog(
      context,
      name,
      address,
      buttonText: 'Copy',
      onPressed: (context) {
        result = true;
        Navigator.of(context).pop(true);
      },
    );
    return result;
  }
}
