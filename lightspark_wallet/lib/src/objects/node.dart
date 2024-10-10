// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import '../lightspark_exception.dart';
import '../lightspark_wallet_client.dart';
import '../requester/query.dart';
import './bitcoin_network.dart';
import './entity.dart';
import './graph_node.dart';
import './node_address_type.dart';
import './node_to_addresses_connection.dart';

/// This object is an interface representing a Lightning Node on the Lightning Network, and could either be a Lightspark node or a node managed by a third party.
class Node implements Entity {
  /// The unique identifier of this entity across all Lightspark systems. Should be treated as an opaque string.
  @override
  final String id;

  /// The date and time when the entity was first created.
  @override
  final String createdAt;

  /// The date and time when the entity was last updated.
  @override
  final String updatedAt;

  /// The Bitcoin Network this node is deployed in.
  final BitcoinNetwork bitcoinNetwork;

  /// The name of this node in the network. It will be the most human-readable option possible, depending on the data
  /// available for this node.
  final String displayName;

  /// The typename of the object
  @override
  final String typename;

  /// A name that identifies the node. It has no importance in terms of operating the node, it is just a way to identify and
  /// search for commercial services or popular nodes. This alias can be changed at any time by the node operator.
  final String? alias;

  /// A hexadecimal string that describes a color. For example "#000000" is black, "#FFFFFF" is white. It has no importance
  /// in terms of operating the node, it is just a way to visually differentiate nodes. That color can be changed at any time
  /// by the node operator.
  final String? color;

  /// A summary metric used to capture how well positioned a node is to send, receive, or route transactions efficiently.
  /// Maximizing a node's conductivity helps a node’s transactions to be capital efficient. The value is an integer ranging
  /// between 0 and 10 (bounds included).
  /// @deprecated Not supported.
  final int? conductivity;

  /// The public key of this node. It acts as a unique identifier of this node in the Lightning Network.
  final String? publicKey;

  Node(
    this.id,
    this.createdAt,
    this.updatedAt,
    this.bitcoinNetwork,
    this.displayName,
    this.typename,
    this.alias,
    this.color,
    this.conductivity,
    this.publicKey,
  );

  Future<NodeToAddressesConnection> getAddresses(
    LightsparkWalletClient client, {
    int? first,
    List<NodeAddressType>? types,
  }) async {
    return (await client.executeRawQuery(Query(
      r''' 
query FetchNodeToAddressesConnection($entity_id: ID!, $first: Int, $types: [NodeAddressType!]) {
    entity(id: $entity_id) {
        ... on Node {
            addresses(, first: $first, types: $types) {
                __typename
                node_to_addresses_connection_count: count
                node_to_addresses_connection_entities: entities {
                    __typename
                    node_address_address: address
                    node_address_type: type
                }
            }
        }
    }
}
''',
      (json) {
        final connection = json['entity']['addresses'];
        return NodeToAddressesConnection.fromJson(connection);
      },
      variables: {'entity_id': id, 'first': first, 'types': types},
    )));
  }

  static Query<Node> getNodeQuery(String id) {
    return Query(
      '''
query GetNode(\$id: ID!) {
    entity(id: \$id) {
        ... on Node {
            ...NodeFragment
        }
    }
}

$fragment  
''',
      (json) => Node.fromJson(json['entity']),
      variables: {'id': id},
    );
  }

  static Node fromJson(Map<String, dynamic> json) {
    if (json['__typename'] == 'GraphNode') {
      return GraphNode(
        json['graph_node_id'],
        json['graph_node_created_at'],
        json['graph_node_updated_at'],
        BitcoinNetwork.values.asNameMap()[json['graph_node_bitcoin_network']] ??
            BitcoinNetwork.FUTURE_VALUE,
        json['graph_node_display_name'],
        'GraphNode',
        json['graph_node_alias'],
        json['graph_node_color'],
        json['graph_node_conductivity'],
        json['graph_node_public_key'],
      );
    }
    throw LightsparkException('DeserializationError',
        'Couldn\'t find a concrete type for interface Node corresponding to the typename=${json['__typename']}');
  }

  static const fragment = r'''
fragment NodeFragment on Node {
    __typename
    ... on GraphNode {
        __typename
        graph_node_id: id
        graph_node_created_at: created_at
        graph_node_updated_at: updated_at
        graph_node_alias: alias
        graph_node_bitcoin_network: bitcoin_network
        graph_node_color: color
        graph_node_conductivity: conductivity
        graph_node_display_name: display_name
        graph_node_public_key: public_key
    }
}''';
}
