// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./MarchMadness.sol";

contract MarchMadnessFactory {
    /** EVENTS **/
    event MarchMadnessCreated(address indexed proxy, uint256 year);

    /** STRUCTS AND ENUMS **/
    enum Status {
        Disabled,
        BetsOn,
        OnGoing,
        Finished
    }

    /** STATE VARIABLES **/
    address public immutable implementation;
    address public immutable gamesHub;
    address public executor;

    mapping(uint256 => address) public tournaments;

    constructor(address _implementation, address _gamesHub, address _executor) {
        implementation = _implementation;
        gamesHub = _gamesHub;
        executor = _executor;
    }

    modifier onlyExecutor() {
        require(msg.sender == executor, "MF-01");
        _;
    }

    function createMarchMadness(
        uint256 year,
        string[8] memory _firstFour,
        string[16] memory _south,
        string[16] memory _west,
        string[16] memory _midwest,
        string[16] memory _east
    ) external returns (address) {
        address clone = Clones.clone(implementation);
        MarchMadness(clone).initialize(
            year,
            _firstFour,
            _south,
            _west,
            _midwest,
            _east,
            gamesHub
        );
        emit MarchMadnessCreated(clone, year);
        tournaments[year] = clone;
        return clone;
    }

    /**
     * @dev Determines the winners of the First Four matches.
     * @param year The year of the tournament.
     * @param teamNames The array of team names for the First Four matches.
     * @param scores The array of scores for the First Four matches.
     */
    function determineFirstFourWinners(
        uint256 year,
        string[8] memory teamNames,
        uint256[8] memory scores
    ) external onlyExecutor {
        MarchMadness(tournaments[year]).determineFirstFourWinners(
            teamNames,
            scores
        );
    }

    /**
     * @dev Determines the winners of the Round 1 matches in a specific region.
     * @param year The year of the tournament.
     * @param regionName The name of the region.
     * @param teamNames The array of team names for the Round 1 matches.
     * @param scores The array of scores for the Round 1 matches.
     */
    function determineRound1Winners(
        uint256 year,
        string memory regionName,
        string[16] memory teamNames,
        uint256[16] memory scores
    ) public onlyExecutor {
        MarchMadness(tournaments[year]).determineRound1Winners(
            regionName,
            teamNames,
            scores
        );
    }

    /**
     * @dev Determines the winners of the Round 2 matches in a specific region and prepares Round 3 matches.
     * @param year The year of the tournament.
     * @param regionName The name of the region.
     * @param teamNames The array of team names for the Round 2 matches.
     * @param scores The array of scores for the Round 2 matches.
     */
    function determineRound2Winners(
        uint256 year,
        string memory regionName,
        string[8] memory teamNames,
        uint256[8] memory scores
    ) public onlyExecutor {
        MarchMadness(tournaments[year]).determineRound2Winners(
            regionName,
            teamNames,
            scores
        );
    }

    /**
     * @dev Determines the winners of the Round 3 matches in a specific region and prepares the Round 4 match.
     * @param year The year of the tournament.
     * @param regionName The name of the region.
     * @param teamNames The array of team names for the Round 3 matches.
     * @param scores The array of scores for the Round 3 matches.
     */
    function determineRound3Winners(
        uint256 year,
        string memory regionName,
        string[4] memory teamNames,
        uint256[4] memory scores
    ) public onlyExecutor {
        MarchMadness(tournaments[year]).determineRound3Winners(
            regionName,
            teamNames,
            scores
        );
    }

    /**
     * @dev Determines the winner of the Round 4 match in a specific region and prepares the team placement in the Final Four.
     * @param year The year of the tournament.
     * @param regionName The name of the region.
     * @param teamNameHome The team name for the home side of the Round 4 match.
     * @param teamNameAway The team name for the away side of the Round 4 match.
     * @param scoreHome The score for the home team in the Round 4 match.
     * @param scoreAway The score for the away team in the Round 4 match.
     */
    function determineRound4Winners(
        uint256 year,
        string memory regionName,
        string memory teamNameHome,
        string memory teamNameAway,
        uint256 scoreHome,
        uint256 scoreAway
    ) public onlyExecutor {
        MarchMadness(tournaments[year]).determineRound4Winners(
            regionName,
            teamNameHome,
            teamNameAway,
            scoreHome,
            scoreAway
        );
    }

    /**
     * @dev Determines the winners of the Final Four matches and prepares the championship match.
     * @param year The year of the tournament.
     * @param teamNamesHome Array containing the home team names for the two Final Four matches.
     * @param teamNamesAway Array containing the away team names for the two Final Four matches.
     * @param scoresHome Array containing the scores for the home teams in the two Final Four matches.
     * @param scoresAway Array containing the scores for the away teams in the two Final Four matches.
     */
    function determineFinalFourWinners(
        uint256 year,
        string[2] memory teamNamesHome,
        string[2] memory teamNamesAway,
        uint256[2] memory scoresHome,
        uint256[2] memory scoresAway
    ) public onlyExecutor {
        MarchMadness(tournaments[year]).determineFinalFourWinners(
            teamNamesHome,
            teamNamesAway,
            scoresHome,
            scoresAway
        );
    }

    /**
     * @dev Determines the winner of the championship match.
     * @param year The year of the tournament.
     * @param teamNameHome The name of the home team in the championship match.
     * @param teamNameAway The name of the away team in the championship match.
     * @param scoreHome The score of the home team in the championship match.
     * @param scoreAway The score of the away team in the championship match.
     */
    function determineChampion(
        uint256 year,
        string memory teamNameHome,
        string memory teamNameAway,
        uint256 scoreHome,
        uint256 scoreAway
    ) public onlyExecutor {
        MarchMadness(tournaments[year]).determineChampion(
            teamNameHome,
            teamNameAway,
            scoreHome,
            scoreAway
        );
    }

    /**
     * @dev Get the data for a specific region.
     * * Region Data (encoded): string[16] teams, bytes[8] matchesRound1, bytes[4] matchesRound2, bytes[2] matchesRound3, bytes matchRound4, string winner
     * * Match Data (encoded): string home, string away, uint256 home_points, uint256 away_points, string winner
     * @param year The year of the tournament.
     * @param regionName The name of the region.
     * @return The region data in bytes format.
     */
    function getRegionData(
        uint256 year,
        bytes32 regionName
    ) public view returns (bytes memory) {
        return MarchMadness(tournaments[year]).getRegionData(regionName);
    }

    /**
     * @dev Get the data for the Final Four.
     * * Final Four Data (encoded): bytes[2] matchesRound1, bytes matchFinal, string winner
     * * Match Data (encoded): string home, string away, uint256 home_points, uint256 away_points, string winner
     * @param year The year of the tournament.
     * @return The Final Four data in bytes format.
     */
    function getFinalFourData(uint256 year) public view returns (bytes memory) {
        return MarchMadness(tournaments[year]).getFinalFourData();
    }

    /**
     * @dev Get the round and game status for the current year.
     * * Game Status (encoded): uint8 currentRound, uint8 status
     * @param year The year of the tournament.
     * @return The current round and game status in bytes format.
     */
    function getGameStatus(uint256 year) public view returns (bytes memory) {
        return
            abi.encode(
                MarchMadness(tournaments[year]).currentRound(),
                MarchMadness(tournaments[year]).status()
            );
    }

    /**
     * @dev Get the team names and IDs for all the regions in a specific year.
     * * Region Data (encoded): string[16] teams, bytes[8] matchesRound1, bytes[4] matchesRound2, bytes[2] matchesRound3, bytes matchRound4, string winner
     * * Match Data (encoded): string home, string away, uint256 home_points, uint256 away_points, string winner
     * @param year The year of the tournament.
     * @return The team names IDs for all the regions in bytes format.
     */
    function getAllTeamsIdsNames(
        uint256 year
    ) public view returns (bytes[4] memory) {
        bytes[4] memory allTeams;
        allTeams[0] = MarchMadness(tournaments[year]).getRegionData(
            keccak256("SOUTH")
        );
        allTeams[1] = MarchMadness(tournaments[year]).getRegionData(
            keccak256("WEST")
        );
        allTeams[2] = MarchMadness(tournaments[year]).getRegionData(
            keccak256("MIDWEST")
        );
        allTeams[3] = MarchMadness(tournaments[year]).getRegionData(
            keccak256("EAST")
        );

        return allTeams;
    }
}