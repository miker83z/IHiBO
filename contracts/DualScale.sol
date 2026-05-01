// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

// import "./DirectedGraph.sol";
// import "./EnumerableMap.sol";
import "./SimpleSet.sol";

contract DualScale {

// ----------------------------------------------------------------------------
    // could use directed graph to represent reasons and their relations however reasons and weight can also be represented directly
    // using DirectedGraph for DirectedGraph.Graph;
    
    using SimpleSet for SimpleSet.Set;

// ----------------------------------------------------------------------------
    // Data Structures

    struct Reason {
        string ground;
        string option;
    }

    struct Weight {
        uint justifying;
        uint requiring;
    }

// ----------------------------------------------------------------------------
    // State Variables

    // we use a key to access each weight in the weighting function, using the mapping:
    // key = keccak256(abi.encodePacked(reasonID, option1, option2, contextID))
    mapping(bytes32 => Weight) private weightingFunction;

    // storage for reasons, options, and agents
    // a mapping can not be iterated over, so we use SimpleSet to keep track of existing IDs 
    // reasons[reasonId] = Reason
    SimpleSet.Set reasonIDs;
    mapping(bytes32 => Reason) reasons; // reasonId = keccak(ground, option)
    // option[optionID] = option
    SimpleSet.Set optionIDs;
    mapping(bytes32 => string) options;
    // agents[agentID] = address
    SimpleSet.Set agentIDs; // agentID is used as a contextID; each agent has their own context
    mapping(bytes32 => address) private agents;

// ----------------------------------------------------------------------------
    // Events
    // using "event" we can emit outputs to the network chain log

    event Output(int256[] args);

// ----------------------------------------------------------------------------
    // constructor
    // A constructor is a function that is called once when the contract is deployed
    // Here we can initialize some default options
    // introducing a default "do Nothing" option with ID 1
    constructor() public {
        optionIDs.insert(bytes32(uint256(1)));
        options[1] = 'do Nothing';
    }

// ----------------------------------------------------------------------------
    // Internal Helper Functions

    // string comparison function; takes two strings and returns true if they are equal
    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    //sign function; returns 1 if x > 0, -1 if x < 0, 0 if x == 0
    function sgn(int256 x) internal pure returns (int256) {
        if (x > 0) {
            return 1;
        } else if (x < 0) {
            return -1;
        } else {
            return 0;
        }
    }

// --- Getters ------------------------------------------------------------------------

    // get justifying and requiring weights for a given reason, option1, option2, and agent
    // TODO test if function works as intended
    function getAgentReasonWeight(
        uint256 reasonID,
        string memory option1,
        string memory option2,
        uint256 agentID
    ) public view returns (uint justifying, uint requiring) {
        // check if reason, options and agent exist // Actually, we can skip this check since if they don't exist, the weights will just be 0.
        // require(reasonIDs.exists(bytes32(reason)), "Reason does not exist");
        // require(optionIDs.exists(keccak256(abi.encodePacked(option1))), "Option1 does not exist");
        // require(optionIDs.exists(keccak256(abi.encodePacked(option2))), "Option2 does not exist");
        // require(agents.exists(keccak256(abi.encodePacked(agent))), "Agent does not exist");

        uint contextID = agentID;
        bytes32 key = keccak256(abi.encodePacked(reasonID, option1, option2, contextID));

        Weight storage weight = weightingFunction[key];
        justifying = weight.justifying;
        requiring = weight.requiring;
    }

    // get all the weights for a given agent in a given comparison of option1 and option2
    // TODO 
    function getAgentWeights(
        string memory option1,
        string memory option2,
        uint256 agentID
    ) public view returns (uint justifying, uint requiring) {
        // check if options and agent exist // Actually, we can skip this check since if they don't exist, the weights will just be 0.
        // require(optionIDs.exists(keccak256(abi.encodePacked(option1))), "Option1 does not exist");
        // require(optionIDs.exists(keccak256(abi.encodePacked(option2))), "Option2 does not exist");
        // require(agents.exists(keccak256(abi.encodePacked(agent))), "Agent does not exist");

        uint contextID = agentID;
        justifying = 0;
        requiring = 0;

        // iterate through all reasons
        uint256 reasonCount = reasonIDs.count();
        for (uint256 j = 0; j < reasonCount; j++) {
            bytes32 reasonID = reasonIDs.keyAtIndex(j);
            bytes32 key = keccak256(abi.encodePacked(reasonID, option1, option2, contextID));
            Weight storage weight = weightingFunction[key];
            justifying += weight.justifying;
            requiring += weight.requiring;
        }
    }

    // get the aggregated weights for each reason in a given comparison of option1 and option2
    // TODO 
    function getAggregatedWeights(
        string memory option1,
        string memory option2
    ) public view returns (uint justifyingOption1, uint requiringOption1, uint justifyingOption2, uint requiringOption2) {
        // check if options exist. Actually, we can skip this check since if they don't exist, the weights will just be 0.
        // alternatively, we can add a function to add options to the contract, so that only introduced options can get a permission status.
        // require(optionIDs.exists(keccak256(abi.encodePacked(option1))), "Option1 does not exist");
        // require(optionIDs.exists(keccak256(abi.encodePacked(option2))), "Option2 does not exist");

        justifyingOption1 = 0;
        requiringOption1 = 0;
        justifyingOption2 = 0;
        requiringOption2 = 0;

        // iterate through all reasons
        uint256 reasonCount = reasonIDs.count();
        for (uint256 i = 0; i < agentIDs.count(); i++) {
            uint contextId = i + 1; // contextID starts from 1
            for (uint256 j = 0; j < reasonCount; j++) {
                bytes32 reasonID = reasonIDs.keyAtIndex(j);
                bytes32 key = keccak256(abi.encodePacked(reasonID, option1, option2, contextId));
                Weight storage weight = weightingFunction[key];
                if (reasons[reasonID].option == option1) {
                    justifyingOption1 += weight.justifying;
                    requiringOption1 += weight.requiring;
                } else if (reasons[reasonID].option == option2) {
                    justifyingOption2 += weight.justifying;
                    requiringOption2 += weight.requiring;
                }
            }
        }
    }

// ----------------------------------------------------------------------------
    // Setters

    // record the vote on a reason by an agent
    // TODO 
    function voteOnReason(
        string memory ground,
        string memory option1,
        string memory option2,
        uint justifying,
        uint requiring
    ) public {
        // adding options and agents if they don't exist
        if (!optionIDs.exists(keccak256(abi.encodePacked(option1)))) {
            optionIDs.insert(keccak256(abi.encodePacked(option1)));
            options[optionIDs.count()] = option1;
        }
        if (!optionIDs.exists(keccak256(abi.encodePacked(option2)))) {
            optionIDs.insert(keccak256(abi.encodePacked(option2)));
            options[optionIDs.count()] = option2;
        }
        if (!agents.exists(keccak256(abi.encodePacked(msg.sender)))) {
            agents.insert(keccak256(abi.encodePacked(msg.sender)));
            agentIDs.push(msg.sender); // assign a new contextID to the new agent
        }

        // initializing keys
        uint contextID = agentIDs.length - 1; // get the last index as contextID
        bytes32 reasonID = keccak256(abi.encodePacked(ground));
        bytes32 key = keccak256(abi.encodePacked(reasonID, option1, option2, contextID));

        // add voted weights to reason its weight
        Weight storage weight = weightingFunction[key]; // default to 0 if not exists
        weight.justifying += justifying;
        weight.requiring += requiring;
    }

// ----------------------------------------------------------------------------
    // Core Functions

    // compare two options and return the deontic status based on the aggregated weights
    // TODO
    function BalanceScale(string memory option1, string memory option2)
        public
        view
        returns (int256 permissionScaleBalance, int256 requirementScaleBalance)
    {
        // check if options exist. Actually, we can skip this check since if they don't exist, the weights will just be 0.
        // require(optionIDs.exists(keccak256(abi.encodePacked(option1))), "Option1 does not exist");
        // require(optionIDs.exists(keccak256(abi.encodePacked(option2))), "Option2 does not exist");

        permissionScaleBalance = 0;
        requirementScaleBalance = 0;
        for (uint256 i = 0; i < agents.count(); i++) {
            uint contextId = i + 1; // contextID starts from 1
            // iterate through all reasons

            for (uint256 j = 0; j < reasons.count(); j++) { // arbitrary limit to avoid infinite loop
                uint reasonID = j + 1; // reasonID starts from 1
                bytes32 key = keccak256(abi.encodePacked(reasonID, option1, option2, contextId));

                Weight storage weight = weightingFunction[key];

                permissionScaleBalance += int256(weight.justifying);
                requirementScaleBalance -= int256(weight.requiring);
            }
        }
        // normalize to -1, 0, 1
        // if there are no reasons the balance will be 0 for both scales.
        permissionScaleBalance = sgn(permissionScaleBalance);
        requirementScaleBalance = sgn(requirementScaleBalance);
    }

    // dynamically scale all options and return the non-dominated options
    // TODO
    function dynamicScale()
        public
        returns (int256[] memory args)
    {
        // This function compares all options pairwise and then determines which options never "loose"
        uint256 optionsCount = optionIDs.count();

        args = new int256[](optionsCount);
        for (uint256 i = 0; i < optionsCount; i++) {
            for (uint256 j = 0; j < optionsCount; j++) {
                if (i != j) {
                    (int256 p, int256 r) = BalanceScale(
                        options[uint256(optionIDs.keyAtIndex(i))],
                        options[uint256(optionIDs.keyAtIndex(j))]
                    );
                    // if option i is dominated by option j, we can mark it as dominated
                    if (p < 0) {
                        args[i] = -1; // dominated
                    } else if (args[i] != -1) {
                        args[i] = int256(optionIDs.keyAtIndex(i)); // non-dominated
                    }
                    if (r < 0) {
                        args[j] = -1; // dominated
                    } else if (args[j] != -1) {
                        args[j] = int256(optionIDs.keyAtIndex(j)); // non-dominated
                    }
                }
            }
        }

        emit Output(args);
    }

// ----------------------------------------------------------------------------
    // Deprecated Functions


    // This function uses multiplication of weights instead of addition for balance
    // function multiplicativeBalanceScale(string memory option1, string memory option2)
    //     public
    //     view
    //     returns (int256 permissionScaleBalance, int256 requirementScaleBalance)
    // {
    //     require(optionIDs.exists(keccak256(abi.encodePacked(option1))), "Option1 does not exist");
    //     require(optionIDs.exists(keccak256(abi.encodePacked(option2))), "Option2 does not exist");

    //     permissionScaleBalance = 1;
    //     requirementScaleBalance = 1;
    //     for (uint256 i = 0; i < agents.count(); i++) {
    //         uint contextId = i + 1; // contextID starts from 1
    //         // iterate through all reasons

    //         for (uint256 j = 0; j < reasons.count(); j++) { // arbitrary limit to avoid infinite loop
    //             uint readsonID = j + 1; // reasonID starts from 1
    //             bytes32 key1 = keccak256(abi.encodePacked(reasonID, option1, option2, contextId));

    //             Weight storage weight = weightingFunction[key1];

    //             permissionScaleBalance *= int256(weight.justifying + 1); // +1 to avoid multiplication by 0
    //             requirementScaleBalance *= int256(weight.requiring + 1);
    //         }
    //     }
    //     permissionScaleBalance = sgn(permissionScaleBalance - 1); // -1 to offset the initial +1
    //     requirementScaleBalance = sgn(requirementScaleBalance - 1);
    // }


    // function insertArgument(string memory metadata)
    //     public
    //     returns (uint256 argId)
    // {
    //     DirectedGraph.Graph storage graph = graphs[1];
    //     argId = graph.insertNode(metadata);

    //     SimpleSet.Set storage agentArgs = agentsArguments[
    //         msg.sender
    //     ];
    //     agentArgs.insert(bytes32(argId));
    // }

    // function supportArgument(uint256 argId) public {
    //     DirectedGraph.Graph storage graph = graphs[1];
    //     graph.incrementValue(argId);

    //     SimpleSet.Set storage agentArgs = agentsArguments[
    //         msg.sender
    //     ];
    //     agentArgs.insert(bytes32(argId));
    // }

    // function insertAttack(
    //     uint256 sourceId,
    //     uint256 targetId,
    //     string memory metadata
    // ) public returns (uint256 edgeId) {
    //     DirectedGraph.Graph storage graph = graphs[1];
    //     edgeId = graph.insertEdge(sourceId, targetId, metadata);
    // }

    // function pafReductionToAfPr1() public returns (uint256 graphId) {
    //     graphId = graphsIds.count() + 1;
    //     graphsIds.insert(bytes32(graphId));

    //     DirectedGraph.Graph storage paf = graphs[1];
    //     DirectedGraph.Graph storage af = graphs[graphId];

    //     for (uint256 j = 0; j < paf.nodesIds.count(); j++) {
    //         af.insertNodeWithId(j+1);
    //     }

    //     for (uint256 i = 0; i < paf.edgesIds.count(); i++) {
    //         uint256 edgeId = uint256(paf.edgesIds.keyAtIndex(i));
    //         DirectedGraph.Edge storage edge = paf.edges[edgeId];

    //         DirectedGraph.Node storage s = paf.nodes[edge.source];
    //         DirectedGraph.Node storage t = paf.nodes[edge.target];
    //         bool notBpreferredToA = !(t.value > s.value);
        
    //         if (notBpreferredToA) {
    //             //insert to af
    //             af.insertEdge(edge.source, edge.target, "");
    //         }

    //         // if (notBpreferredToA) { // [Vincent: all args should be ported over.
    //         //     //insert to af
    //         //     if (!af.nodesIds.exists(bytes32(edge.source))) {
    //         //         af.insertNodeWithId(edge.source);
    //         //     }
    //         //     if (!af.nodesIds.exists(bytes32(edge.target))) {
    //         //         af.insertNodeWithId(edge.target);
    //         //     }
    //         //     af.insertEdge(edge.source, edge.target, "");
    //         // }
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

    // function enumeratingPreferredExtensions(uint256 graphId)
    //     public
    //     returns (uint256[] memory args)
    // {
    //     DirectedGraph.Graph storage graph = graphs[graphId];
    //     SimpleSet.Set storage ext = prefExtensions[
    //         prefExtensionsNum
    //     ];
    //     EMap.LabelMap storage lab = labs[labsNum];
    //     for (uint256 i = 0; i < graph.nodesIds.count(); i++) {
    //         lab.set(uint256(graph.nodesIds.keyAtIndex(i)), EMap.Label.BLANK);
    //     }
    //     _findPreferredExtensions(labsNum++, prefExtensionsNum++, graphId);

    //     args = new uint256[](ext.count());
    //     for (uint256 i = 0; i < ext.count(); i++) {
    //         args[i] = uint256(ext.keyAtIndex(i));
    //     }

    //     emit Output(args);
    // }


}
