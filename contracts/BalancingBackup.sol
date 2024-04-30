// SPDX-License-Identifier: MIT

// TODO consider making more contracts for example for the data structures with getters and setters
// like in the example on: https://github.com/rob-Hitchens/UnorderedKeySet

pragma solidity ^0.5.1;
pragma experimental ABIEncoderV2; // experimental feature | do not use in live deployments

// import "./DirectedGraph.sol";
// import "./EnumerableMap.sol";
import "./HitchensUnorderedKeySet.sol";

// /*
contract BalancingBackUp {
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;

    struct Reason {
        uint256 justification;
        uint256 issue;
        uint256 polarity;
    }

    struct Context {
        uint256 rcount;
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
        uint256 wsID = weightSystemIds.count() + 1;
        weightSystemIds.insert(bytes32(wsID));
        WeightSystem storage weightSystem = weightSystems[wsID];
        weightSystem.weights[1][1] = 2;

        // initReasons();
        // changeWeight(0,0,0,1);

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
        context.rcount = 1;
        context.issue = 0;

    }

    function returnWeight(uint256 r, uint256 c) 
        public
        view
        returns (uint256 weight) 
    {
        WeightSystem storage weightSystem = weightSystems[1];
        weight = weightSystem.weights[r][c];
    }

    function changeWeight(uint256 weightSystemId, uint256 reason, uint256 context, uint256 newWeight) 
        public
    {
        assert(reason != 0);
        uint256 key = uint256(weightSystemIds.keyAtIndex(weightSystemId));
        WeightSystem storage weightSystem = weightSystems[key];
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
            uint256[5][3] memory weights
        )
    {
        // TODO not finished yet this is only considering context 0.
        uint256 key = uint256(weightSystemIds.keyAtIndex(wsId));
        WeightSystem storage weightSystem = weightSystems[key];

        // uint256 rs = reasonsIds.count();
        // uint256 cs = contextsIds.count();
        // uint256[5][3] memory weights;

        // uint256[] memory _weights = new uint256[](reasonsIds.count());
        // weights = new uint256[][](contextsIds.count());

        for (uint256 j = 0; j < contextsIds.count(); j++) {
            for (uint256 i = 0; i < reasonsIds.count(); i++) {
                // _weights[i] = weightSystem.weights[i][j];
                weights[j][i] = weightSystem.weights[i][j];
            }
            // weights[j] = _weights;
        }
        return weights;
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
            reasonss[i] = new uint256[](10); // 10 was a temporary solution
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
        // part of this function is redone to put ?'s but this makes part of the function redundant

        uint256 reasonsCount = reasonsIds.count();
        uint256[] memory rss = new uint256[](reasonsCount);
        // uint256 amount = 0;
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
        
        // does not really do what it should? // why did I write this?
        contextID = contextsIds.count() + 1;
        contextsIds.insert(bytes32(contextID));
        Context storage context = contexts[contextID];
        context.rcount = rs.length;
        context.reasons = rsss;
        context.issue = issue; 

        HitchensUnorderedKeySetLib.Set storage source = sources[
            msg.sender
        ];

        // TODO *10 short term solution writing from insert reason and insert context
        source.insert(bytes32(contextID*10));

        // TODO add weight instantiation.

    }


    function procedureAdditive(uint256 wsID, uint256[] memory con)
        public 
        view
        returns (int256[] memory sum)
    {
        // int256[] memory sum;
        sum = new int256[](con.length);

        uint256 wkey = uint256(weightSystemIds.keyAtIndex(wsID));
        WeightSystem storage weightSystem = weightSystems[wkey];

        for (uint256 j = 0; j < con.length; j++) {
            uint256 ckey = uint256(contextsIds.keyAtIndex(con[j]));
            Context storage context = contexts[ckey];

            sum[j] = 0;
            
            for (uint256 i = 0; i < context.rcount; i++){
                
                uint256 r = context.reasons[i];
                uint256 reasonId = uint256(reasonsIds.keyAtIndex(r));
                Reason storage reason = reasons[reasonId];

                if (reason.issue == context.issue) {
                    if (reason.polarity == 0) { // condition polarity is ?
                        continue;
                    }
                    else if (reason.polarity == 1) { // condition polarity -
                        sum[j] -= int256(weightSystem.weights[r][con[j]]);
                    }
                    else if (reason.polarity == 2) { // condition polarity +
                        sum[j] += int256(weightSystem.weights[r][con[j]]);
                    }
                }
            }
             if (sum[j] > 0) {
                sum[j] = 2;
            }
            else if (sum[j] < 0) {
                sum[j] = 1;
            }
            else {
                sum[j] = 0;
            }
        }
    }

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
