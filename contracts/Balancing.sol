// SPDX-License-Identifier: MIT

pragma solidity ^0.5.1;

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

    struct Context {
        HitchensUnorderedKeySetLib.Set reasonsIds;
        mapping(uint256 => Reason) reasons;
        uint256 issue;
    }

    HitchensUnorderedKeySetLib.Set contextsIds;
    mapping(uint256 => Context) contexts;
    HitchensUnorderedKeySetLib.Set reasonsIds;
    mapping(uint256 => Reason) reasons;

    mapping(address => HitchensUnorderedKeySetLib.Set) sources;


    constructor() public {
        // contextsIds.insert(bytes32(uint256(1)));
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

    function insertReason(uint256 justification, uint256 issue, uint256 polarity) 
        public
        returns (uint256 reasonID)
    {
        // TODO check that reason does not exist yet.

        reasonID = reasonsIds.count() + 1;
        reasonsIds.insert(bytes32(reasonID));
        Reason storage reason = reasons[reasonID];
        reason.justification = justification;
        reason.issue = issue;
        reason.polarity = polarity;
 

        HitchensUnorderedKeySetLib.Set storage source = sources[
            msg.sender
        ];
        source.insert(bytes32(reasonID));

    }
    

    // function insertContext(uint256[] memory rs, uint256 issue) 
    //     public
    //     returns (uint256 contextID)
    // {
        
    //     contextID = contextsIds.count() + 1;
    //     contextsIds.insert(bytes32(contextID));
    //     Context storage context = contexts[contextID];
    //     for (uint256 i = 0; i < rs.length; i++) {
    //         reasonID = context.reasonsIds.count() + 1;
    //         context.reasonIds.insert(bytes32(reasonID));
    //         Reason storage r = context.rs[reasonID];
    //         uint256 rID = uin256(reasonsIds.keyAtIndex(i));
    //         reason.justification = rs[rID].justifcation;
    //         reason.issue = rs[rID].issue;
    //         reason.polarity = rs[rID].polarity;
    //     }
    //     context.issue = issue;

    // }

    // function insertReason(uint256 justification, uint256 issue, uint256 polarity) 
    //     public
    //     returns (uint256 reasonID)
    // {
        
    //     reasonID = reasonsIds.count() + 1;
    //     reasonIds.insert(bytes32(reasonID));
    //     Reason storage reason = reasons[reasonID];
    //     reason.justification = justifcation;
    //     reason.issue = issue;
    //     reason.polarity = polarity;

    // }



    // function procedureAdditive(Context c, uint256[] weightsc)
    //     public 
    //     view
    //     returns (uint256 value)
    // {
    //     for (i = 0; i < c.reasons.count(); i++){
    //         sum = 0;
    //         r = c.reasons[i];
    //         if (r[2] = c.issue) {
    //             sum += r[3]*weightsc[i];
    //         }
    //     }
    //     if (sum > 0) {
    //         value = 1;
    //     }
    //     else if (sum < 0) {
    //         value = -1;
    //     }
    //     else {
    //         value = 0;
    //     }
    // }

    // function getGraph(uint256 graphId)
    //     public
    //     view
    //     returns (
    //         uint256[] memory nodes,
    //         uint256[] memory edgesSource,
    //         uint256[] memory edgesTarget
    //     )
    // {
    //     DirectedGraph.Graph storage graph = graphs[graphId];
    //     uint256 nodesCount = graph.nodesIds.count();
    //     uint256 edgesCount = graph.edgesIds.count();

    //     nodes = new uint256[](nodesCount);
    //     edgesSource = new uint256[](edgesCount);
    //     edgesTarget = new uint256[](edgesCount);

    //     for (uint256 i = 0; i < graph.nodesIds.count(); i++) {
    //         nodes[i] = uint256(graph.nodesIds.keyAtIndex(i));
    //     }

    //     for (uint256 i = 0; i < graph.edgesIds.count(); i++) {
    //         uint256 edgeId = uint256(graph.edgesIds.keyAtIndex(i));
    //         DirectedGraph.Edge storage edge = graph.edges[edgeId];
    //         edgesSource[i] = edge.source;
    //         edgesTarget[i] = edge.target;
    //     }
    // }

}
// */
