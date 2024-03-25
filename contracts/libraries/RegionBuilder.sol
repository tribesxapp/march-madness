// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DinamicData.sol";

library RegionBuilder {
    function region1(
        uint8[63] memory betValidator,
        string[63] memory tokens,
        uint16 start,
        uint16[12] memory coords
    ) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    DinamicData.buildBetSquare(
                        coords[0],
                        coords[1],
                        tokens[start],
                        betValidator[start]
                    ),
                    DinamicData.buildBetSquare(
                        coords[2],
                        coords[3],
                        tokens[start + 1],
                        betValidator[start + 1]
                    ),
                    DinamicData.buildBetSquare(
                        coords[4],
                        coords[5],
                        tokens[start + 2],
                        betValidator[start + 2]
                    ),
                    DinamicData.buildBetSquare(
                        coords[6],
                        coords[7],
                        tokens[start + 3],
                        betValidator[start + 3]
                    ),
                    DinamicData.buildBetSquare(
                        coords[8],
                        coords[9],
                        tokens[start + 4],
                        betValidator[start + 4]
                    ),
                    DinamicData.buildBetSquare(
                        coords[10],
                        coords[11],
                        tokens[start + 5],
                        betValidator[start + 5]
                    )
                )
            );
    }

    function region2(
        uint8[63] memory betValidator,
        string[63] memory tokens,
        uint16 start,
        uint16[10] memory coords
    ) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    DinamicData.buildBetSquare(
                        coords[0],
                        coords[1],
                        tokens[start],
                        betValidator[start]
                    ),
                    DinamicData.buildBetSquare(
                        coords[2],
                        coords[3],
                        tokens[start + 1],
                        betValidator[start + 1]
                    ),
                    DinamicData.buildBetSquare(
                        coords[4],
                        coords[5],
                        tokens[start + 2],
                        betValidator[start + 2]
                    ),
                    DinamicData.buildBetSquare(
                        coords[6],
                        coords[7],
                        tokens[start + 3],
                        betValidator[start + 3]
                    ),
                    DinamicData.buildBetSquare(
                        coords[8],
                        coords[9],
                        tokens[start + 4],
                        betValidator[start + 4]
                    )
                )
            );
    }

    function region3(
        uint8[63] memory betValidator,
        string[63] memory tokens,
        uint16 start,
        uint16[6] memory coords
    ) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    DinamicData.buildBetSquare(
                        coords[0],
                        coords[1],
                        tokens[start],
                        betValidator[start]
                    ),
                    DinamicData.buildBetSquare(
                        coords[2],
                        coords[3],
                        tokens[start + 1],
                        betValidator[start + 1]
                    ),
                    DinamicData.buildBetSquare(
                        coords[4],
                        coords[5],
                        tokens[start + 2],
                        betValidator[start + 2]
                    )
                )
            );
    }

    function finalFour1(
        uint8[63] memory betValidator,
        string[63] memory tokens,
        uint16 start,
        uint16[8] memory coords
    ) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    DinamicData.buildBetSquare(
                        coords[0],
                        coords[1],
                        tokens[start],
                        betValidator[start]
                    ),
                    DinamicData.buildBetSquare(
                        coords[2],
                        coords[3],
                        tokens[start + 1],
                        betValidator[start + 1]
                    ),
                    DinamicData.buildBetSquare(
                        coords[4],
                        coords[5],
                        tokens[start + 2],
                        betValidator[start + 2]
                    ),
                    DinamicData.buildBetSquare(
                        coords[6],
                        coords[7],
                        tokens[start + 3],
                        betValidator[start + 3]
                    )
                )
            );
    }
}
