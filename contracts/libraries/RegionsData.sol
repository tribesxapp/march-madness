// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RegionBuilder.sol";

library RegionsData {
    function regionEast(
        uint8[63] memory betValidator,
        string[63] memory tokens
    ) external pure returns (string memory) {
        uint16 xEven = 38;
        uint16 xOdd = 142;
        return
            string(
                abi.encodePacked(
                    RegionBuilder.region1(
                        betValidator,
                        tokens,
                        0,
                        [
                            xEven,
                            160,
                            xOdd,
                            160,
                            xEven,
                            184,
                            xOdd,
                            184,
                            xEven,
                            206,
                            xOdd,
                            206
                        ]
                    ),
                    RegionBuilder.region2(
                        betValidator,
                        tokens,
                        6,
                        [
                            xEven,
                            230,
                            xOdd,
                            230,
                            xEven,
                            306,
                            xOdd,
                            306,
                            xEven,
                            282
                        ]
                    ),
                    RegionBuilder.region3(
                        betValidator,
                        tokens,
                        11,
                        [xEven, 282, xOdd, 356, xEven, 356]
                    )
                )
            );
    }

    function regionSouth(
        uint8[63] memory betValidator,
        string[63] memory tokens
    ) external pure returns (string memory) {
        uint16 xEven = 302;
        uint16 xOdd = 406;
        return
            string(
                abi.encodePacked(
                    RegionBuilder.region1(
                        betValidator,
                        tokens,
                        14,
                        [
                            xEven,
                            160,
                            xOdd,
                            160,
                            xEven,
                            184,
                            xOdd,
                            184,
                            xEven,
                            206,
                            xOdd,
                            206
                        ]
                    ),
                    RegionBuilder.region2(
                        betValidator,
                        tokens,
                        20,
                        [
                            xEven,
                            230,
                            xOdd,
                            230,
                            xEven,
                            306,
                            xOdd,
                            306,
                            xEven,
                            282
                        ]
                    ),
                    RegionBuilder.region3(
                        betValidator,
                        tokens,
                        25,
                        [xEven, 282, xOdd, 356, xEven, 356]
                    )
                )
            );
    }

    function regionWest(
        uint8[63] memory betValidator,
        string[63] memory tokens
    ) external pure returns (string memory) {
        uint16 xEven = 38;
        uint16 xOdd = 142;
        return
            string(
                abi.encodePacked(
                    RegionBuilder.region1(
                        betValidator,
                        tokens,
                        28,
                        [
                            xEven,
                            448,
                            xOdd,
                            448,
                            xEven,
                            472,
                            xOdd,
                            472,
                            xEven,
                            494,
                            xOdd,
                            494
                        ]
                    ),
                    RegionBuilder.region2(
                        betValidator,
                        tokens,
                        34,
                        [
                            xEven,
                            518,
                            xOdd,
                            518,
                            xEven,
                            570,
                            xOdd,
                            570,
                            xEven,
                            594
                        ]
                    ),
                    RegionBuilder.region3(
                        betValidator,
                        tokens,
                        39,
                        [xEven, 594, xOdd, 644, xEven, 644]
                    )
                )
            );
    }

    function regionMidWest(
        uint8[63] memory betValidator,
        string[63] memory tokens
    ) external pure returns (string memory) {
        uint16 xEven = 302;
        uint16 xOdd = 406;
        return
            string(
                abi.encodePacked(
                    RegionBuilder.region1(
                        betValidator,
                        tokens,
                        42,
                        [
                            xEven,
                            448,
                            xOdd,
                            448,
                            xEven,
                            472,
                            xOdd,
                            472,
                            xEven,
                            494,
                            xOdd,
                            494
                        ]
                    ),
                    RegionBuilder.region2(
                        betValidator,
                        tokens,
                        48,
                        [
                            xEven,
                            518,
                            xOdd,
                            518,
                            xEven,
                            570,
                            xOdd,
                            570,
                            xEven,
                            594
                        ]
                    ),
                    RegionBuilder.region3(
                        betValidator,
                        tokens,
                        53,
                        [xEven, 594, xOdd, 644, xEven, 644]
                    )
                )
            );
    }

    function finalFour(
        uint8[63] memory betValidator,
        string[63] memory tokens
    ) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    RegionBuilder.finalFour1(
                        betValidator,
                        tokens,
                        56,
                        [38, 744, 142, 744, 302, 744, 406, 744]
                    ),
                    RegionBuilder.region3(
                        betValidator,
                        tokens,
                        60,
                        [172, 802, 274, 802, 222, 826]
                    )
                )
            );
    }
}
