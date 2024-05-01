// SPDX-License-Identifier: MIT

pragma solidity ^0.5.1;
pragma experimental ABIEncoderV2; // experimental feature | do not use in live deployments

// import "./DirectedGraph.sol";
// import "./EnumerableMap.sol";
import "./HitchensUnorderedKeySet.sol";

// /*
contract Balancing {
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;

    struct Reason {
        uint256 justification;
        uint256 issue;
        uint256 polarity;
    }

    struct Case {
        uint256 rcount;
        uint256[] reasons;
        uint256 issue;
    }

    HitchensUnorderedKeySetLib.Set reasonsIds;
    mapping(uint256 => Reason) reasons;
    uint256 issueTBD;
    Case caseToBeDecided; 
    mapping(uint256 => uint256) weights;

    mapping(address => HitchensUnorderedKeySetLib.Set) sources;


    constructor() public {
        // for now constructor sets issue to 0 // this is a bit silly as there will only be one issue in the contract but there can be reasons that are relevant for another issue.
        
        issueTBD = 0;
        
        //changeWeight(1,1);

        uint256 reasonID = reasonsIds.count() + 1;
        reasonsIds.insert(bytes32(reasonID));
        Reason storage reason = reasons[reasonID];
        reason.justification = 0;
        reason.issue = 0;
        reason.polarity = 0;
        weights[reasonID-1] = 42;
    }

// create functon to initialize contract. create access right for admin to set issue and read rights of the discourse.



    function returnWeight(uint256 r) 
        public
        view
        returns (uint256 weight) 
    {
        weight = weights[r];
    }

    function changeWeight(uint256 reason, uint256 newWeight) 
        public
    {
        assert(reason != 0);
        weights[reason] = newWeight;
    }

    function getWeights()
        public
        view
        returns (
            uint256[] memory
        )
    {
        uint256 rs = reasonsIds.count();

        uint256[] memory _weights = new uint256[](rs);

        for (uint256 i = 0; i < rs; i++) {
            _weights[i] = weights[i];
        }

        return _weights;
    }

    function getIssue()
        public
        view
        returns ( uint256 )
    {
        return issueTBD;
    }
    
    function setIssue(uint256 issue)
    	public
    {
    	// TODO change to depend on access rights and can only be called at the start
    	if(reasonsIds.count() < 2) {
    	    issueTBD = issue;
    	}
    }

    function getReasons()
        public
        view
        returns (
            uint256[] memory justifications,
            uint256[] memory issues,
            uint256[] memory polarities
        )
    {
        
        uint256 reasonsCount = reasonsIds.count();

        justifications = new uint256[](reasonsCount);
        issues = new uint256[](reasonsCount);
        polarities = new uint256[](reasonsCount);

        for (uint256 i = 0; i < reasonsIds.count(); i++) {
            uint256 reasonId = uint256(reasonsIds.keyAtIndex(i));
            Reason storage reason = reasons[reasonId];
            justifications[i] = reason.justification;
            issues[i] = reason.issue;
            polarities[i] = reason.polarity;
        }
    }

    function voteOnReason(uint256 justification, uint256 issue, uint256 polarity) 
        public
        returns (int256 re)
    {

        re = 0;
        // check that reason is not known yet.
        for (uint256 j = 1; j < reasonsIds.count() + 1; j++) {
            if (reasons[j].justification == justification && 
            reasons[j].issue == issue && reasons[j].polarity == polarity) {
                // conclude reason is already in reasons
                // increase weight by +1
                weights[j-1]++;
                re = 1;
                break;
            }
        }

        if (re == 0) {
            uint256 reasonID = reasonsIds.count() + 1;
            reasonsIds.insert(bytes32(reasonID));
            Reason storage reason = reasons[reasonID];
            reason.justification = justification;
            reason.issue = issue;
            reason.polarity = polarity;
            weights[reasonID-1]++;
    
            HitchensUnorderedKeySetLib.Set storage source = sources[
                msg.sender
            ];
            source.insert(bytes32(reasonID));
            re = int256(reasonID);
        }
    }
   

    function procedureAdditive()
        public
        view 
        returns (int256 sum)
    {

        sum = 0;
        uint256 rs = reasonsIds.count();        
        for (uint256 i = 0; i < rs; i++){
                
            uint256 reasonId = uint256(reasonsIds.keyAtIndex(i));
            Reason storage reason = reasons[reasonId];

            if (reason.issue == issueTBD) {
                if (reason.polarity == 0) { // condition polarity is ?
                    continue;
                }
                else if (reason.polarity == 1) { // condition polarity -
                    sum -= int256(weights[i]);
                }
                else if (reason.polarity == 2) { // condition polarity +
                    sum += int256(weights[i]);
                }
            }
        }   
        if (sum > 0) {
            sum = 2;
        }
        else if (sum < 0) {
            sum = 1;
        }
        else {
            sum = 0;
        }
    }

}
