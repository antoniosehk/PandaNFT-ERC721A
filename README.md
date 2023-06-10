## Inspiration
Miniting NFT should be fun! Gamification is brought into NFT minitng through Chainlink keeper and Chainlink VRF v2.

## What it does
Each day Chainlink keeper will increase the mint price of the NFT. You can either mint based on a daily increasing fee or pay a fixed fee to enroll into a luck draw, supported by Chainlink VRF v2, to get 10 NFTs !

## How we built it
- The smart contract was written in Solidity (ERC721A) using Hardhat
   - Chainlink keeper was used to call the increaseMintFee daily
   - Chainlink VRF was used for the randomness
- The front-end was built using React, with Rainbowkit and Wagmi / view, hosted on Vercel
- Dapp was deployed in both Sepolia and Goerli

## Challenges we ran into
- Issues related to using Chainlink keeper and VRF
- Issues related to front-end to have the best UX

## Accomplishments that we're proud of
- The dapp is fully functional !

## What we learned
- Improved skills in smart contract development
- Improved skills in front-end development
- Improved understanding in Chainlink products

## What's next for Panda NFT
- Have more gamification features !

## Demo
 - [https://0xpanda.xyz](https://0xpanda.xyz)

## Deployment

### Set up the .env file
```
DEPLOYER_PRIVATE_KEY=
ALCHEMY_API_KEY=
ETHERSCAN_API_KEY=
```

### Commands
```
npx hardhat compile
npx hardhat test
npx hardhat run scripts/deploy deploy.js
```

## Reference
 - [https://github.com/antoniosehk/PandaNFT-Frontend](https://github.com/antoniosehk/PandaNFT-Frontend)
