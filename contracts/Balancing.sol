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
        string justification;
        string issue;
        string polarity;
    }

    struct Context {
        uint256 rcount;
        string[] reasons;
        string issue;
    }

    struct Decision {
        Context context;
        mapping(uint256 => uint256) weights;
        uint256 outputPolarity;
    }

    HitchensUnorderedKeySetLib.Set reasonsIds;
    mapping(uint256 => Reason) reasons;
    string issueTBD;
    Context contextTBD; 
    mapping(uint256 => uint256) weights;

    // HitchensUnorderedKeySetLib.Set decisionsIds;
    // mapping(uint256 => Decision) decisions;

    mapping(address => HitchensUnorderedKeySetLib.Set) sources;

    mapping(address => uint256) reputations;

    // event Output(uint256 key);
    event Output(string reasons, string issue, string polarity);


    constructor() public {
        // for now constructor sets issue to 0 // this is a bit silly as there will only be one issue in the contract but there can be reasons that are relevant for another issue.
        
        issueTBD = '0';
    }

    // create functon to initialize contract. create access right for admin to set issue and read rights of the discourse.

    function convertToString(uint256 value) 
        internal 
        pure 
        returns (string memory) 
    {
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }

        return string(buffer);
    }

    function compareStrings(string memory a, string memory b) public view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function setReputation(uint256 rep, address subject) 
        public
    {
        assert(msg.sender!=subject);
        reputations[subject] = rep;
    }

    function returnWeight(uint256 r) 
        public
        view
        returns (uint256 weight) 
    {
        weight = weights[r];
    }

    function changeWeight(uint256 reasonID, uint256 newWeight) 
        public
    {
        assert(reasonID != 0);
        weights[reasonID] = newWeight;
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
        returns ( string memory)
    {
        return issueTBD;
    }
    
    function setIssue(string memory issue)
    	public
    {
    	// TODO change to depend on access rights and can only be called at the start
    	if(true) {
    	    issueTBD = issue;
    	}
    }

    function getReasons()
        public
        view
        returns (
            string[] memory justifications,
            string[] memory issues,
            string[] memory polarities
        )
    {
        
        uint256 reasonsCount = reasonsIds.count();

        justifications = new string[](reasonsCount);
        issues = new string[](reasonsCount);
        polarities = new string[](reasonsCount);

        for (uint256 i = 0; i < reasonsIds.count(); i++) {
            uint256 reasonId = uint256(reasonsIds.keyAtIndex(i));
            Reason storage reason = reasons[reasonId];
            justifications[i] = reason.justification;
            issues[i] = reason.issue;
            polarities[i] = reason.polarity;
        }
    }

    function voteOnReason
    (
        string memory justification, 
        string memory issue, 
        string memory polarity, 
        uint256 magnitude
    ) 
        public
        returns (int256 re)
    {

        re = 0;
        // check that reason is not known yet.
        for (uint256 j = 1; j < reasonsIds.count() + 1; j++) {
            // if reason is known
            uint256 reasonId = uint256(reasonsIds.keyAtIndex(j));
            if (compareStrings(reasons[reasonId].justification, justification) && 
            compareStrings(reasons[reasonId].issue, issue) && 
            compareStrings(reasons[reasonId].polarity, polarity)) {
                // conclude reason is already in reasons
                // increase weight by +1
                weights[reasonId-1] = weights[reasonId-1] + magnitude*reputations[msg.sender];
                
                HitchensUnorderedKeySetLib.Set storage source = sources[
                    msg.sender
                ];
                source.insert(bytes32(reasonId));
                re = int256(reasonId);
                break;
            }
        }

        if (re == 0) {// reason is new add reason and set weight to 1
            uint256 reasonID = reasonsIds.count() + 1;
            reasonsIds.insert(bytes32(reasonID));
            Reason storage reason = reasons[reasonID];
            reason.justification = justification;
            reason.issue = issue;
            reason.polarity = polarity;
            weights[reasonID-1] = magnitude*reputations[msg.sender];
    
            HitchensUnorderedKeySetLib.Set storage source = sources[
                msg.sender
            ];
            source.insert(bytes32(reasonID));
            re = int256(reasonID);
        }
    }
   

    function procedureAdditive()
        public
        // view 
        returns (string memory dec)
    {

        dec = '';
        uint256 magn = 0;
        uint256 pos = 0;
        uint256 ppos = 0;
        uint256 neg = 0;
        uint256 nneg = 0;
        int256 sum = 0;
        uint256 neut = 0;
        string memory cs = '';
        uint256 rs = reasonsIds.count();   


        for (uint256 i = 0; i < rs; i++){
                
            uint256 reasonId = uint256(reasonsIds.keyAtIndex(i));
            Reason storage reason = reasons[reasonId];
            
            cs = string(abi.encodePacked(cs, " ", i, " ", reason.justification));

            if (compareStrings(reason.issue, issueTBD)) {
                if (compareStrings(reason.polarity, '0')) { 
                    neut += uint256(weights[i]);
                }
                else if (compareStrings(reason.polarity, '-')) { 
                    neg += uint256(weights[i]);
                }
                else if (compareStrings(reason.polarity, '+')) { 
                    pos += uint256(weights[i]);
                }
                else if (compareStrings(reason.polarity, '--')) { 
                    nneg += uint256(weights[i]);
                }
                else if (compareStrings(reason.polarity, '++')) { 
                    ppos += uint256(weights[i]);
                }
            }
        }  

        sum = int256(pos) + 2*int256(ppos) - (int256(neg) + 2*int256(nneg));
        magn = sum < 0 ? uint256(-sum) : uint256(sum);

        // pos += 2*ppos;
        // neg += 2*nneg;
        // magn = pos > neg ? pos - neg : neg - pos;
        // magn = 2*magn < neut ? neut-magn : (2*magn-neut)/2;
        // string memory Magn = convertToString(magn);

        if (!(2*magn > neut)) {
            magn = neut;
            string memory Magn = convertToString(magn);
            dec = string(abi.encodePacked(dec, '(', Magn, ', ', '0', ')'));
            // dec = string(magn + '0');
            // dec = '0';
        }
        else if (sum > 0 && ppos > pos) {
            // 2*pos > 2*(neut+2*neg)) {
            magn = ppos;
            string memory Magn = convertToString(magn);
            dec = string(abi.encodePacked(dec, '(', Magn, ', ', '++', ')'));
            // dec = string(magn + '++');
            // dec = '++';
        }
        else if (sum > 0) {
            // 2*pos > neut+2*neg) {
            magn = pos;
            string memory Magn = convertToString(magn);
            dec = string(abi.encodePacked(dec, '(', Magn, ', ', '+', ')'));
            // dec = string(magn + '+');
            // dec = '+';
        }
        else if (sum < 0 && nneg > neg) {
            // 2*neg > 2*(neut+2*pos)) {
            magn = nneg;
            string memory Magn = convertToString(magn);
            dec = string(abi.encodePacked(dec, '(', Magn, ', ', '--', ')'));
            // dec = string(magn + '--');
            // dec = '--';
        }
        else if (sum < 0) {
            // 2*neg > neut+2*pos) {
            magn = neg;
            string memory Magn = convertToString(magn);
            dec = string(abi.encodePacked(dec, '(', Magn, ', ', '-', ')'));
            // dec = string(magn + '-');
            // dec = '-';
        }
        else {
            magn = 0;
            string memory Magn = convertToString(magn);
            dec = string(abi.encodePacked(dec, '(', Magn, ', ', '0', ')'));
        }


    // untested code for emiting decisionKey
    // /*
        // contextTBD.rcount = rs;
        // contextTBD.reasons = reasons;
        // contextTBD.issue = issueTBD;

        // uint256 decisionID = decisionsIds.count() + 1;
        // decisionsIds.insert(bytes32(decisionID));
        // Decision storage decision = decisions[decisionID];
        // decision.context = contextTBD;
        // decision.weights = weights;
        // decision.outputPolarity = uint256(sum);

        // emit Output(decisionID);
        // */

        // emit Output(42); // ^^'
        emit Output(cs ,issueTBD, dec);

        return dec;
    }

}
