// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @title SimpleSet - A minimal bytes32 set library with insert, remove, and enumeration
library SimpleSet {
    struct Set {
        mapping(bytes32 => uint256) index; // key => index in values[]
        bytes32[] values;
    }

    /// @notice Inserts a new key into the set
    /// @dev Reverts if key already exists or is 0x0
    function insert(Set storage self, bytes32 key) internal {
        require(key != bytes32(0), "SimpleSet: key cannot be 0x0");
        require(!exists(self, key), "SimpleSet: key already exists");

        self.index[key] = self.values.length;
        self.values.push(key);
    }

    /// @notice Removes a key from the set
    /// @dev Reverts if key doesn't exist
    function remove(Set storage self, bytes32 key) internal {
        require(exists(self, key), "SimpleSet: key does not exist");

        uint256 idxToRemove = self.index[key];
        uint256 lastIdx = self.values.length - 1;
        bytes32 lastKey = self.values[lastIdx];

        // Swap the last key with the one to remove
        self.values[idxToRemove] = lastKey;
        self.index[lastKey] = idxToRemove;

        // Remove last
        self.values.pop();
        delete self.index[key];
    }

    /// @notice Returns true if the key exists
    function exists(Set storage self, bytes32 key) internal view returns (bool) {
        if (self.values.length == 0) return false;
        uint256 i = self.index[key];
        return i < self.values.length && self.values[i] == key;
    }

    /// @notice Returns number of keys in the set
    function count(Set storage self) internal view returns (uint256) {
        return self.values.length;
    }

    /// @notice Returns the key at the given index
    /// @dev Reverts if index is out of bounds
    function keyAtIndex(Set storage self, uint256 i) internal view returns (bytes32) {
        require(i < self.values.length, "SimpleSet: index out of bounds");
        return self.values[i];
    }

    /// @notice Clears the entire set
    function clear(Set storage self) internal {
        delete self.values;
    }
}

