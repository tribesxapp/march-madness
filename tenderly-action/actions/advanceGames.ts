import { ActionFn, Context, Event } from "@tenderly/actions";

import { ethers } from "ethers";
import axios from "axios";

type Game = {
    id: string;
    status: string;
    title: string;
    home_points: number;
    away_points: number;
    home: {
        alias: string;
    };
    away: {
        alias: string;
    };
};

type Region = {
    teams: string[];
    scores: number[];
};

type TournamentRegions = {
    south: Region;
    west: Region;
    midwest: Region;
    east: Region;
};

const abi = [
    {
        inputs: [
            {
                internalType: "uint256",
                name: "",
                type: "uint256",
            },
        ],
        name: "tournaments",
        outputs: [
            {
                internalType: "address",
                name: "",
                type: "address",
            },
        ],
        stateMutability: "view",
        type: "function",
    },
    {
        inputs: [
            {
                internalType: "uint256",
                name: "year",
                type: "uint256",
            },
            {
                internalType: "string[16]",
                name: "_south",
                type: "string[16]",
            },
            {
                internalType: "string[16]",
                name: "_west",
                type: "string[16]",
            },
            {
                internalType: "string[16]",
                name: "_midwest",
                type: "string[16]",
            },
            {
                internalType: "string[16]",
                name: "_east",
                type: "string[16]",
            },
        ],
        name: "createMarchMadness",
        outputs: [
            {
                internalType: "address",
                name: "",
                type: "address",
            },
        ],
        stateMutability: "nonpayable",
        type: "function",
    },
];

function processGames(length: number, games: Game[]): Region {
    //preencher os arrays de times e scores com valores vazios, para garantir que os arrays tenham games.length * 2 itens
    let teams: string[] = Array.from({ length }, () => "");
    let scores: number[] = Array.from({ length }, () => 0);


    // Itera pelos jogos ordenados e constrói os arrays de retorno
    games.forEach((game) => {
        const gameNumber = parseInt(game.title.split(" - Game ")[1]);
        const indexHome = (gameNumber - 1) * 2;
        const indexAway = indexHome + 1;

        const homePoints = game.status === "closed" ? game.home_points : 0;
        const awayPoints = game.status === "closed" ? game.away_points : 0;

        teams[indexHome] = game.home.alias;
        teams[indexAway] = game.away.alias;
        scores[indexHome] = homePoints;
        scores[indexAway] = awayPoints;
    });

    return { teams, scores };
}

const getMmInfo = async (
    round: number,
    context: Context
): Promise<TournamentRegions> => {
    // const apiKey = await context.secrets.get("project.cmcAPIKey");
    const url = `https://developer.sportradar.com/files/NCAAM_Bracket_5_MM_Tournament_Schedule.json`;
    const sequence = round + 1;

    const length = round === 1 ? 16 : round === 2 ? 8 : round === 3 ? 4 : 2;

    try {
        const response = await axios.get(url);

        const madnessData = response.data;
        let roundData: any;
        madnessData.rounds.forEach((r: any) => {
            if (r.sequence === sequence) {
                roundData = r;
            }
        });

        if (roundData === undefined) {
            throw new Error("Round data not found");
        }

        let southRegion: any;
        let westRegion: any;
        let midwestRegion: any;
        let eastRegion: any;

        roundData.bracketed.forEach((r: any) => {
            if (r.bracket.name === "South Regional") {
                southRegion = processGames(length, r.games);
            } else if (r.bracket.name === "West Regional") {
                westRegion = processGames(length, r.games);
            } else if (r.bracket.name === "Midwest Regional") {
                midwestRegion = processGames(length, r.games);
            } else if (r.bracket.name === "East Regional") {
                eastRegion = processGames(length, r.games);
            } else {
                console.log("Bracket not found:", r.bracket.name);
            }
        });

        return {
            south: southRegion,
            west: westRegion,
            midwest: midwestRegion,
            east: eastRegion,
        };
    } catch (error) {
        console.error("Sportradar API call failed:", error);
        return {
            south: { teams: [], scores: [] },
            west: { teams: [], scores: [] },
            midwest: { teams: [], scores: [] },
            east: { teams: [], scores: [] },
        };
    }
};

const getGasPrice = async (
    baseScanUrl: string,
    baseScanKey: string
): Promise<ethers.BigNumber> => {
    try {
        const response = await axios.get(
            `${baseScanUrl}?module=proxy&action=eth_gasPrice&apikey=${baseScanKey}`
        );
        const proposedGasPriceHex = response.data.result;
        const gasPriceGwei = ethers.BigNumber.from(proposedGasPriceHex);

        // Increase the gas price by 10%
        const increasedGasPrice = gasPriceGwei.mul(110).div(100);
        return increasedGasPrice;
    } catch (error) {
        console.log("Failed to fetch gas price:", error);
        return ethers.utils.parseUnits("10", "gwei");
    }
};

const createNewTournament = async (
    marchMadness: any,
    GAME_YEAR: number,
    baseScanKey: string,
    baseScanUrl: string,
    context: Context
): Promise<string> => {
    const regions = await getMmInfo(1, context);
    if (
        regions.south.teams.length === 0 ||
        regions.west.teams.length === 0 ||
        regions.midwest.teams.length === 0 ||
        regions.east.teams.length === 0
    ) {
        console.error("Failed to fetch March Madness data");
        return "";
    }
    console.log("Creating new March Madness contract, year:", GAME_YEAR);
    console.log("South Region:", regions.south.teams);
    console.log("West Region:", regions.west.teams);
    console.log("Midwest Region:", regions.midwest.teams);
    console.log("East Region:", regions.east.teams);

    try {
        const estimatedGas = await marchMadness.estimateGas.createMarchMadness(
            GAME_YEAR,
            regions.south.teams,
            regions.west.teams,
            regions.midwest.teams,
            regions.east.teams
        );
        const gasLimit = estimatedGas.mul(120).div(100);
        const gasPrice = await getGasPrice(baseScanUrl, baseScanKey);

        console.log(
            `Estimated gas: ${estimatedGas.toString()}, adjusted gas limit: ${gasLimit.toString()}`
        );

        const tx = await marchMadness.createMarchMadness(
            GAME_YEAR,
            regions.south.teams,
            regions.west.teams,
            regions.midwest.teams,
            regions.east.teams,
            {
                gasLimit: gasLimit,
                gasPrice: gasPrice,
            }
        );

        await tx.wait();
        console.log(`New March Madness contract created. TX: ${tx.hash}`);
        // check new contract address
        const tournamentContract = await marchMadness.tournaments(GAME_YEAR);
        console.log("New tournament contract:", tournamentContract);
        return tournamentContract;
    } catch (error) {
        console.error("Failed to create March Madness contract:", error);
        return "";
    }
};

export const advanceGames: ActionFn = async (
    context: Context,
    event: Event
) => {
    const privateKey = await context.secrets.get("project.addressPrivateKey");
    const baseScanKey = await context.secrets.get("baseScan.key");
    const baseScanUrl = await context.secrets.get("baseSepolia.apiUrl");
    const rpcUrl = await context.secrets.get("baseSepolia.rpcUrl");
    const marchMadnessAdress = await context.secrets.get("baseSepolia.marchMadnessContract");
    const GAME_YEAR = 2021;

    console.log("Checking on data for March Madness, year:", GAME_YEAR);

    console.log("MarchMadness Contract:", marchMadnessAdress);

    console.log("Fetching wallet");
    const provider = new ethers.providers.JsonRpcProvider(rpcUrl);
    const wallet = new ethers.Wallet(privateKey, provider);
    console.log("Wallet:", wallet.address);

    console.log("Fetching MarchMadness contract");
    let marchMadness;
    try {
        marchMadness = new ethers.Contract(marchMadnessAdress, abi, wallet);
    } catch (error) {
        console.error("Failed to fetch contract:", error);
        return;
    }

    console.log("Fetching if there is a tournament contract for this year");
    let tournamentContract;
    try {
        tournamentContract = await marchMadness.tournaments(GAME_YEAR);
    } catch (error) {
        console.error("Failed to fetch tournament contract:", error);
        return;
    }

    if (tournamentContract === "0x0000000000000000000000000000000000000000") {
        tournamentContract = await createNewTournament(
            marchMadness,
            GAME_YEAR,
            baseScanKey,
            baseScanUrl,
            context
        );
        if (tournamentContract === "") {
            console.error("Failed to create new tournament contract");
            return;
        }
    }

    console.log(
        "Tournament contract for Year",
        GAME_YEAR,
        ":",
        tournamentContract
    );

    //pegar informação do contrato para o ano atual
    //se não existir um contrato para o ano atual:
    ///entrar na API e buscar todos os jogos do round 1, informando as iniciais dos times para cada região em array de 16 itens
    ///iniciar um novo jogo no contrato para o ano atual
    //se existir um contrato para o ano atual:
    ///consultar o round atual e o status do round
    ///se o status for betsOn ou onGoing, consultar os dados do round atual e organizar os valores para escrever na blockchain
};
