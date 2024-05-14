// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IDripCheck } from "../IDripCheck.sol";

/// @title CheckSecrets
/// @notice DripCheck that checks if specific secrets exist (or not). Supports having a secret that
///         must exist for the check to pass as well as a second secret that must not exist. First
///         secret can be revealed to begin the drip, second secret can be revealed to stop it.
contract CheckSecrets is IDripCheck {
    struct Params {
        uint256 delay;
        bytes32 secretMustExist;
        bytes32 secretMustNotExist;
    }

    /// @notice External event used to help client-side tooling encode parameters.
    /// @param params Parameters to encode.
    event _EventToExposeStructInABI__Params(Params params);

    /// @notice Event emitted when a secret is revealed.
    event SecretRevealed(bytes32 secret);

    /// @notice Keeps track of when secrets were revealed.
    mapping(bytes32 => uint256) public revealedSecrets;

    /// @inheritdoc IDripCheck
    function check(bytes memory _params) external view returns (bool execute_) {
        Params memory params = abi.decode(_params, (Params));

        // Check that the secrets have/have not been revealed.
        execute_ = (
            revealedSecrets[params.secretMustExist] > 0
                && block.timestamp >= revealedSecrets[params.secretMustExist] + params.delay
                && revealedSecrets[params.secretMustNotExist] == 0
        );
    }

    /// @notice Reveal a secret.
    /// @param _secret Secret to reveal.
    function reveal(bytes memory _secret) external {
        bytes32 secret = keccak256(_secret);
        require(revealedSecrets[secret] == 0, "CheckSecrets: secret already revealed");
        revealedSecrets[secret] = block.timestamp;
        emit SecretRevealed(secret);
    }
}
