// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MarchMadness {
    /** CONSTANTS **/
    bytes32 public constant SOUTH = keccak256("SOUTH");
    bytes32 public constant WEST = keccak256("WEST");
    bytes32 public constant MIDWEST = keccak256("MIDWEST");
    bytes32 public constant EAST = keccak256("EAST");
    bytes32[4] private matchCodes;

    /** STRUCTS AND ENUMS **/
    enum Status {
        Disabled,
        BetsOn,
        OnGoing,
        Finished
    }

    struct Match {
        uint8 home;
        uint8 away;
        uint256 home_points;
        uint256 away_points;
        uint8 winner;
    }

    struct Region {
        uint8[16] teams;
        uint8[8] matchesRound1;
        uint8[4] matchesRound2;
        uint8[2] matchesRound3;
        uint8 matchRound4;
        uint8 winner;
    }

    struct FinalFour {
        uint8[2] matchesRound1;
        uint8 matchFinal;
        uint8 winner;
    }

    /** STATE VARIABLES **/
    mapping(bytes32 => Region) private regions;
    mapping(uint8 => Match) private matches;
    mapping(uint8 => bytes) private teams;
    mapping(bytes => uint8) private teamToId;
    mapping(bytes32 => uint8) private firstFourMatches;

    uint256 public year;
    uint8 public currentRound;
    uint8 public playersActualIndex;
    uint8 public matchesActualIndex;

    Status public status;
    FinalFour private finalFour;
    address public gameContract;

    /** MODIFIERS **/
    modifier onlyGameContract() {
        require(msg.sender == gameContract, "MM-01");
        _;
    }

    /**
     * @dev Initializes the MarchMadness contract.
     * @param _year The year of the March Madness tournament.
     * @param _south The array of team names for the South region.
     * @param _west The array of team names for the West region.
     * @param _midwest The array of team names for the Midwest region.
     * @param _east The array of team names for the East region.
     * @param _gameContract The address of the GamesHub contract.
     */
    function initialize(
        uint256 _year,
        string[8] memory _firstFour,
        string[16] memory _south,
        string[16] memory _west,
        string[16] memory _midwest,
        string[16] memory _east,
        address _gameContract
    ) external {
        year = _year;
        gameContract = _gameContract;

        matchCodes = [
            keccak256("FFG1"),
            keccak256("FFG2"),
            keccak256("FFG3"),
            keccak256("FFG4")
        ];

        playersActualIndex = 1;
        matchesActualIndex = 1;

        // Inicializar First Four
        for (uint8 i = 0; i < 4; i++) {
            _initFirstFour(
                matchCodes[i],
                _firstFour[i * 2],
                _firstFour[i * 2 + 1]
            );
        }

        // Inicializar regiões com times
        _initRegion(SOUTH, _south);
        _initRegion(WEST, _west);
        _initRegion(MIDWEST, _midwest);
        _initRegion(EAST, _east);

        status = Status.BetsOn;
    }

    function _initFirstFour(
        bytes32 matchCode,
        string memory _home,
        string memory _away
    ) internal {
        require(bytes(_home).length > 0 && bytes(_away).length > 0, "MM-02");
        bytes memory teamHomeHash = abi.encodePacked(_home);
        bytes memory teamAwayHash = abi.encodePacked(_away);

        uint8 newId = playersActualIndex;
        teams[newId] = teamHomeHash;
        teamToId[teamHomeHash] = newId;
        matches[matchesActualIndex].home = newId;
        newId++;

        teams[newId] = teamAwayHash;
        teamToId[teamAwayHash] = newId;
        matches[matchesActualIndex].away = newId;

        firstFourMatches[matchCode] = matchesActualIndex;
        matchesActualIndex++;

        playersActualIndex = newId;
    }

    /**
     * @dev Initializes a region with teams and matches.
     * @param regionName The name of the region.
     * @param teamNames The array of team names for the region.
     */
    function _initRegion(
        bytes32 regionName,
        string[16] memory teamNames
    ) private {
        uint8[16] memory teamIds;
        uint8[8] memory matchIds;
        uint8 matchIndex = 0;

        for (uint8 i = 0; i < 16; i++) {
            require(bytes(teamNames[i]).length > 0, "MM-02");
            bytes memory teamHash = abi.encodePacked(teamNames[i]);
            if (teamToId[teamHash] == 0) {
                uint8 newId = playersActualIndex;
                teams[newId] = teamHash;
                teamToId[teamHash] = newId;
                teamIds[i] = newId;
                playersActualIndex++;
            } else {
                teamIds[i] = teamToId[teamHash];
            }

            if (i % 2 == 1) {
                matches[matchesActualIndex].home = teamIds[i - 1];
                matches[matchesActualIndex].away = teamIds[i];
                matchIds[matchIndex] = matchesActualIndex;
                matchIndex++;
                matchesActualIndex++;
            }
        }

        regions[regionName].teams = teamIds;
        regions[regionName].matchesRound1 = matchIds;
    }

    /**
     * @dev Determines the winners of the First Four matches.
     * @param teamNames The array of team names for the First Four matches.
     * @param scores The array of scores for the First Four matches.
     */
    function determineFirstFourWinners(
        string[8] memory teamNames,
        uint256[8] memory scores
    ) external {
        // onlyGameContract {
        for (uint8 i = 0; i < 8; i += 2) {
            Match storage currentMatch = matches[
                firstFourMatches[matchCodes[i / 2]]
            ];
            require(
                currentMatch.home == teamToId[abi.encodePacked(teamNames[i])],
                "MM-03"
            );
            require(
                currentMatch.away ==
                    teamToId[abi.encodePacked(teamNames[i + 1])],
                "MM-04"
            );

            if (scores[i] == 0 && scores[i + 1] == 0) {
                continue;
            }

            currentMatch.winner = scores[i] > scores[i + 1]
                ? currentMatch.home
                : currentMatch.away;

            currentMatch.home_points = scores[i];
            currentMatch.away_points = scores[i + 1];
        }
    }

    /**
     * @dev Closes the bets for the tournament.
     */
    function closeBets() external {
        // onlyGameContract {
        require(status == Status.BetsOn, "MM-05");
        currentRound = 1;
        status = Status.OnGoing;
    }

    /**
     * @dev Advances the round to the next one.
     */
    function advanceRound() external {
        // onlyGameContract {
        require(currentRound < 6, "MM-05");
        currentRound++;
    }

    /**
     * @dev Determines the winners of the Round 1 matches in a specific region.
     * @param regionName The name of the region.
     * @param teamNames The array of team names for the Round 1 matches.
     * @param scores The array of scores for the Round 1 matches.
     */
    function determineRound1Winners(
        string memory regionName,
        string[16] memory teamNames,
        uint256[16] memory scores
    ) external {
        // onlyGameContract {
        require(currentRound == 1, "MM-05");

        bytes32 regionHash = keccak256(abi.encodePacked(regionName));
        Region storage region = regions[regionHash];

        uint8[8] memory winnersRound2;
        uint8 winnersIndex = 0;

        for (uint8 i = 0; i < 16; i += 2) {
            uint8 matchId = region.matchesRound1[i / 2];
            Match storage currentMatch = matches[matchId];
            require(
                currentMatch.home == teamToId[abi.encodePacked(teamNames[i])],
                "MM-03"
            );
            require(
                currentMatch.away ==
                    teamToId[abi.encodePacked(teamNames[i + 1])],
                "MM-04"
            );

            if (scores[i] == 0 && scores[i + 1] == 0) {
                continue;
            }

            currentMatch.winner = scores[i] > scores[i + 1]
                ? currentMatch.home
                : currentMatch.away;

            currentMatch.home_points = scores[i];
            currentMatch.away_points = scores[i + 1];

            if (i % 4 == 0 || i % 4 == 2) {
                winnersRound2[winnersIndex] = currentMatch.winner;
                winnersIndex++;
            }

            if (i % 4 == 2) {
                matches[matchesActualIndex].home = winnersRound2[
                    winnersIndex - 2
                ];
                matches[matchesActualIndex].away = winnersRound2[
                    winnersIndex - 1
                ];

                region.matchesRound2[(i / 4)] = matchesActualIndex;
                matchesActualIndex++;
            }
        }
    }

    /**
     * @dev Determines the winners of the Round 2 matches in a specific region and prepares Round 3 matches.
     * @param regionName The name of the region.
     * @param teamNames The array of team names for the Round 2 matches.
     * @param scores The array of scores for the Round 2 matches.
     */
    function determineRound2Winners(
        string memory regionName,
        string[8] memory teamNames,
        uint256[8] memory scores
    ) external {
        // onlyGameContract {
        require(currentRound == 2, "MM-05");

        bytes32 regionHash = keccak256(abi.encodePacked(regionName));
        Region storage region = regions[regionHash];

        uint8[4] memory winnersRound3;
        uint8 winnersIndex = 0;

        for (uint8 i = 0; i < 8; i += 2) {
            uint8 matchId = region.matchesRound2[i / 2];
            Match storage currentMatch = matches[matchId];

            if (scores[i] == 0 && scores[i + 1] == 0) {
                continue;
            }

            uint8 homeId = teamToId[abi.encodePacked(teamNames[i])];
            uint8 awayId = teamToId[abi.encodePacked(teamNames[i + 1])];
            uint256 score_home = scores[i];
            uint256 score_away = scores[i + 1];

            if (currentMatch.home == awayId && currentMatch.away == homeId) {
                homeId = teamToId[abi.encodePacked(teamNames[i + 1])];
                awayId = teamToId[abi.encodePacked(teamNames[i])];
                score_home = scores[i + 1];
                score_away = scores[i];

                currentMatch.home = homeId;
                currentMatch.away = awayId;
            } else {
                require(currentMatch.home == homeId, "MM-03");
                require(currentMatch.away == awayId, "MM-04");
            }

            currentMatch.home_points = score_home;
            currentMatch.away_points = score_away;

            currentMatch.winner = score_home > score_away ? homeId : awayId;

            if (i % 2 == 0) {
                winnersRound3[winnersIndex] = currentMatch.winner;
                winnersIndex++;
            }
        }

        matches[matchesActualIndex].home = winnersRound3[0];
        matches[matchesActualIndex].away = winnersRound3[1];

        region.matchesRound3[0] = matchesActualIndex;
        matchesActualIndex++;

        matches[matchesActualIndex].home = winnersRound3[2];
        matches[matchesActualIndex].away = winnersRound3[3];

        region.matchesRound3[1] = matchesActualIndex;
        matchesActualIndex++;
    }

    /**
     * @dev Determines the winners of the Round 3 matches in a specific region and prepares the Round 4 match.
     * @param regionName The name of the region.
     * @param teamNames The array of team names for the Round 3 matches.
     * @param scores The array of scores for the Round 3 matches.
     */
    function determineRound3Winners(
        string memory regionName,
        string[4] memory teamNames,
        uint256[4] memory scores
    ) external {
        // onlyGameContract {
        require(currentRound == 3, "MM-05");

        bytes32 regionHash = keccak256(abi.encodePacked(regionName));
        Region storage region = regions[regionHash];

        uint8[2] memory winnersRound4;
        uint8 winnersIndex = 0;

        for (uint8 i = 0; i < 4; i += 2) {
            uint8 matchId = region.matchesRound3[i / 2];
            Match storage currentMatch = matches[matchId];

            uint8 homeId = teamToId[abi.encodePacked(teamNames[i])];
            uint8 awayId = teamToId[abi.encodePacked(teamNames[i + 1])];
            uint256 score_home = scores[i];
            uint256 score_away = scores[i + 1];

            if (currentMatch.home == awayId && currentMatch.away == homeId) {
                currentMatch.home = homeId;
                currentMatch.away = awayId;
                currentMatch.home_points = score_away;
                currentMatch.away_points = score_home;
            } else {
                require(currentMatch.home == homeId, "MM-03");
                require(currentMatch.away == awayId, "MM-04");
                currentMatch.home_points = score_home;
                currentMatch.away_points = score_away;
            }

            currentMatch.winner = currentMatch.home_points >
                currentMatch.away_points
                ? currentMatch.home
                : currentMatch.away;

            winnersRound4[winnersIndex] = currentMatch.winner;
            winnersIndex++;
        }

        matches[matchesActualIndex].home = winnersRound4[0];
        matches[matchesActualIndex].away = winnersRound4[1];

        region.matchRound4 = matchesActualIndex;
        matchesActualIndex++;
    }

    /**
     * @dev Determines the winner of the Round 4 match in a specific region and prepares the team placement in the Final Four.
     * @param regionName The name of the region.
     * @param teamNameHome The team name for the home side of the Round 4 match.
     * @param teamNameAway The team name for the away side of the Round 4 match.
     * @param scoreHome The score for the home team in the Round 4 match.
     * @param scoreAway The score for the away team in the Round 4 match.
     */
    function determineRound4Winners(
        string memory regionName,
        string memory teamNameHome,
        string memory teamNameAway,
        uint256 scoreHome,
        uint256 scoreAway
    ) external {
        // onlyGameContract {
        require(currentRound == 4, "MM-05");

        bytes32 regionHash = keccak256(abi.encodePacked(regionName));
        Region storage region = regions[regionHash];
        Match storage currentMatch = matches[region.matchRound4];

        uint8 homeId = teamToId[abi.encodePacked(teamNameHome)];
        uint8 awayId = teamToId[abi.encodePacked(teamNameAway)];

        if (currentMatch.home == awayId && currentMatch.away == homeId) {
            currentMatch.home = homeId;
            currentMatch.away = awayId;
            currentMatch.home_points = scoreAway;
            currentMatch.away_points = scoreHome;
        } else {
            require(currentMatch.home == homeId, "MM-03");
            require(currentMatch.away == awayId, "MM-04");
            currentMatch.home_points = scoreHome;
            currentMatch.away_points = scoreAway;
        }

        currentMatch.winner = currentMatch.home_points >
            currentMatch.away_points
            ? currentMatch.home
            : currentMatch.away;

        uint8 roundMatchId;
        if (regionHash == SOUTH) {
            if (finalFour.matchesRound1[0] == 0) {
                matchesActualIndex++;
                finalFour.matchesRound1[0] = matchesActualIndex;
                roundMatchId = matchesActualIndex;
            } else {
                roundMatchId = finalFour.matchesRound1[0];
            }
            matches[roundMatchId].home = currentMatch.winner;
        } else if (regionHash == EAST) {
            if (finalFour.matchesRound1[0] == 0) {
                matchesActualIndex++;
                finalFour.matchesRound1[0] = matchesActualIndex;
                roundMatchId = matchesActualIndex;
            } else {
                roundMatchId = finalFour.matchesRound1[0];
            }
            matches[roundMatchId].away = currentMatch.winner;
        } else if (regionHash == MIDWEST) {
            if (finalFour.matchesRound1[1] == 0) {
                matchesActualIndex++;
                finalFour.matchesRound1[1] = matchesActualIndex;
                roundMatchId = matchesActualIndex;
            } else {
                roundMatchId = finalFour.matchesRound1[1];
            }
            matches[roundMatchId].home = currentMatch.winner;
        } else if (regionHash == WEST) {
            if (finalFour.matchesRound1[1] == 0) {
                matchesActualIndex++;
                finalFour.matchesRound1[1] = matchesActualIndex;
                roundMatchId = matchesActualIndex;
            } else {
                roundMatchId = finalFour.matchesRound1[1];
            }
            matches[roundMatchId].away = currentMatch.winner;
        }
    }

    /**
     * @dev Determines the winners of the Final Four matches and prepares the championship match.
     * @param teamNamesHome Array containing the home team names for the two Final Four matches.
     * @param teamNamesAway Array containing the away team names for the two Final Four matches.
     * @param scoresHome Array containing the scores for the home teams in the two Final Four matches.
     * @param scoresAway Array containing the scores for the away teams in the two Final Four matches.
     */
    function determineFinalFourWinners(
        string[2] memory teamNamesHome,
        string[2] memory teamNamesAway,
        uint256[2] memory scoresHome,
        uint256[2] memory scoresAway
    ) external {
        // onlyGameContract {
        require(currentRound == 5, "MM-05");

        uint8[2] memory winners;
        for (uint8 i = 0; i < 2; i++) {
            Match storage currentMatch = matches[finalFour.matchesRound1[i]];

            require(
                currentMatch.home ==
                    teamToId[abi.encodePacked(teamNamesHome[i])],
                "MM-03"
            );
            require(
                currentMatch.away ==
                    teamToId[abi.encodePacked(teamNamesAway[i])],
                "MM-04"
            );

            if (scoresHome[i] == 0 && scoresAway[i] == 0) {
                revert("MM-06");
            }

            uint8 winnerId = scoresHome[i] > scoresAway[i]
                ? currentMatch.home
                : currentMatch.away;

            currentMatch.home_points = scoresHome[i];
            currentMatch.away_points = scoresAway[i];

            currentMatch.winner = winnerId;
            winners[i] = winnerId;
        }

        // Create the championship match with the winners of the Final Four
        matches[matchesActualIndex++].home = winners[0];
        matches[matchesActualIndex++].away = winners[1];
        finalFour.matchFinal = matchesActualIndex - 1;

        currentRound++;
    }

    /**
     * @dev Determines the winner of the championship match.
     * @param teamNameHome The name of the home team in the championship match.
     * @param teamNameAway The name of the away team in the championship match.
     * @param scoreHome The score of the home team in the championship match.
     * @param scoreAway The score of the away team in the championship match.
     */
    function determineChampion(
        string memory teamNameHome,
        string memory teamNameAway,
        uint256 scoreHome,
        uint256 scoreAway
    ) external {
        // onlyGameContract {
        require(currentRound == 6, "MM-05");

        Match storage currentMatch = matches[finalFour.matchFinal];

        require(
            currentMatch.home == teamToId[abi.encodePacked(teamNameHome)],
            "MM-03"
        );

        require(
            currentMatch.away == teamToId[abi.encodePacked(teamNameAway)],
            "MM-04"
        );

        if (scoreHome == 0 && scoreAway == 0) {
            revert("MM-06");
        }

        uint8 winnerId = scoreHome > scoreAway
            ? currentMatch.home
            : currentMatch.away;

        currentMatch.home_points = scoreHome;
        currentMatch.away_points = scoreAway;

        currentMatch.winner = winnerId;
        finalFour.winner = winnerId;

        status = Status.Finished;
    }

    /**
     * @dev Get the match data for a specific match.
     * @param matchId The ID of the match.
     * @return The match data in bytes format.
     */
    function getMatchData(uint8 matchId) internal view returns (bytes memory) {
        //string home, string away, uint256 home_points, uint256 away_points, string winner
        return
            abi.encode(
                teams[matches[matchId].home],
                teams[matches[matchId].away],
                matches[matchId].home_points,
                matches[matchId].away_points,
                teams[matches[matchId].winner]
            );
    }

    /**
     * @dev Get the data for a specific region.
     * @param regionName The name of the region.
     * @return The region data in bytes format.
     */
    function getRegionData(
        bytes32 regionName
    ) external view returns (bytes memory) {
        bytes[8] memory matchesRound1;
        Region storage region = regions[regionName];

        for (uint8 i = 0; i < 8; i++) {
            matchesRound1[i] = getMatchData(region.matchesRound1[i]);
        }

        bytes[4] memory matchesRound2;
        for (uint8 i = 0; i < 4; i++) {
            matchesRound2[i] = getMatchData(region.matchesRound2[i]);
        }

        bytes[2] memory matchesRound3;
        for (uint8 i = 0; i < 2; i++) {
            matchesRound3[i] = getMatchData(region.matchesRound3[i]);
        }

        bytes memory matchRound4 = getMatchData(region.matchRound4);

        string[16] memory _teams;
        for (uint8 i = 0; i < 16; i++) {
            _teams[i] = string(teams[region.teams[i]]);
        }

        // string[16] teams, bytes[8] matchesRound1, bytes[4] matchesRound2, bytes[2] matchesRound3, bytes matchRound4, string winner
        return
            abi.encode(
                _teams,
                matchesRound1,
                matchesRound2,
                matchesRound3,
                matchRound4,
                string(teams[region.winner])
            );
    }

    /**
     * @dev Get the data for the First Four.
     * @return The First Four data in bytes format.
     */
    function getFirstFourData() external view returns (bytes[4] memory) {
        bytes[4] memory matchesFirstFour;
        for (uint8 i = 0; i < 4; i++) {
            matchesFirstFour[i] = getMatchData(firstFourMatches[matchCodes[i]]);
        }

        return matchesFirstFour;
    }

    /**
     * @dev Get the data for the Final Four.
     * @return The Final Four data in bytes format.
     */
    function getFinalFourData() external view returns (bytes memory) {
        bytes[2] memory matchesRound1;
        for (uint8 i = 0; i < 2; i++) {
            matchesRound1[i] = getMatchData(finalFour.matchesRound1[i]);
        }

        bytes memory matchFinal = getMatchData(finalFour.matchFinal);

        // bytes[2] matchesRound1, bytes matchFinal, string winner
        return
            abi.encode(
                matchesRound1,
                matchFinal,
                string(teams[finalFour.winner])
            );
    }

    /**
     * @dev Get the ID of a team based on its name.
     * @param _team The name of the team.
     * @return The ID of the team.
     */
    function getTeamId(string memory _team) external view returns (uint8) {
        return teamToId[abi.encodePacked(_team)];
    }

    /**
     * @dev Get the name of a team based on its ID.
     * @param _teamId The ID of the team.
     * @return The name of the team.
     */
    function getTeamName(uint8 _teamId) external view returns (string memory) {
        return string(teams[_teamId]);
    }

    /**
     * @dev Get all the teams in a specific region.
     * @param _region The name of the region.
     * @return The names of the teams and their corresponding IDs.
     */
    function getAllTeams(bytes32 _region) external view returns (bytes memory) {
        string[16] memory _teams;
        uint8[16] memory _teamIds;

        _teamIds = regions[_region].teams;
        for (uint8 i = 0; i < 16; i++) {
            _teams[i] = string(teams[_teamIds[i]]);
        }

        // string[16] memory, uint8[16] memory
        return abi.encode(_teams, _teamIds);
    }
}
