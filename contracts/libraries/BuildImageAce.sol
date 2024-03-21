// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ImageParts.sol";

library BuildImageAce {
    function fullSvgImage(uint8 status, uint8[7] memory betValidator, string[7] memory tokens) public pure returns (string memory) {
        bool victory = true;
        for (uint8 i = 0; i < 7; i++) {
            if (betValidator[i] == 2) {
                status = 4;
                victory = false;
            }
        }
        return
            string(
                abi.encodePacked(
                    ImageParts.svgPartUp(),
                    ImageParts.svgPartDown(status, victory),
                    ImageParts.buildCircles(betValidator),
                    ImageParts.buildBets(tokens)
                )
            );
    }
}
