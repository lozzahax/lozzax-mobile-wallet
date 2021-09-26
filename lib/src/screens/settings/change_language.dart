import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lozzax_wallet/generated/l10n.dart';
import 'package:lozzax_wallet/src/domain/common/language.dart';
import 'package:lozzax_wallet/src/screens/base_page.dart';
import 'package:lozzax_wallet/src/stores/settings/settings_store.dart';
import 'package:lozzax_wallet/src/widgets/lozzax_dialog.dart';
import 'package:provider/provider.dart';

class ChangeLanguage extends BasePage {
  @override
  String get title => S.current.settings_change_language;

  @override
  Widget body(BuildContext context) {
    final settingsStore = Provider.of<SettingsStore>(context);
    final currentLanguage = Provider.of<Language>(context);

    final currentColor = Theme.of(context).selectedRowColor;
    final notCurrentColor =
        Theme.of(context).accentTextTheme.subtitle1.backgroundColor;

    return Container(
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: ListView.builder(
          itemCount: languages.values.length,
          itemBuilder: (BuildContext context, int index) {
            final isCurrent = settingsStore.languageCode == null
                ? false
                : languages.keys.elementAt(index) == settingsStore.languageCode;

            return Container(
              margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
              color: isCurrent ? currentColor : notCurrentColor,
              child: ListTile(
                title: Text(
                  languages.values.elementAt(index),
                  style: TextStyle(
                      fontSize: 16.0,
                      color:
                          Theme.of(context).primaryTextTheme.headline6.color),
                ),
                onTap: () async {
                  if (!isCurrent) {
                    await showSimpleLozzaxDialog(
                      context,
                      S.of(context).change_language,
                      S.of(context).change_language_to(
                          languages.values.elementAt(index)),
                      onPressed: (context) {
                        settingsStore.saveLanguageCode(
                            languageCode: languages.keys.elementAt(index));
                        currentLanguage.setCurrentLanguage(
                            languages.keys.elementAt(index));
                        Navigator.of(context).pop();
                      },
                    );
                  }
                },
              ),
            );
          },
        ));
  }
}
