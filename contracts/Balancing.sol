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

    struct Context {
        uint256[] reasons;
        uint256 issue;
    }

    struct ReCo { // reason-context pair
        Reason reason;
        Context context;
    }

    HitchensUnorderedKeySetLib.Set contextsIds;
    mapping(uint256 => Context) contexts;
    HitchensUnorderedKeySetLib.Set reasonsIds;
    mapping(uint256 => Reason) reasons;

    mapping(address => HitchensUnorderedKeySetLib.Set) sources;

    event Bla(
        int value
    );


    constructor() public {
        contextsIds.insert(bytes32(uint256(1)));
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
        returns (int256 re)
    {

        re = 0;
        // check that reason does is not known yet.
        for (uint256 j = 0; j < reasonsIds.count() + 1; j++) {
            if (reasons[j].justification == justification && 
            reasons[j].issue == issue && reasons[j].polarity == polarity) {
                // conclude reason is already in reasons
                re = -1;
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
    
            HitchensUnorderedKeySetLib.Set storage source = sources[
                msg.sender
            ];
            source.insert(bytes32(reasonID));
            re = int256(reasonID);
        }

    }

    function getContexts()
        public
        view
        returns (
            uint256[][] memory reasonss,
            uint256[] memory issues
        )
    {
        uint256 contextsCount = contextsIds.count();

        reasonss = new uint256[][](contextsCount);
        issues = new uint256[](contextsCount);

        for (uint256 i = 0; i < contextsIds.count(); i++) {
            uint256 contextId = uint256(contextsIds.keyAtIndex(i));
            Context storage context = contexts[contextId];
            reasonss[i] = context.reasons;
            issues[i] = context.issue;
        }
    }
    

    function insertContext(uint256[] memory rs, uint256 issue) 
        public
        returns (uint256 contextID)
    {
        
        contextID = contextsIds.count() + 1;
        contextsIds.insert(bytes32(contextID));
        Context storage context = contexts[contextID];
        context.reasons = rs;
        context.issue = issue;

        HitchensUnorderedKeySetLib.Set storage source = sources[
            msg.sender
        ];
        // *10 short term solution writing from insert reason and insert context
        source.insert(bytes32(contextID*10));

    }





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
