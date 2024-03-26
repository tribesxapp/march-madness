// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMarchMadnessFactory {
    function getGameStatus(
        uint256 _gameYear
    ) external view returns (bytes memory);

    function getFinalResult(
        uint256 _gameYear
    ) external view returns (uint256[63] memory);

    function getTeamSymbol(
        uint256 _gameYear,
        uint256 _teamId
    ) external view returns (string memory);

    function paused() external view returns (bool);
}