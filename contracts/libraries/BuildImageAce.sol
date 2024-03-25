// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DinamicData.sol";
import "./RegionsData.sol";

library BuildImageAce {
    function fullSvgImage(
        uint8[63] memory betValidator,
        string[63] memory tokens,
        string memory backgroundUrl,
        uint256 tokenId
    ) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    DinamicData.svgPartUp(backgroundUrl),
                    RegionsData.regionEast(betValidator, tokens),
                    RegionsData.regionSouth(betValidator, tokens),
                    RegionsData.regionWest(betValidator, tokens),
                    RegionsData.regionMidWest(betValidator, tokens),
                    RegionsData.finalFour(betValidator, tokens),
                    DinamicData.nftIdSquare(tokenId),
                    "</g></svg>"
                )
            );
    }
}
//https://nftstorage.link/ipfs/bafkreiblsdf2cyvdmmnzvtvdtsyj3gcscarmdnryljppllt3za3w3dg52m
//https://perfect-pool-dev-public.s3.amazonaws.com/marchmadness/images/fundo.svg
