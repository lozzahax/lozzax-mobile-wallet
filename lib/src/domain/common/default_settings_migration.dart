import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lozzax_wallet/src/node/node.dart';
import 'package:lozzax_wallet/src/domain/common/balance_display_mode.dart';
import 'package:lozzax_wallet/src/domain/common/fiat_currency.dart';
import 'package:lozzax_wallet/src/node/node_list.dart';
import 'package:lozzax_wallet/src/wallet/lozzax/transaction/transaction_priority.dart';

Future defaultSettingsMigration(
    {@required int version,
    @required SharedPreferences sharedPreferences,
    @required Box<Node> nodes}) async {
  final currentVersion =
      sharedPreferences.getInt('current_default_settings_migration_version') ??
          0;

  if (currentVersion >= version) {
    return;
  }

  final migrationVersionsLength = version - currentVersion;
  final migrationVersions = List<int>.generate(
      migrationVersionsLength, (i) => currentVersion + (i + 1));

  await Future.forEach(migrationVersions, (int version) async {
    try {
      switch (version) {
        case 1:
          await sharedPreferences.setString(
              'current_fiat_currency', FiatCurrency.usd.toString());
          await sharedPreferences.setInt(
              'current_fee_priority', LozzaxTransactionPriority.standard.raw);
          await sharedPreferences.setInt('current_balance_display_mode',
              BalanceDisplayMode.availableBalance.raw);
          await sharedPreferences.setBool('save_recipient_address', true);
          await resetToDefault(nodes);
          await changeCurrentNodeToDefault(
              sharedPreferences: sharedPreferences, nodes: nodes);

          break;
        case 2:
          await replaceNodesMigration(nodes: nodes);
          await replaceDefaultNode(
              sharedPreferences: sharedPreferences, nodes: nodes);

          break;
        default:
          break;
      }

      await sharedPreferences.setInt(
          'current_default_settings_migration_version', version);
    } catch (e) {
      print('Migration error: ${e.toString()}');
    }
  });

  await sharedPreferences.setInt(
      'current_default_settings_migration_version', version);
}

Future<void> replaceNodesMigration({@required Box<Node> nodes}) async {
  final replaceNodes = <String, Node>{
    'public.lozzax.xyz:22123':
        Node(uri: 'public.lozzax.xyz:22123'),
    'nodes.lozzax.xyz:22123':
        Node(uri: 'nodes.lozzax.xyz:22123'),
    'node.lozzax.xyz:18081': Node(uri: 'node.lozzax.xyz:18081')
  };

  nodes.values.forEach((Node node) async {
    final nodeToReplace = replaceNodes[node.uri];

    if (nodeToReplace != null) {
      node.uri = nodeToReplace.uri;
      node.login = nodeToReplace.login;
      node.password = nodeToReplace.password;
      await node.save();
    }
  });
}

Future<void> changeCurrentNodeToDefault(
    {@required SharedPreferences sharedPreferences,
    @required Box<Node> nodes}) async {
  final timeZone = DateTime.now().timeZoneOffset.inHours;
  var nodeUri = '';

  if (timeZone >= 1) { // Eurasia
    nodeUri = 'public.lozzax.xyz:22123';
  } else if (timeZone <= -4) { // America
    nodeUri = 'freyr.lozzax.xyz:22123';
  }

  final node = nodes.values.firstWhere((Node node) => node.uri == nodeUri) ??
      nodes.values.first;
  final nodeId = node != null ? node.key as int : 0; // 0 - England

  await sharedPreferences.setInt('current_node_id', nodeId);
}

Future<void> replaceDefaultNode(
    {@required SharedPreferences sharedPreferences,
    @required Box<Node> nodes}) async {
  const nodesForReplace = <String>[
    'public.lozzax.xyz:22123',
    'nodes.lozzax.xyz:22123',
    'node.lozzax.xyz:18081'
  ];
  final currentNodeId = sharedPreferences.getInt('current_node_id');
  final currentNode =
      nodes.values.firstWhere((Node node) => node.key == currentNodeId);
  final needToReplace =
      currentNode == null ? true : nodesForReplace.contains(currentNode.uri);

  if (!needToReplace) {
    return;
  }

  await changeCurrentNodeToDefault(
      sharedPreferences: sharedPreferences, nodes: nodes);
}
