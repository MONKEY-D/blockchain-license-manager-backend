// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KeyManager {
    address public owner;

    // Key status enum for clarity
    enum Status { Inactive, Active }

    // Struct to hold key info
    struct KeyInfo {
        Status status;
        uint256 activationDate; // timestamp when activated
        uint256 expiryDate;     // timestamp of expiry
    }

    // Mapping from key hash to its info
    mapping(bytes32 => KeyInfo) private keys;

    event KeyCreated(bytes32 keyHash);
    event KeyActivated(bytes32 keyHash, uint256 activationDate);
    event KeyExpirySet(bytes32 keyHash, uint256 expiryDate);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Create a key with default inactive status and no activation/expiry dates
    function createKey(string memory key) public onlyOwner {
        bytes32 keyHash = keccak256(abi.encodePacked(key));
        require(keys[keyHash].status == Status.Inactive && keys[keyHash].activationDate == 0, "Key already exists");

        keys[keyHash] = KeyInfo({
            status: Status.Inactive,
            activationDate: 0,
            expiryDate: 0
        });

        emit KeyCreated(keyHash);
    }

    // Activate a key — sets status active and records current timestamp as activationDate
    function activateKey(string memory key) public onlyOwner {
        bytes32 keyHash = keccak256(abi.encodePacked(key));
        require(keys[keyHash].status == Status.Inactive, "Key is already active or doesn't exist");

        keys[keyHash].status = Status.Active;
        keys[keyHash].activationDate = block.timestamp;

        emit KeyActivated(keyHash, block.timestamp);
    }

    // Set expiry date for a key — timestamp passed by owner
    function setExpiryDate(string memory key, uint256 expiryTimestamp) public onlyOwner {
        bytes32 keyHash = keccak256(abi.encodePacked(key));
        require(keys[keyHash].status != Status.Inactive, "Key must be created and active before setting expiry");
        require(expiryTimestamp > block.timestamp, "Expiry must be in the future");

        keys[keyHash].expiryDate = expiryTimestamp;

        emit KeyExpirySet(keyHash, expiryTimestamp);
    }

    // View function to get key info
    function getKeyInfo(string memory key) public view returns (Status, uint256 activationDate, uint256 expiryDate) {
        bytes32 keyHash = keccak256(abi.encodePacked(key));
        KeyInfo memory info = keys[keyHash];
        return (info.status, info.activationDate, info.expiryDate);
    }
}
