// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './node_address_type.dart';

/// An object that represents the address of a node on the Lightning Network.
class NodeAddress {
  /// The string representation of the address.
  final String address;

  /// The type, or protocol, of this address.
  final NodeAddressType type;

  NodeAddress(
    this.address,
    this.type,
  );

  static NodeAddress fromJson(Map<String, dynamic> json) {
    return NodeAddress(
      json['node_address_address'],
      NodeAddressType.values.asNameMap()[json['node_address_type']] ??
          NodeAddressType.FUTURE_VALUE,
    );
  }

  static const fragment = r'''
fragment NodeAddressFragment on NodeAddress {
    __typename
    node_address_address: address
    node_address_type: type
}''';
}
