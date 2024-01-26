// SPDX-License-Identifier: MIT

pragma solidity ^0.5.1;

import "./DirectedGraph.sol";
import "./EnumerableMap.sol";

contract Argumentation {
    using DirectedGraph for DirectedGraph.Graph;
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;
    using EMap for EMap.LabelMap;

    HitchensUnorderedKeySetLib.Set graphsIds;
    mapping(uint256 => DirectedGraph.Graph) graphs;

    // Arguments Sets
    mapping(address => HitchensUnorderedKeySetLib.Set) agentsArguments;

    uint256 labsNum;
    mapping(uint256 => EMap.LabelMap) labs;
    uint256 prefExtensionsNum;
    mapping(uint256 => HitchensUnorderedKeySetLib.Set) prefExtensions;

    event PreferredExtensions(uint256[] args);

    constructor() public {
        graphsIds.insert(bytes32(uint256(1)));
    }

    function insertArgument(string memory metadata)
        public
        returns (uint256 argId)
    {
        DirectedGraph.Graph storage graph = graphs[1];
        argId = graph.insertNode(metadata);

        HitchensUnorderedKeySetLib.Set storage agentArgs = agentsArguments[
            msg.sender
        ];
        agentArgs.insert(bytes32(argId));
    }

    function supportArgument(uint256 argId) public {
        DirectedGraph.Graph storage graph = graphs[1];
        graph.incrementValue(argId);

        HitchensUnorderedKeySetLib.Set storage agentArgs = agentsArguments[
            msg.sender
        ];
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

            // [Vincent: i.e. Like this]
            // if (!af.nodesIds.exists(bytes32(edge.source))) {
            //     af.insertNodeWithId(edge.source);
            // }
            // if (!af.nodesIds.exists(bytes32(edge.target))) {
            //     af.insertNodeWithId(edge.target);
            // }
            if (notBpreferredToA) { // [Vincent: node should be considered to be added regardless of this if]
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

            DirectedGraph.Edge storage edgeReverse = paf.edges[
                DirectedGraph.cantorPairing(edge.target, edge.source)
            ];
            bool notBtoA = edgeReverse.source > 0 && edgeReverse.target > 0;

            // [Vincent: i.e. like this]
            // if (!af.nodesIds.exists(bytes32(edge.source))) {
            //     af.insertNodeWithId(edge.source);
            // }
            // if (!af.nodesIds.exists(bytes32(edge.target))) {
            //     af.insertNodeWithId(edge.target);
            if (notBpreferredToA || notBtoA) { // [Vincent: node should be considered to be added regardless of this if]
                // insert to af
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

    function enumeratingPreferredExtensions(uint256 graphId)
        public
        returns (uint256[] memory args)
    {
        DirectedGraph.Graph storage graph = graphs[graphId];
        HitchensUnorderedKeySetLib.Set storage ext = prefExtensions[
            prefExtensionsNum
        ];
        EMap.LabelMap storage lab = labs[labsNum];
        for (uint256 i = 0; i < graph.nodesIds.count(); i++) {
            lab.set(uint256(graph.nodesIds.keyAtIndex(i)), EMap.Label.BLANK);
        }
        _findPreferredExtensions(labsNum++, prefExtensionsNum++, graphId);

        args = new uint256[](ext.count());
        for (uint256 i = 0; i < ext.count(); i++) {
            args[i] = uint256(ext.keyAtIndex(i));
        }

        emit PreferredExtensions(args);
    }

    function _findPreferredExtensions(
        uint256 labId,
        uint256 prefExtensionId,
        uint256 graphId
    ) private {
        DirectedGraph.Graph storage graph = graphs[graphId];
        EMap.LabelMap storage lab = labs[labId];
        bool[] memory flags = new bool[](5);

        // while ∃y ∈ A : Lab(y) = BLANK do
        while (!flags[0]) {
            (uint256[] memory argIds, uint256 argIdsLen) = _getBlank(labId);
            if (argIdsLen <= 0) {
                flags[0] = true;
            } else {
                uint256 y = 0;
                // select y with Lab(y) = BLANK and ∀z ∈ {y}− Lab(z) ∈ {OUT, MUST_OUT}
                flags[1] = false;
                for (uint256 i = 0; i < argIdsLen && !flags[1]; i++) {
                    y = argIds[i];
                    DirectedGraph.Node storage y_temp = graph.nodes[y];
                    flags[2] = false;
                    for (
                        uint256 j = 0;
                        j < y_temp.edgesIn.count() && !flags[2];
                        j++
                    ) {
                        DirectedGraph.Edge storage edge = graph.edges[
                            uint256(y_temp.edgesIn.keyAtIndex(j))
                        ];
                        if (
                            lab.get(edge.source) != EMap.Label.OUT &&
                            lab.get(edge.source) != EMap.Label.MUST_OUT
                        ) {
                            flags[2] = true;
                        }
                    }
                    flags[1] = !flags[2];
                }

                // otherwise select y with Lab(y) = BLANK s.t. ∀z ∈ A : Lab(z) = BLANK,
                //|{x : x ∈ {y}+ ∧ Lab(x)!= OUT }| ≥ |{x : x ∈ {z}+ ∧ Lab(x) != OUT }|;
                if (!flags[1]) {
                    uint256 max = 0;
                    for (uint256 i = 0; i < argIdsLen; i++) {
                        DirectedGraph.Node storage y_temp = graph.nodes[
                            argIds[i]
                        ];
                        uint256 y_temp_num = 0;
                        for (uint256 j = 0; j < y_temp.edgesOut.count(); j++) {
                            DirectedGraph.Edge storage edge = graph.edges[
                                uint256(y_temp.edgesOut.keyAtIndex(j))
                            ];
                            if (lab.get(edge.target) != EMap.Label.OUT) {
                                y_temp_num++;
                            }
                        }
                        if (y_temp_num > max) {
                            max = y_temp_num;
                            y = argIds[i];
                        }
                    }
                }
                // Lab′ ← Lab;
                uint256 lab1Id = labsNum++;
                EMap.LabelMap storage lab1 = labs[lab1Id];
                for (uint256 i = 0; i < lab.length(); i++) {
                    (uint256 arg, EMap.Label argLabel) = lab.at(i);
                    lab1.set(arg, argLabel);
                }
                // Lab′ (y) ← IN;
                lab1.set(y, EMap.Label.IN);
                // foreach z ∈ {y}+ do Lab′(z) ← OUT ;
                DirectedGraph.Node storage y_node = graph.nodes[y];
                for (uint256 j = 0; j < y_node.edgesOut.count(); j++) {
                    DirectedGraph.Edge storage edge = graph.edges[
                        uint256(y_node.edgesOut.keyAtIndex(j))
                    ];
                    lab1.set(edge.target, EMap.Label.OUT);
                }
                // foreach z ∈ {y}− do
                flags[3] = false;
                for (
                    uint256 j = 0;
                    j < y_node.edgesIn.count() && !flags[3];
                    j++
                ) {
                    DirectedGraph.Edge storage edge = graph.edges[
                        uint256(y_node.edgesIn.keyAtIndex(j))
                    ];
                    // if Lab′ (z) ∈ {UNDEC, BLANK} then Lab′ (z) ← MUST OUT ;
                    if (
                        lab1.get(edge.source) == EMap.Label.UNDEC ||
                        lab1.get(edge.source) == EMap.Label.BLANK
                    ) {
                        lab1.set(edge.source, EMap.Label.MUST_OUT);
                        // if !∃w ∈ {z}− : Lab′ (w) = BLANK then Lab(y) ← UNDEC;
                        DirectedGraph.Node storage z_node = graph.nodes[
                            edge.source
                        ];
                        flags[3] = true;
                        for (
                            uint256 k = 0;
                            k < z_node.edgesIn.count() && flags[3];
                            k++
                        ) {
                            DirectedGraph.Edge storage edgeZ = graph.edges[
                                uint256(z_node.edgesIn.keyAtIndex(k))
                            ];
                            if (lab1.get(edgeZ.source) == EMap.Label.BLANK) {
                                flags[3] = false;
                            }
                        }
                        if (flags[3]) {
                            lab.set(y, EMap.Label.UNDEC);
                            // goto line 7;
                        }
                    }
                }
                if (!flags[3]) {
                    // call find-preferred-extensions(Lab′ );
                    _findPreferredExtensions(lab1Id, prefExtensionId, graphId);
                    //if ∃z ∈ {y}− : Lab(z) ∈ {BLANK,UNDEC} then Lab(y) ← UNDEC;
                    flags[4] = false;
                    for (
                        uint256 j = 0;
                        j < y_node.edgesIn.count() && !flags[4];
                        j++
                    ) {
                        DirectedGraph.Edge storage edge = graph.edges[
                            uint256(y_node.edgesIn.keyAtIndex(j))
                        ];
                        // if Lab′ (z) ∈ {UNDEC, BLANK} then Lab′ (z) ← MUST OUT ;
                        if (
                            lab.get(edge.source) == EMap.Label.UNDEC ||
                            lab.get(edge.source) == EMap.Label.BLANK
                        ) {
                            lab.set(y, EMap.Label.MUST_OUT);
                            flags[4] = true;
                        }
                    }
                    // else Lab ← Lab′ ;
                    if (!flags[4]) {
                        lab = labs[lab1Id];
                        labId = lab1Id;
                    }
                }
            }
        }
        // if  !∃x : Lab(x) = MUST OUT then
        (, uint256 argMustOutIdsLen) = _getMustOut(labId);
        if (argMustOutIdsLen <= 0) {
            // S ← {x | Lab(x) = IN};
            (uint256[] memory argInIds, uint256 argINIdsLen) = _getIn(labId);
            // if !∃T ∈ Epreferred : S ⊆ T then Epreferred ← Epreferred ∪ {S};
            HitchensUnorderedKeySetLib.Set storage ext = prefExtensions[
                prefExtensionId
            ];
            for (uint256 i = 0; i < argINIdsLen; i++) {
                if (!ext.exists(bytes32(argInIds[i]))) {
                    ext.insert(bytes32(argInIds[i]));
                }
            }
        }
    }

    function _getBlank(uint256 labId)
        private
        view
        returns (uint256[] memory argIdsTemp, uint256 argIdsLenTemp)
    {
        EMap.LabelMap storage lab = labs[labId];
        argIdsTemp = new uint256[](lab.length());
        argIdsLenTemp = 0;
        for (uint256 i = 0; i < argIdsTemp.length; i++) {
            (uint256 arg, EMap.Label argLabel) = lab.at(i);
            if (argLabel == EMap.Label.BLANK) {
                argIdsTemp[argIdsLenTemp++] = arg;
            }
        }
    }

    function _getMustOut(uint256 labId)
        private
        view
        returns (uint256[] memory argIdsTemp, uint256 argIdsLenTemp)
    {
        EMap.LabelMap storage lab = labs[labId];
        argIdsTemp = new uint256[](lab.length());
        argIdsLenTemp = 0;
        for (uint256 i = 0; i < argIdsTemp.length; i++) {
            (uint256 arg, EMap.Label argLabel) = lab.at(i);
            if (argLabel == EMap.Label.MUST_OUT) {
                argIdsTemp[argIdsLenTemp++] = arg;
            }
        }
    }

    function _getIn(uint256 labId)
        private
        view
        returns (uint256[] memory argIdsTemp, uint256 argIdsLenTemp)
    {
        EMap.LabelMap storage lab = labs[labId];
        argIdsTemp = new uint256[](lab.length());
        argIdsLenTemp = 0;
        for (uint256 i = 0; i < argIdsTemp.length; i++) {
            (uint256 arg, EMap.Label argLabel) = lab.at(i);
            if (argLabel == EMap.Label.IN) {
                argIdsTemp[argIdsLenTemp++] = arg;
            }
        }
    }
}
