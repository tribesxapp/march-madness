// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../libraries/Base64.sol";
import "../libraries/BuildImage.sol";
import "../interfaces/IMarchMadnessFactory.sol";
import "../interfaces/IGamesHub.sol";
import "../interfaces/IOnchainMadnessTicket.sol";

contract NftImage {
    using Strings for uint16;
    using Strings for uint256;

    IGamesHub public gamesHub;
    string public backgroundUrl;

    constructor(address _gamesHub, string memory _backgroundUrl) {
        gamesHub = IGamesHub(_gamesHub);
        backgroundUrl = _backgroundUrl;
    }

    modifier onlyAdmin() {
        require(
            gamesHub.checkRole(gamesHub.ADMIN_ROLE(), msg.sender),
            "Caller is not admin"
        );
        _;
    }

    function changeBackgroundUrl(string memory _backgroundUrl)
        public
        onlyAdmin
    {
        backgroundUrl = _backgroundUrl;
    }

    function buildImage(
        uint256 _tokenId
    ) public view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                BuildImage.fullSvgImage(
                                    IOnchainMadnessTicket(
                                        gamesHub.helpers(
                                            keccak256("MM_TICKET")
                                        )
                                    ).betValidator(_tokenId),
                                    IOnchainMadnessTicket(
                                        gamesHub.helpers(
                                            keccak256("MM_TICKET")
                                        )
                                    ).getTeamSymbols(_tokenId),
                                    backgroundUrl,
                                    _tokenId
                                )
                            )
                        )
                    )
                )
            );
    }
}
