// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './node_address.dart';

/// A connection between a node and the addresses it has announced for itself on Lightning Network.
class NodeToAddressesConnection {
  /// The total count of objects in this connection, using the current filters. It is different from the number of objects
  /// returned in the current page (in the `entities` field).
  final int count;

  /// The addresses for the current page of this connection.
  final List<NodeAddress> entities;

  NodeToAddressesConnection(
    this.count,
    this.entities,
  );

  static NodeToAddressesConnection fromJson(Map<String, dynamic> json) {
    return NodeToAddressesConnection(
      json["node_to_addresses_connection_count"],
      json["node_to_addresses_connection_entities"]
          .map<NodeAddress>((e) => NodeAddress.fromJson(e))
          .toList(),
    );
  }

  static const fragment = r'''
fragment NodeToAddressesConnectionFragment on NodeToAddressesConnection {
    __typename
    node_to_addresses_connection_count: count
    node_to_addresses_connection_entities: entities {
        __typename
        node_address_address: address
        node_address_type: type
    }
}''';
}
