// SPDX-License-Identifier: MIT

pragma solidity ^0.5.1;

contract Negotiation {
    uint256 negotiationNum;
    mapping(uint256 => NegotiationStruct) negotiations;

    struct NegotiationStruct {
        address a;
        address b;
        uint256[][] aOffers;
        uint256[][] bOffers;
        bool accepted;
    }

    constructor() public {}

    function newNegotiation(address b) public returns (uint256 negotiationId) {
        negotiationId = negotiationNum++;
        NegotiationStruct storage negotiation = negotiations[negotiationId];
        negotiation.a = msg.sender;
        negotiation.b = b;
    }

    function newOffer(uint256 negId, uint256[] memory offer) public {
        NegotiationStruct storage negotiation = negotiations[negId];
        require(
            msg.sender == negotiation.a || msg.sender == negotiation.b,
            "Negotiation: Sender not allowed"
        );
        require(!negotiation.accepted, "Negotiation: Already accepted");
        if (msg.sender == negotiation.a) {
            negotiation.aOffers.push(offer);
        } else {
            negotiation.bOffers.push(offer);
        }
    }

    function accept(uint256 negId) public {
        NegotiationStruct storage negotiation = negotiations[negId];
        require(
            msg.sender == negotiation.a || msg.sender == negotiation.b,
            "Negotiation: Sender not allowed"
        );
        require(!negotiation.accepted, "Negotiation: Already accepted");
        negotiation.accepted = true;
    }
}
