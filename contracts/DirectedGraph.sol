// SPDX-License-Identifier: MIT

pragma solidity ^0.5.1;

import "./HitchensUnorderedKeySet.sol";

library DirectedGraph {
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;

    struct Node {
        HitchensUnorderedKeySetLib.Set edgesIn;
        HitchensUnorderedKeySetLib.Set edgesOut;
        uint256 value;
        string metadata;
    }

    struct Edge {
        uint256 source;
        uint256 target;
        string metadata;
    }

    struct Graph {
        HitchensUnorderedKeySetLib.Set nodesIds;
        mapping(uint256 => Node) nodes;
        HitchensUnorderedKeySetLib.Set edgesIds;
        mapping(uint256 => Edge) edges;
    }

    function insertNode(Graph storage g, string memory metadata)
        internal
        returns (uint256 nodeId)
    {
        nodeId = g.nodesIds.count() + 1;

        g.nodesIds.insert(bytes32(nodeId));

        Node storage arg = g.nodes[nodeId];
        arg.metadata = metadata;
        arg.value++;
    }
											// Node added and checked that another node with the same id is not in the graph yet the content is however not regarded. If the argument expresses 												the same idea ^^ then the argument should already be considered part of the graph.
    function insertNodeWithId(Graph storage g, uint256 nodeId) internal {
        require(!g.nodesIds.exists(bytes32(nodeId)), "Node already exists.");
        g.nodesIds.insert(bytes32(nodeId));
    }

    function incrementValue(Graph storage g, uint256 nodeId) internal {
        require(g.nodesIds.exists(bytes32(nodeId)), "Unknown nodeId.");

        Node storage arg = g.nodes[nodeId];
        arg.value++;
    }

    function insertEdge(
        Graph storage g,
        uint256 sourceId,
        uint256 targetId,
        string memory metadata
    ) internal returns (uint256 edgeId) {
        require(g.nodesIds.exists(bytes32(sourceId)), "Unknown sourceId.");
        require(g.nodesIds.exists(bytes32(targetId)), "Unknown targetId.");

        edgeId = cantorPairing(sourceId, targetId);

        g.edgesIds.insert(bytes32(edgeId));

        Edge storage edge = g.edges[edgeId];
        edge.metadata = metadata;
        edge.source = sourceId;
        edge.target = targetId;

        Node storage s = g.nodes[sourceId];
        Node storage t = g.nodes[targetId];
        s.edgesOut.insert(bytes32(edgeId));
        t.edgesIn.insert(bytes32(edgeId));
    }

    // works only for a and b between 0 to 2^16 -1, TODO
    function cantorPairing(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return ((a + b) * (a + b + 1)) / 2 + a;
    }
}
