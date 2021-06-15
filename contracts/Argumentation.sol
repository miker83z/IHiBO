// SPDX-License-Identifier: MIT

pragma solidity ^0.5.1;

import "./DirectedGraph.sol";

contract Argumentation {
    using DirectedGraph for DirectedGraph.Graph;
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;

    HitchensUnorderedKeySetLib.Set graphsIds;
    mapping(uint256 => DirectedGraph.Graph) graphs;

    // Arguments Sets
    mapping(address => HitchensUnorderedKeySetLib.Set) agentsArguments;

    constructor() public {
        graphsIds.insert(bytes32(uint256(1)));
    }

    function insertArgument(string memory metadata)
        public
        returns (uint256 argId)
    {
        DirectedGraph.Graph storage graph = graphs[1];
        argId = graph.insertNode(metadata);

        HitchensUnorderedKeySetLib.Set storage agentArgs =
            agentsArguments[msg.sender];
        agentArgs.insert(bytes32(argId));
    }

    function supportArgument(uint256 argId) public {
        DirectedGraph.Graph storage graph = graphs[1];
        graph.incrementValue(argId);

        HitchensUnorderedKeySetLib.Set storage agentArgs =
            agentsArguments[msg.sender];
        agentArgs.insert(bytes32(argId));
    }

    function insertAttack(
        uint256 sourceId,
        uint256 targetId,
        string memory metadata
    ) public returns (uint256 edgeId) {
        DirectedGraph.Graph storage graph = graphs[1];
        edgeId = graph.insertEdge(sourceId, targetId, metadata);
    }

    function pafReductionToAfPr1() public returns (uint256 graphId) {
        graphId = graphsIds.count() + 1;
        graphsIds.insert(bytes32(graphId));

        DirectedGraph.Graph storage paf = graphs[1];
        DirectedGraph.Graph storage af = graphs[graphId];

        for (uint256 i = 0; i < paf.edgesIds.count(); i++) {
            uint256 edgeId = uint256(paf.edgesIds.keyAtIndex(i));
            DirectedGraph.Edge storage edge = paf.edges[edgeId];

            DirectedGraph.Node storage s = paf.nodes[edge.source];
            DirectedGraph.Node storage t = paf.nodes[edge.target];
            bool notBpreferredToA = !(t.value > s.value);

            DirectedGraph.Edge storage edgeReverse =
                paf.edges[
                    DirectedGraph.cantorPairing(edge.target, edge.source)
                ];

            if (notBpreferredToA) {
                //insert to af
                if (!af.nodesIds.exists(bytes32(edge.source))) {
                    af.insertNodeWithId(edge.source);
                }
                if (!af.nodesIds.exists(bytes32(edge.target))) {
                    af.insertNodeWithId(edge.target);
                }
                af.insertEdge(edge.source, edge.target, "");
            }
        }
    }

    function pafReductionToAfPr3() public returns (uint256 graphId) {
        graphId = graphsIds.count() + 1;
        graphsIds.insert(bytes32(graphId));

        DirectedGraph.Graph storage paf = graphs[1];
        DirectedGraph.Graph storage af = graphs[graphId];

        for (uint256 i = 0; i < paf.edgesIds.count(); i++) {
            uint256 edgeId = uint256(paf.edgesIds.keyAtIndex(i));
            DirectedGraph.Edge storage edge = paf.edges[edgeId];

            DirectedGraph.Node storage s = paf.nodes[edge.source];
            DirectedGraph.Node storage t = paf.nodes[edge.target];
            bool notBpreferredToA = !(t.value > s.value);

            DirectedGraph.Edge storage edgeReverse =
                paf.edges[
                    DirectedGraph.cantorPairing(edge.target, edge.source)
                ];
            bool notBtoA = edgeReverse.source > 0 && edgeReverse.target > 0;

            if (notBpreferredToA || notBtoA) {
                //insert to af
                if (!af.nodesIds.exists(bytes32(edge.source))) {
                    af.insertNodeWithId(edge.source);
                }
                if (!af.nodesIds.exists(bytes32(edge.target))) {
                    af.insertNodeWithId(edge.target);
                }
                af.insertEdge(edge.source, edge.target, "");
            }
        }
    }

    function getGraph(uint256 graphId)
        public
        view
        returns (
            uint256[] memory nodes,
            uint256[] memory edgesSource,
            uint256[] memory edgesTarget
        )
    {
        DirectedGraph.Graph storage graph = graphs[graphId];
        uint256 nodesCount = graph.nodesIds.count();
        uint256 edgesCount = graph.edgesIds.count();

        nodes = new uint256[](nodesCount);
        edgesSource = new uint256[](edgesCount);
        edgesTarget = new uint256[](edgesCount);

        for (uint256 i = 0; i < graph.nodesIds.count(); i++) {
            nodes[i] = uint256(graph.nodesIds.keyAtIndex(i));
        }

        for (uint256 i = 0; i < graph.edgesIds.count(); i++) {
            uint256 edgeId = uint256(graph.edgesIds.keyAtIndex(i));
            DirectedGraph.Edge storage edge = graph.edges[edgeId];
            edgesSource[i] = edge.source;
            edgesTarget[i] = edge.target;
        }
    }
}
