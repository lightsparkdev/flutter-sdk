
// Copyright ©, 2023-present, Lightspark Group, Inc. - All Rights Reserved

import './entity.dart';
import './withdrawal_request_to_withdrawals_connection.dart';
import "../lightspark_wallet_client.dart";
import './currency_amount.dart';
import './withdrawal_request_status.dart';
import '../requester/query.dart';

/// This object represents a request made for an L1 withdrawal from your Lightspark Node to any Bitcoin wallet. You can retrieve this object to receive detailed information about any withdrawal request made from your Lightspark account.
class WithdrawalRequest implements Entity {

    /// The unique identifier of this entity across all Lightspark systems. Should be treated as an opaque string.
@override
final String id;

    /// The date and time when the entity was first created.
@override
final String createdAt;

    /// The date and time when the entity was last updated.
@override
final String updatedAt;

    /// The requested amount of money to be withdrawn. If the requested amount is -1, it means to withdraw all.
final CurrencyAmount requestedAmount;

    /// The amount of money that should be withdrawn in this request.
    /// @deprecated Use `requested_amount` instead
final CurrencyAmount amount;

    /// The bitcoin address where the funds should be sent.
final String bitcoinAddress;

    /// The current status of this withdrawal request.
final WithdrawalRequestStatus status;

    /// The typename of the object
@override
final String typename;

    /// If the requested amount is `-1` (i.e. everything), this field may contain an estimate of the amount for the withdrawal.
final CurrencyAmount? estimatedAmount;

    /// The actual amount that is withdrawn to the bitcoin address. It will be set once the request is completed.
final CurrencyAmount? amountWithdrawn;

    /// The total fees the node paid for the withdrawal. It will be set once the request is completed.
final CurrencyAmount? totalFees;

    /// The time at which this request was completed.
final String? completedAt;

    /// The withdrawal transaction that has been generated by this request.
    /// @deprecated Use `withdrawals` instead.
final String? withdrawalId;


    WithdrawalRequest(
        this.id, this.createdAt, this.updatedAt, this.requestedAmount, this.amount, this.bitcoinAddress, this.status, this.typename, this.estimatedAmount, this.amountWithdrawn, this.totalFees, this.completedAt, this.withdrawalId, 
    );


     Future<WithdrawalRequestToWithdrawalsConnection> getWithdrawals(LightsparkWalletClient client, { int? first, }) async {
        return (await client.executeRawQuery(Query(
            r''' 
query FetchWithdrawalRequestToWithdrawalsConnection($entity_id: ID!, $first: Int) {
    entity(id: $entity_id) {
        ... on WithdrawalRequest {
            withdrawals(, first: $first) {
                __typename
                withdrawal_request_to_withdrawals_connection_count: count
                withdrawal_request_to_withdrawals_connection_entities: entities {
                    __typename
                    withdrawal_id: id
                    withdrawal_created_at: created_at
                    withdrawal_updated_at: updated_at
                    withdrawal_status: status
                    withdrawal_resolved_at: resolved_at
                    withdrawal_amount: amount {
                        __typename
                        currency_amount_original_value: original_value
                        currency_amount_original_unit: original_unit
                        currency_amount_preferred_currency_unit: preferred_currency_unit
                        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
                        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
                    }
                    withdrawal_transaction_hash: transaction_hash
                    withdrawal_fees: fees {
                        __typename
                        currency_amount_original_value: original_value
                        currency_amount_original_unit: original_unit
                        currency_amount_preferred_currency_unit: preferred_currency_unit
                        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
                        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
                    }
                    withdrawal_block_hash: block_hash
                    withdrawal_block_height: block_height
                    withdrawal_destination_addresses: destination_addresses
                    withdrawal_num_confirmations: num_confirmations
                }
            }
        }
    }
}
''',
            (json) {
                final connection = json['entity']['withdrawals'];
                return WithdrawalRequestToWithdrawalsConnection.fromJson(connection);
            },
            variables: {"entity_id": id, "first": first},
        )));
    }


    static Query<WithdrawalRequest> getWithdrawalRequestQuery(String id) {
        return Query(
            '''
query GetWithdrawalRequest(\$id: ID!) {
    entity(id: \$id) {
        ... on WithdrawalRequest {
            ...WithdrawalRequestFragment
        }
    }
}

$fragment  
''',
            (json) => WithdrawalRequest.fromJson(json["entity"]),
            variables: {'id': id},
        );
    }

static WithdrawalRequest fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
        json["withdrawal_request_id"],
        json["withdrawal_request_created_at"],
        json["withdrawal_request_updated_at"],
        CurrencyAmount.fromJson(json["withdrawal_request_requested_amount"]),
        CurrencyAmount.fromJson(json["withdrawal_request_amount"]),
        json["withdrawal_request_bitcoin_address"],
        WithdrawalRequestStatus.values.asNameMap()[json['withdrawal_request_status']] ?? WithdrawalRequestStatus.FUTURE_VALUE,
"WithdrawalRequest",        (json['withdrawal_request_estimated_amount'] != null ? CurrencyAmount.fromJson(json['withdrawal_request_estimated_amount']) : null),
        (json['withdrawal_request_amount_withdrawn'] != null ? CurrencyAmount.fromJson(json['withdrawal_request_amount_withdrawn']) : null),
        (json['withdrawal_request_total_fees'] != null ? CurrencyAmount.fromJson(json['withdrawal_request_total_fees']) : null),
        json["withdrawal_request_completed_at"],
        json["withdrawal_request_withdrawal"]?["id"],

        );

}

    static const fragment = r'''
fragment WithdrawalRequestFragment on WithdrawalRequest {
    __typename
    withdrawal_request_id: id
    withdrawal_request_created_at: created_at
    withdrawal_request_updated_at: updated_at
    withdrawal_request_requested_amount: requested_amount {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    withdrawal_request_amount: amount {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    withdrawal_request_estimated_amount: estimated_amount {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    withdrawal_request_amount_withdrawn: amount_withdrawn {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    withdrawal_request_total_fees: total_fees {
        __typename
        currency_amount_original_value: original_value
        currency_amount_original_unit: original_unit
        currency_amount_preferred_currency_unit: preferred_currency_unit
        currency_amount_preferred_currency_value_rounded: preferred_currency_value_rounded
        currency_amount_preferred_currency_value_approx: preferred_currency_value_approx
    }
    withdrawal_request_bitcoin_address: bitcoin_address
    withdrawal_request_status: status
    withdrawal_request_completed_at: completed_at
    withdrawal_request_withdrawal: withdrawal {
        id
    }
}''';

}
