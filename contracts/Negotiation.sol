// SPDX-License-Identifier: MIT

pragma solidity ^0.5.1;

contract Negotiation {
    uint256 negotiationNum;
    mapping(uint256 => NegotiationStruct) negotiations;

    struct NegotiationStruct {
        uint256 j;
        address a;
        address b;
        uint256[] aProposals;
        uint256[] bProposals;
        bool accepted;
        uint256 acceptedProposal;
    }

    constructor() public {}

    function newNegotiation(
        uint256 j,
        address a,
        address b
    ) public returns (uint256 negotiationId) {
        negotiationId = negotiationNum++;
        NegotiationStruct storage negotiation = negotiations[negotiationId];
        negotiation.j = j;
        negotiation.a = a;
        negotiation.b = b;
    }

    function newProposal(uint256 negId, uint256 proposal) public {
        NegotiationStruct storage negotiation = negotiations[negId];
        require(
            msg.sender == negotiation.a || msg.sender == negotiation.b,
            "Negotiation: Sender not allowed"
        );
        require(!negotiation.accepted, "Negotiation: Already accepted");
        if (msg.sender == negotiation.a) {
            negotiation.aProposals.push(proposal);
        } else {
            negotiation.bProposals.push(proposal);
        }
    }

    function accept(uint256 negId, uint256 acceptedProposal) public {
        NegotiationStruct storage negotiation = negotiations[negId];
        require(
            msg.sender == negotiation.a || msg.sender == negotiation.b,
            "Negotiation: Sender not allowed"
        );
        require(!negotiation.accepted, "Negotiation: Already accepted");
        negotiation.accepted = true;
        negotiation.acceptedProposal = acceptedProposal;
    }
}
