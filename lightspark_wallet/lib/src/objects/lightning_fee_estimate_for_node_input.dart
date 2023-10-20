// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

class LightningFeeEstimateForNodeInput {
  /// The public key of the node that you want to pay.
  final String destinationNodePublicKey;

  /// The payment amount expressed in msats.
  final int amountMsats;

  LightningFeeEstimateForNodeInput(
    this.destinationNodePublicKey,
    this.amountMsats,
  );

  static LightningFeeEstimateForNodeInput fromJson(Map<String, dynamic> json) {
    return LightningFeeEstimateForNodeInput(
      json['lightning_fee_estimate_for_node_input_destination_node_public_key'],
      json['lightning_fee_estimate_for_node_input_amount_msats'],
    );
  }
}
