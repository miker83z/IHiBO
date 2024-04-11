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

    struct WeightSystem {
        mapping(uint256 => mapping(uint256 => uint256)) weights;
    }

    HitchensUnorderedKeySetLib.Set contextsIds;
    mapping(uint256 => Context) contexts;
    HitchensUnorderedKeySetLib.Set reasonsIds;
    mapping(uint256 => Reason) reasons;
    HitchensUnorderedKeySetLib.Set weightSystemIds;
    mapping(uint256 => WeightSystem) weightSystems;

    mapping(address => HitchensUnorderedKeySetLib.Set) sources;



    constructor() public {
        weightSystemIds.insert(bytes32(uint256(1)));
        // initReasons();

        uint256 reasonID = reasonsIds.count() + 1;
        reasonsIds.insert(bytes32(reasonID));
        Reason storage reason = reasons[reasonID];
        reason.justification = 0;
        reason.issue = 0;
        reason.polarity = 0;

        uint256 contextID = contextsIds.count() + 1;
        contextsIds.insert(bytes32(contextID));
        Context storage context = contexts[contextID];
        context.reasons = [0];
        context.issue = 0;
    }

    function changeWeight(uint256 weightSystemId, uint256 reason, uint256 context, uint256 newWeight) 
        public
    {
        assert(reason != 0);
        WeightSystem storage weightSystem = weightSystems[weightSystemId];
        weightSystem.weights[reason][context] = newWeight;
    }

    // function initializeNewWeights() 
    //     public
    // {
    //     for (uint256 i = 0; i < weightSystemIds.count(); i++) {
    //         uint256 wsId = uint256(weightSystemIds.keyAtIndex(i));
    //         WeightSystem storage weightSystem = weightSystems[wsId];


    //         for (uint256 r = 0; r < reasonsIds.count(); r++) {
    //             for (uint256 c = 0; c < contextsIds.count(); c++) {
    //                 if (r > weightSystem.numberOfReasons || c > weightSystem.numberOfContexts) {
    //                     weightSystem.weights[r][c] = 0;
    //                 }
    //             }
    //         }
    //         weightSystem.numberOfContexts = contextsIds.count();
    //         weightSystem.numberOfReasons = reasonsIds.count();
    //     }
    // }

    function getWeights(uint256 wsId)
        public
        view
        returns (
            uint256[] memory weights
        )
    {
        WeightSystem storage weightSystem = weightSystems[wsId];
        weights = new uint256[](reasonsIds.count());
        for (uint256 i = 0; i < 1; i++) {
            weights[i] = weightSystem.weights[0][i];
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

    function insertReason(uint256 justification, uint256 issue, uint256 polarity) 
        public
        returns (int256 re)
    {

        re = 0;
        // check that reason is not known yet.
        for (uint256 j = 0; j < reasonsIds.count() + 1; j++) {
            if (reasons[j].justification == justification && 
            reasons[j].issue == issue && reasons[j].polarity == polarity) {
                // conclude reason is already in reasons
                // return false;
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

        for (uint256 i = 0; i < contextsCount; i++) {
            reasonss[i] = new uint256[](10);
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
        // possible TODO: instead of removing unknown reasons add them to known reasons
        // but with ?'s as x, y and v.

        uint256 reasonsCount = reasonsIds.count();
        uint256[] memory rss = new uint256[](reasonsCount);
        uint256 amount = 0;
        for (uint256 i = 0; i < rs.length; i++) {
            if (rs[i] < reasonsCount) {
                rss[i] = rs[i];
            }
        }

        uint256[] memory rsss = new uint256[](rs.length);
        uint256 j = 0;
        for (uint256 i = 0; i < rs.length; i++) {
            if (rs[i] < reasonsCount) {
                rsss[j] = rs[i];
                j += 1;
            }
        }

        contextID = contextsIds.count() + 1;
        contextsIds.insert(bytes32(contextID));
        Context storage context = contexts[contextID];
        context.reasons = rsss;
        context.issue = issue; // does not really do what it should

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
