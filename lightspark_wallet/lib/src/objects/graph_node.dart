
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './node.dart';
import './entity.dart';
import './node_address_type.dart';
import "../lightspark_wallet_client.dart";
import './bitcoin_network.dart';
import './node_to_addresses_connection.dart';
import '../requester/query.dart';

/// This object represents a node that exists on the Lightning Network, including nodes not managed by Lightspark. You can retrieve this object to get publicly available information about any node on the Lightning Network.
class GraphNode implements Node, Entity {

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
@override
final BitcoinNetwork bitcoinNetwork;

    /// The name of this node in the network. It will be the most human-readable option possible, depending on the data
/// available for this node.
@override
final String displayName;

    /// The typename of the object
@override
final String typename;

    /// A name that identifies the node. It has no importance in terms of operating the node, it is just a way to identify and
/// search for commercial services or popular nodes. This alias can be changed at any time by the node operator.
@override
final String? alias;

    /// A hexadecimal string that describes a color. For example "#000000" is black, "#FFFFFF" is white. It has no importance
/// in terms of operating the node, it is just a way to visually differentiate nodes. That color can be changed at any time
/// by the node operator.
@override
final String? color;

    /// A summary metric used to capture how well positioned a node is to send, receive, or route transactions efficiently.
/// Maximizing a node's conductivity helps a node’s transactions to be capital efficient. The value is an integer ranging
/// between 0 and 10 (bounds included).
    /// @deprecated Not supported.
@override
final int? conductivity;

    /// The public key of this node. It acts as a unique identifier of this node in the Lightning Network.
@override
final String? publicKey;


    GraphNode(
        this.id, this.createdAt, this.updatedAt, this.bitcoinNetwork, this.displayName, this.typename, this.alias, this.color, this.conductivity, this.publicKey, 
    );

@override

     Future<NodeToAddressesConnection> getAddresses(LightsparkWalletClient client, { int? first, List<NodeAddressType>? types, }) async {
        return (await client.executeRawQuery(Query(
            r''' 
query FetchNodeToAddressesConnection($entity_id: ID!, $first: Int, $types: [NodeAddressType!]) {
    entity(id: $entity_id) {
        ... on GraphNode {
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
            variables: {"entity_id": id, "first": first, "types": types},
        )));
    }


    static Query<GraphNode> getGraphNodeQuery(String id) {
        return Query(
            '''
query GetGraphNode(\$id: ID!) {
    entity(id: \$id) {
        ... on GraphNode {
            ...GraphNodeFragment
        }
    }
}

$fragment  
''',
            (json) => GraphNode.fromJson(json["entity"]),
            variables: {'id': id},
        );
    }

static GraphNode fromJson(Map<String, dynamic> json) {
    return GraphNode(
        json["graph_node_id"],
        json["graph_node_created_at"],
        json["graph_node_updated_at"],
        BitcoinNetwork.values.asNameMap()[json['graph_node_bitcoin_network']] ?? BitcoinNetwork.FUTURE_VALUE,
        json["graph_node_display_name"],
"GraphNode",        json["graph_node_alias"],
        json["graph_node_color"],
        json["graph_node_conductivity"],
        json["graph_node_public_key"],

        );

}

    static const fragment = r'''
fragment GraphNodeFragment on GraphNode {
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
}''';

}
